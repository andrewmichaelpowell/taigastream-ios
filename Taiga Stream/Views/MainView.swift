//  Taiga Stream (iOS)
//  github.com/andrewmichaelpowell

import Foundation
import SwiftUI

struct MainView: View {
	@StateObject private var popupPresenter = StationPopupPresenter()
	@AppStorage("SelectedTab") private var selectedTab = MainTab.radio
	@State private var topSafeAreaInset: CGFloat = 0

	private static let noStatusBarTopMargin: CGFloat = 12

	enum MainTab: String {
		case radio, podcasts
	}

	var body: some View {
		ZStack {
			page(RadioView(), for: .radio)
			page(PodcastsView(), for: .podcasts)
		}
		.safeAreaInset(edge: .top, spacing: 0) {
			NowPlayingPanel()
				.padding(
					.top,
					needsTopMargin(topInset: topSafeAreaInset)
						? Self.noStatusBarTopMargin : 0
				)
		}
		.safeAreaInset(edge: .bottom) {
			PageChooser(selection: $selectedTab)
		}
		.onGeometryChange(for: CGFloat.self) { proxy in
			proxy.safeAreaInsets.top
		} action: { inset in
			topSafeAreaInset = inset
		}
		.stationPopupHost(popupPresenter)
		.task { await PodcastLibrary.shared.refreshAllFeeds() }
	}

	private func page<Content: View>(_ content: Content, for tab: MainTab)
		-> some View
	{
		let isSelected = selectedTab == tab
		return content
			.opacity(isSelected ? 1 : 0)
			.allowsHitTesting(isSelected)
			.accessibilityHidden(!isSelected)
	}

	private func needsTopMargin(topInset: CGFloat) -> Bool {
		UIDevice.current.userInterfaceIdiom == .phone && topInset < 1
	}
}

private struct PageChooser: View {
	@Binding var selection: MainView.MainTab

	@Namespace private var namespace

	private static let itemWidth: CGFloat = 92
	private static let itemHeight: CGFloat = 54
	private static let inset: CGFloat = 4

	var body: some View {
		HStack(spacing: 0) {
			item(.radio, symbol: "radio", label: Text("Radio"))
			item(.podcasts, symbol: "mic", label: Text("Podcasts"))
		}
		.padding(Self.inset)
		.chooserBackground()
		.animation(.snappy, value: selection)
	}

	private func item(
		_ tab: MainView.MainTab,
		symbol: String,
		label: Text
	) -> some View {
		let isSelected = selection == tab
		return Button {
			selection = tab
		} label: {
			Image(systemName: symbol)
				.font(.system(size: 21))
				.foregroundStyle(isSelected ? Color.white : Color.primary)
				.frame(width: Self.itemWidth, height: Self.itemHeight)
				.background {
					if isSelected {
						Capsule()
							.fill(Color.taigaGreen)
							.matchedGeometryEffect(
								id: "selection",
								in: namespace
							)
					}
				}
				.contentShape(Capsule())
		}
		.buttonStyle(.plain)
		.accessibilityLabel(label)
		.accessibilityAddTraits(isSelected ? .isSelected : [])
	}
}

extension View {
	@ViewBuilder
	fileprivate func chooserBackground() -> some View {
		if #available(iOS 26.0, *) {
			glassEffect(.regular.interactive(), in: Capsule())
		} else {
			background(.regularMaterial, in: Capsule())
		}
	}
}
