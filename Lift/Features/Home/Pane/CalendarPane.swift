import SwiftUI
import SwiftData

/// Calendar column: owns selected-date state and embeds the grid UI.
struct CalendarPane: HomePaneContent {

    static let paneKind = HomePane.calendar
    static let paneTitle = "Calendar"
    static let paneSystemImage = "calendar"

    @Environment(\.selectedCalendarDate) private var selectedDate

    var body: some View {
        CalendarGridView(selectedDate: selectedDate)
    }
}

// MARK: - Grid

private struct CalendarGridView: View {
    @Environment(\.focusPane) var focus
    
    @Binding var selectedDate: Date?
    @Query(sort: \TaskItem.deadline) private var tasks: [TaskItem]
    @State private var displayedMonth: Date = Calendar.current.startOfMonth(for: Date())

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    private let weekdaySymbols = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                monthHeader
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        focus(.calendar)
                    }
                weekdayHeader
                    .frame(height: 32)
                dayGrid(availableHeight: geo.size.height - 44 - 32)
            }
        }
        .background(.quaternary.opacity(0.35))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var monthHeader: some View {
        HStack {
            Button { shiftMonth(by: -1) } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .medium))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 8)

            Spacer()

            Text(displayedMonth.formatted(.dateTime.month(.wide).year()))
                .font(.system(size: 15, weight: .semibold))

            Spacer()

            HStack(spacing: 8) {
                if selectedDate != nil {
                    Button {
                        selectedDate = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help("Clear selected date")
                }

                Button { shiftMonth(by: 1) } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 15, weight: .medium))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 8)
        }
        .padding(.horizontal, 4)
    }

    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func dayGrid(availableHeight: CGFloat) -> some View {
        let cells = makeCells()
        let rowCount = CGFloat(cells.count / 7)
        let cellHeight = availableHeight / rowCount

        return GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack(alignment: .topLeading) {
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(cells) { cell in
                        DayCell(
                            cell: cell,
                            isSelected: isSelected(cell.date),
                            isToday: calendar.isDateInToday(cell.date),
                            importantTaskCount: importantTaskCount(on: cell.date)
                        )
                        .frame(height: cellHeight)
                        .contentShape(Rectangle())
                        .onTapGesture { toggleSelection(for: cell.date) }
                    }
                }

                ForEach(0...6, id: \.self) { row in
                    Rectangle()
                        .fill(Color(nsColor: .separatorColor))
                        .frame(width: w, height: 0.5)
                        .offset(y: CGFloat(row) * cellHeight)
                }

                ForEach(1...6, id: \.self) { col in
                    Rectangle()
                        .fill(Color(nsColor: .separatorColor))
                        .frame(width: 0.5, height: h)
                        .offset(x: CGFloat(col) * (w / 7))
                }
            }
        }
        .frame(height: cellHeight * rowCount)
    }

    private func makeCells() -> [CalendarCell] {
        let monthStart = displayedMonth
        let firstWeekday = calendar.component(.weekday, from: monthStart) - 1
        let totalCells = 42

        return (0..<totalCells).map { index in
            let offset = index - firstWeekday
            let date = calendar.date(byAdding: .day, value: offset, to: monthStart)!
            let isCurrentMonth = calendar.isDate(date, equalTo: monthStart, toGranularity: .month)
            return CalendarCell(id: index, date: date, isCurrentMonth: isCurrentMonth)
        }
    }

    private func shiftMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: displayedMonth) {
            displayedMonth = newMonth
        }
    }

    private func isSelected(_ date: Date) -> Bool {
        guard let selectedDate else { return false }
        return calendar.isDate(date, inSameDayAs: selectedDate)
    }

    private func toggleSelection(for date: Date) {
        if isSelected(date) {
            selectedDate = nil
        } else {
            selectedDate = date
        }
    }

    private func importantTaskCount(on date: Date) -> Int {
        countTasks(on: date) { task in
            task.tags.contains { $0.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "important" }
        }
    }

    private func countTasks(on date: Date, matching predicate: (TaskItem) -> Bool) -> Int {
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return 0
        }

        return tasks.reduce(into: 0) { result, task in
            guard let due = task.deadline, due >= startOfDay, due < endOfDay, predicate(task) else { return }
            result += 1
        }
    }
}

// MARK: - Supporting types

private struct CalendarCell: Identifiable {
    let id: Int
    let date: Date
    let isCurrentMonth: Bool
}

private struct DayCell: View {
    let cell: CalendarCell
    let isSelected: Bool
    let isToday: Bool
    let importantTaskCount: Int

    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                if isSelected {
                    Circle()
                        .fill(Color.primary.opacity(0.4))
                        .padding(6)

                } else if isToday {
                    Circle()
                        .fill(Color.accentColor.opacity(0.8))
                        .padding(6)
                }

                Text("\(calendar.component(.day, from: cell.date))")
                    .font(.system(size: 13))
                    .foregroundStyle(labelColor)
                
                if importantTaskCount > 0 {
                    Text("\(importantTaskCount)")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Color.red.opacity(0.6))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        .padding(2)
                }
            }

            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var labelColor: Color {
        if isSelected || isToday { return .white }
        if !cell.isCurrentMonth { return Color(nsColor: .tertiaryLabelColor) }
        return Color(nsColor: .labelColor)
    }
}

extension Calendar {
    fileprivate func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components)!
    }
}

#Preview("Calendar grid") {
    CalendarPane()
        .frame(width: 640, height: 480)
}
