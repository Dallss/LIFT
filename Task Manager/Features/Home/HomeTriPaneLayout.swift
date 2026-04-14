import SwiftUI

/// Places exactly three subviews in rects that depend on `focusFraction` and animates smoothly
/// when `focusFraction` changes with `withAnimation` (via `Animatable`).
struct HomeTriPaneLayout: Layout {
    /// Continuous focus: `0` = task list, `1` = calendar, `2` = mini stacks.
    /// Interpolate between adjacent integer stops for sliding transitions.
    var focusFraction: CGFloat

    var animatableData: CGFloat {
        get { focusFraction }
        set { focusFraction = newValue }
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        proposal.replacingUnspecifiedDimensions()
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard subviews.count == 3 else { return }
        let unitRects = interpolatedUnitFrames(at: focusFraction)
        for index in subviews.indices {
            let unit = unitRects[index]
            let frame = CGRect(
                x: bounds.minX + unit.minX * bounds.width,
                y: bounds.minY + unit.minY * bounds.height,
                width: unit.width * bounds.width,
                height: unit.height * bounds.height
            )
            let sizeProposal = ProposedViewSize(width: frame.width, height: frame.height)
            subviews[index].place(
                at: CGPoint(x: frame.minX, y: frame.minY),
                anchor: .topLeading,
                proposal: sizeProposal
            )
        }
    }

    /// Unit-space frames [taskList, calendar, miniStacks] for each discrete focus.
    private static let layouts: [[CGRect]] = [
        // Task list focused
        [
            CGRect(x: 0.0, y: 0.0, width: 0.62, height: 1.0),
            CGRect(x: 0.62, y: 0.0, width: 0.38, height: 0.48),
            CGRect(x: 0.62, y: 0.52, width: 0.38, height: 0.48),
        ],
        // Calendar focused
        [
            CGRect(x: 0.0, y: 0.52, width: 0.34, height: 0.48),
            CGRect(x: 0.34, y: 0.0, width: 0.66, height: 1.0),
            CGRect(x: 0.0, y: 0.0, width: 0.34, height: 0.48),
        ],
        // Mini stacks focused
        [
            CGRect(x: 0.0, y: 0.0, width: 0.36, height: 0.42),
            CGRect(x: 0.0, y: 0.44, width: 0.36, height: 0.56),
            CGRect(x: 0.38, y: 0.0, width: 0.62, height: 1.0),
        ],
    ]

    private func interpolatedUnitFrames(at t: CGFloat) -> [CGRect] {
        let clamped = min(max(t, 0), 2)
        if clamped <= 1 {
            return lerp(Self.layouts[0], Self.layouts[1], t: clamped)
        }
        return lerp(Self.layouts[1], Self.layouts[2], t: clamped - 1)
    }

    private func lerp(_ a: [CGRect], _ b: [CGRect], t: CGFloat) -> [CGRect] {
        zip(a, b).map { lhs, rhs in
            CGRect(
                x: lhs.origin.x + (rhs.origin.x - lhs.origin.x) * t,
                y: lhs.origin.y + (rhs.origin.y - lhs.origin.y) * t,
                width: lhs.width + (rhs.width - lhs.width) * t,
                height: lhs.height + (rhs.height - lhs.height) * t
            )
        }
    }
}
