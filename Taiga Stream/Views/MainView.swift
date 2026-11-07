//  Taiga Stream (iOS)
//  github.com/andrewmichaelpowell

import Foundation
import SwiftUI

struct MainView: View {
	@ObservedObject var streamInfo = StreamInfo.shared
	@StateObject private var popupPresenter = StationPopupPresenter()

	private static let noStatusBarTopMargin: CGFloat = 20

	var body: some View {
		GeometryReader { proxy in
			stationList
				.contentMargins(
					.top,
					needsTopMargin(topInset: proxy.safeAreaInsets.top)
						? Self.noStatusBarTopMargin : 0,
					for: .scrollContent
				)
		}
		.stationPopupHost(popupPresenter)
	}

	private func needsTopMargin(topInset: CGFloat) -> Bool {
		UIDevice.current.userInterfaceIdiom == .phone && topInset < 1
	}

	private var stationList: some View {
		List {
			ForEach(Array(streamInfo.stations.enumerated()), id: \.element.id) {
				index,
				station in
				HStack(spacing: 12) {
					FaviconView(station: station)

					StreamSlotRow(index: index)
						.environmentObject(streamInfo)

					PlayButton(streamNumber: index + 1)
				}
				.frame(minHeight: 56)
				.listRowInsets(
					EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16)
				)
				.listRowSeparator(.hidden)
				.moveDisabled(false)
				.deleteDisabled(true)
			}
			.onMove { source, destination in
				streamInfo.moveStation(from: source, to: destination)
			}

			HStack {
				Spacer()
				StreamSlotRow(index: streamInfo.stations.count, isAddButton: true)
					.environmentObject(streamInfo)
				Spacer()
			}
			.frame(minHeight: 56)
			.listRowInsets(
				EdgeInsets(top: 16, leading: 16, bottom: 4, trailing: 16)
			)
			.listRowSeparator(.hidden)
			.moveDisabled(true)
			.deleteDisabled(true)
		}
		.listStyle(.plain)
		.scrollContentBackground(.hidden)
		.environment(\.editMode, .constant(.active))
	}
}
