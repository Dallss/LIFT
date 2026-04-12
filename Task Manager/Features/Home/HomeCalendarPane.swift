import SwiftUI

/// Calendar surface; refine with month grid or EventKit later.
struct HomeCalendarPane: View {
    @Binding var selectedDate: Date

    var body: some View {
        VStack(spacing: 12) {
            Text(selectedDate.formatted(.dateTime.month(.wide).year()))
                .font(.title2.weight(.semibold))

            DatePicker(
                "",
                selection: $selectedDate,
                displayedComponents: [.date]
            )
                .datePickerStyle(.graphical)
                .labelsHidden()

            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(.quaternary.opacity(0.35))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
