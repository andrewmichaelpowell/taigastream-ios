//  Taiga Stream (iOS)
//  github.com/andrewmichaelpowell

import Foundation
import SwiftUI

struct MainView: View {
	@StateObject private var popupPresenter = StationPopupPresenter()
	@AppStorage("SelectedTab") private var selectedTab = MainTab.radio

	private static let noStatusBarTopMargin: CGFloat = 20

	enum MainTab: String {
		case radio, podcasts
	}

	var body: some View {
		TabView(selection: $selectedTab) {
			Tab(value: MainTab.radio) {
				withTopMargin(RadioView())
			} label: {
				tabIcon("radio")
					.accessibilityLabel(Text("Radio"))
			}
			Tab(value: MainTab.podcasts) {
				withTopMargin(PodcastsView())
			} label: {
				tabIcon("mic")
					.accessibilityLabel(Text("Podcasts"))
			}
		}
		.tint(Color(red: 4 / 255, green: 80 / 255, blue: 48 / 255))
		.stationPopupHost(popupPresenter)
	}

	private func tabIcon(_ name: String) -> Image {
		let config = UIImage.SymbolConfiguration(
			pointSize: 21,
			weight: .regular
		)
		guard let symbol = UIImage(systemName: name, withConfiguration: config)
		else { return Image(systemName: name) }
		let flat = UIGraphicsImageRenderer(size: symbol.size).image { _ in
			symbol.draw(at: .zero)
		}
		return Image(uiImage: flat.withRenderingMode(.alwaysTemplate))
	}

	private func withTopMargin<Content: View>(_ content: Content) -> some View {
		GeometryReader { proxy in
			content
				.background { NowPlayingBackground() }
				.contentMargins(
					.top,
					needsTopMargin(topInset: proxy.safeAreaInsets.top)
						? Self.noStatusBarTopMargin : 0,
					for: .scrollContent
				)
		}
	}

	private func needsTopMargin(topInset: CGFloat) -> Bool {
		UIDevice.current.userInterfaceIdiom == .phone && topInset < 1
	}
}
