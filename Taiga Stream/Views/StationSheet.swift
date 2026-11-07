//  Taiga Stream (iOS)
//  github.com/andrewmichaelpowell

import Combine
import SwiftUI
import UIKit

extension View {
	func stationSheet<SheetContent: View>(
		isPresented: Binding<Bool>,
		@ViewBuilder content: @escaping () -> SheetContent
	) -> some View {
		modifier(
			StationSheetModifier(isPresented: isPresented, sheetContent: content)
		)
	}

	func stationPopupHost(_ presenter: StationPopupPresenter) -> some View {
		environment(\.stationPopupPresenter, presenter)
			.overlay { StationPopupHost(presenter: presenter) }
	}
}

final class StationPopupPresenter: ObservableObject {
	fileprivate struct Popup {
		let id: UUID
		let content: AnyView
		let onDismiss: () -> Void
	}

	@Published fileprivate private(set) var popup: Popup?

	private let animation = Animation.easeOut(duration: 0.2)

	fileprivate func present(
		id: UUID,
		content: AnyView,
		onDismiss: @escaping () -> Void
	) {
		withAnimation(animation) {
			popup = Popup(id: id, content: content, onDismiss: onDismiss)
		}
	}

	fileprivate func dismiss(id: UUID) {
		guard popup?.id == id else { return }
		withAnimation(animation) { popup = nil }
	}

	fileprivate func dismissFromOutside() {
		let current = popup
		withAnimation(animation) { popup = nil }
		current?.onDismiss()
	}
}

private struct StationPopupPresenterKey: EnvironmentKey {
	static let defaultValue: StationPopupPresenter? = nil
}

extension EnvironmentValues {
	fileprivate var stationPopupPresenter: StationPopupPresenter? {
		get { self[StationPopupPresenterKey.self] }
		set { self[StationPopupPresenterKey.self] = newValue }
	}
}

private struct StationSheetModifier<SheetContent: View>: ViewModifier {
	@Binding var isPresented: Bool
	let sheetContent: () -> SheetContent
	@Environment(\.stationPopupPresenter) private var presenter
	@State private var id = UUID()

	func body(content: Content) -> some View {
		if UIDevice.current.userInterfaceIdiom == .pad, let presenter {
			content
				.onChange(of: isPresented) { _, presented in
					if presented {
						presenter.present(
							id: id,
							content: AnyView(sheetContent()),
							onDismiss: { isPresented = false }
						)
					} else {
						presenter.dismiss(id: id)
					}
				}
		} else {
			content.sheet(isPresented: $isPresented, content: sheetContent)
		}
	}
}

private struct StationPopupHost: View {
	@ObservedObject var presenter: StationPopupPresenter

	var body: some View {
		ZStack {
			if let popup = presenter.popup {
				Color.black.opacity(0.4)
					.ignoresSafeArea()
					.onTapGesture { presenter.dismissFromOutside() }
					.accessibilityHidden(true)
					.transition(.opacity)

				popup.content
					.environment(\.horizontalSizeClass, .compact)
					.frame(maxWidth: 540, maxHeight: 620)
					.background(Color.sheetBackground)
					.clipShape(
						RoundedRectangle(cornerRadius: 32, style: .continuous)
					)
					.padding(40)
					.accessibilityAddTraits(.isModal)
					.transition(.opacity.combined(with: .scale(scale: 0.95)))
					.id(popup.id)
			}
		}
	}
}

extension Color {
	static let sheetBackground = elevated(.systemBackground)

	static let sheetControl = elevated(.secondarySystemBackground)

	private static func elevated(_ color: UIColor) -> Color {
		Color(
			uiColor: UIColor { traits in
				color.resolvedColor(
					with: traits.modifyingTraits {
						$0.userInterfaceLevel = .elevated
					}
				)
			}
		)
	}
}
