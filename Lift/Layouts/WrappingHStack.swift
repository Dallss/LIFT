//
//  WrappingHStack.swift
//  Task Manager
//
//  Created by Randall Alquicer on 4/30/26.
//

import SwiftUI

struct WrappingHStack: Layout {
    var spacing: CGFloat = 8

    init(spacing: CGFloat = 8) {
        self.spacing = spacing
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let proposedWidth = proposal.width
        let hasFiniteWidth = proposedWidth.map(\.isFinite) ?? false
        let maxWidth = hasFiniteWidth ? (proposedWidth ?? 0) : .greatestFiniteMagnitude

        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var widestRow: CGFloat = 0

        for view in subviews {
            let size = view.sizeThatFits(.unspecified)

            if x + size.width > maxWidth {
                widestRow = max(widestRow, x > 0 ? x - spacing : x)
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }

            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        widestRow = max(widestRow, x > 0 ? x - spacing : x)
        let finalWidth = hasFiniteWidth ? min(widestRow, proposedWidth ?? widestRow) : widestRow
        return CGSize(width: finalWidth, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for view in subviews {
            let size = view.sizeThatFits(.unspecified)

            if x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }

            view.place(
                at: CGPoint(x: x, y: y),
                proposal: ProposedViewSize(size)
            )

            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }
    }
}
