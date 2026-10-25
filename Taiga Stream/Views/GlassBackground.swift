//  Taiga Stream (iOS)
//  github.com/andrewmichaelpowell

import SwiftUI

extension View {
	@ViewBuilder
	func glassBackground<S: Shape>(
		_ shape: S,
		fill: Color,
		tint: Color? = nil,
		interactive: Bool = true
	) -> some View {
		if #available(iOS 26.0, *) {
			glassEffect(.regular.tint(tint).interactive(interactive), in: shape)
		} else {
			background(shape.fill(tint ?? fill))
		}
	}
}
