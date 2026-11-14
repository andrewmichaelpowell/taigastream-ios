//  Taiga Stream (iOS)
//  github.com/andrewmichaelpowell

import Foundation
import SwiftUI

extension Color {
	static let taigaGreen = Color(red: 4 / 255, green: 80 / 255, blue: 48 / 255)
}

extension View {
	func circleButtonStyle(isOn: Bool = false) -> some View {
		modifier(CircleButtonStyle(isOn: isOn))
	}

	@ViewBuilder
	func sheetButtonGlass() -> some View {
		if #available(iOS 26.0, *) {
			glassEffect(
				.regular.interactive(),
				in: RoundedRectangle(cornerRadius: 10)
			)
		} else {
			background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
		}
	}

	func frostedRowBackground() -> some View {
		background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
	}
}

private struct CircleButtonStyle: ViewModifier {
	let isOn: Bool

	func body(content: Content) -> some View {
		if #available(iOS 26.0, *) {
			if isOn {
				content
					.buttonStyle(.glassProminent)
					.buttonBorderShape(.circle)
					.tint(.taigaGreen)
			} else {
				content
					.buttonStyle(.glass)
					.buttonBorderShape(.circle)
			}
		} else {
			content
				.buttonStyle(.borderedProminent)
				.buttonBorderShape(.circle)
				.tint(isOn ? .taigaGreen : Color(.secondarySystemBackground))
		}
	}
}
