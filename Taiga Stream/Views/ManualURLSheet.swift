//  Taiga Stream (iOS)
//  github.com/andrewmichaelpowell

import Foundation
import SwiftUI

struct ManualURLSheet: View {
	let slotIndex: Int
	@Binding var isPresented: Bool
	@Binding var manualUrl: String
	@EnvironmentObject var streamInfo: StreamInfo
	@Binding var manualName: String

	var station: RadioStation { streamInfo.station(at: slotIndex) }

	private var isValidUrl: Bool {
		guard
			let url = URL(
				string: manualUrl.trimmingCharacters(in: .whitespaces)
			),
			let scheme = url.scheme?.lowercased(),
			scheme == "http" || scheme == "https",
			let host = url.host,
			!host.isEmpty
		else { return false }
		return true
	}

	var body: some View {
		NavigationStack {
			VStack(spacing: 0) {
				VStack(spacing: 8) {
					HStack {
						Image(systemName: "radio")
							.foregroundColor(Color(.tertiaryLabel))
						TextField("", text: $manualName)
							.autocorrectionDisabled()
					}
					.padding()
					.background(
						RoundedRectangle(cornerRadius: 10)
							.fill(Color.sheetControl)
					)
					HStack {
						Image(systemName: "link")
							.foregroundColor(Color(.tertiaryLabel))
						TextField("", text: $manualUrl)
							.autocorrectionDisabled()
							.autocapitalization(.none)
							.onSubmit { save() }
					}
					.padding()
					.background(
						RoundedRectangle(cornerRadius: 10)
							.fill(
								Color.sheetControl
							)
					)

					Button(action: save) {
						HStack {
							Spacer()
							Text("Save")
								.bold()
								.foregroundColor(
									isValidUrl
										? Color(.label) : Color(.tertiaryLabel)
								)
							Spacer()
						}
						.padding()
						.background(
							RoundedRectangle(cornerRadius: 10)
								.fill(
									Color.sheetControl
								)
						)
					}
					.disabled(!isValidUrl)

					Button(action: { isPresented = false }) {
						HStack {
							Spacer()
							Text("Cancel")
								.bold()
								.foregroundColor(Color(.label))
							Spacer()
						}
						.padding()
						.background(
							RoundedRectangle(cornerRadius: 10)
								.fill(
									Color.sheetControl
								)
						)
					}
				}
				.padding()

				Spacer()
			}
			.navigationTitle("Enter URL")
			.navigationBarTitleDisplayMode(.inline)
			.containerBackground(Color.sheetBackground, for: .navigation)
		}
	}

	private func save() {
		guard isValidUrl else { return }
		let saved = RadioStation(
			url: manualUrl.trimmingCharacters(in: .whitespaces),
			name: manualName.trimmingCharacters(in: .whitespaces),
			faviconUrl: station.faviconUrl
		)
		streamInfo.saveStation(saved, at: slotIndex)
		isPresented = false
	}
}
