//  Taiga Stream (iOS)
//  github.com/andrewmichaelpowell

import SwiftUI

extension View {
	// Liquid Glass behind a shape on iOS 26 and later, tinted when given a colour. Applied directly
	// rather than through a glass button style so shapes and tints stay exactly as designed.
	// Earlier versions keep the solid fill.
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
