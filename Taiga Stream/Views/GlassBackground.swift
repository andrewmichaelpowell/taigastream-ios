//  Taiga Stream (iOS)
//  github.com/andrewmichaelpowell

import SwiftUI

extension View {
	@ViewBuilder
	// The content shape keeps the whole button tappable: unlike a solid fill, glass doesn't count
	// as content, so a button with nothing else in it (an empty station) would ignore taps.
	func glassBackground<S: Shape>(
		_ shape: S,
		fill: Color,
		tint: Color? = nil
	) -> some View {
		if #available(iOS 26.0, *) {
			contentShape(shape)
				.glassEffect(.regular.tint(tint).interactive(), in: shape)
		} else {
			background(shape.fill(tint ?? fill))
		}
	}
}
