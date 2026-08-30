//  Taiga Stream
//  github.com/andrewmichaelpowell

import Foundation
import SwiftUI

struct ManualURLSheet: View {
	let slotIndex: Int
	@Binding var isPresented: Bool
	@Binding var manualUrl: String
	@EnvironmentObject var streamInfo: StreamInfo
	@Binding var manualName: String

	var station: RadioStation { streamInfo.stations[slotIndex] }

	var body: some View {
		NavigationView {
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
							.fill(Color(.secondarySystemBackground))
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
								Color(.secondarySystemBackground)
							)
					)

					Button(action: save) {
						HStack {
							Spacer()
							Text("Save")
								.bold()
								.foregroundColor(
									manualUrl.isEmpty
										? Color(.tertiaryLabel) : Color(.label)
								)
							Spacer()
						}
						.padding()
						.background(
							RoundedRectangle(cornerRadius: 10)
								.fill(
									Color(.secondarySystemBackground)
								)
						)
					}
					.disabled(manualUrl.isEmpty)

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
									Color(.secondarySystemBackground)
								)
						)
					}
				}
				.padding()

				Spacer()
			}
			.navigationTitle("Enter URL")
			.navigationBarTitleDisplayMode(.inline)
		}
	}

	private func save() {
		let saved = RadioStation(
			url: manualUrl.trimmingCharacters(in: .whitespaces),
			name: manualName.trimmingCharacters(in: .whitespaces),
			faviconUrl: station.faviconUrl
		)
		streamInfo.saveStation(saved, at: slotIndex)
		isPresented = false
	}
}
