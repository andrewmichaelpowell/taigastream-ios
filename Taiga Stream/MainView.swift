//  Taiga Stream
//  github.com/andrewmichaelpowell

import SwiftUI

public let color1 = Color(
	red: 10 / 255.0,
	green: 10 / 255.0,
	blue: 10 / 255.0,
	opacity: 1.0
)
public let color2 = Color(
	red: 2 / 255.0,
	green: 218 / 255.0,
	blue: 195 / 255.0,
	opacity: 1.0
)
public let color3 = Color(
	red: 72 / 255.0,
	green: 72 / 255.0,
	blue: 80 / 255.0,
	opacity: 1.0
)
public let color4 = Color(
	red: 36 / 255.0,
	green: 36 / 255.0,
	blue: 40 / 255.0,
	opacity: 1.0
)

struct MainView: View {
	@ObservedObject var streamInfo = StreamInfo.shared

	var body: some View {
		ScrollView {
			ForEach(1...32, id: \.self) { streamNumber in
				HStack(spacing: 12) {
					FaviconView(index: streamNumber - 1)
						.environmentObject(streamInfo)

					StreamSlotRow(index: streamNumber - 1)
						.environmentObject(streamInfo)

					PlayButton(streamNumber: streamNumber)
				}
				.frame(minHeight: 56)
				.padding(.horizontal)
			}
			Spacer()
		}
		.background(.black)
	}
}

struct FaviconView: View {
	let index: Int
	@EnvironmentObject var streamInfo: StreamInfo
	@State private var favicon: UIImage? = nil
	@State private var fallbackIcon: UIImage? = nil

	var station: RadioStation { streamInfo.stations[index] }

	var body: some View {
		Group {
			if let favicon {
				Image(uiImage: favicon)
					.resizable()
					.aspectRatio(contentMode: .fit)
			} else if let fallbackIcon {
				Image(uiImage: fallbackIcon)
					.resizable()
					.renderingMode(.template)
					.foregroundColor(station.url.isEmpty ? color4 : .white)
					.aspectRatio(contentMode: .fit)
			} else {
				Color.black
			}
		}
		.frame(width: 36, height: 36)
		.clipShape(RoundedRectangle(cornerRadius: 6))
		.onAppear {
			loadFallbackIcon()
			loadFavicon()
		}
		.onChange(of: station.faviconUrl) { loadFavicon() }
	}

	private func loadFallbackIcon() {
		fallbackIcon = UIImage(systemName: "antenna.radiowaves.left.and.right")
	}

	private func loadFavicon() {
		guard !station.faviconUrl.isEmpty,
			let url = URL(string: station.faviconUrl)
		else {
			favicon = nil
			return
		}
		URLSession.shared.dataTask(with: url) { data, _, _ in
			if let data, let image = UIImage(data: data) {
				DispatchQueue.main.async { favicon = image }
			}
		}.resume()
	}
}

struct RadioBrowserStation: Identifiable {
	let id: String
	let name: String
	let url: String
	let faviconUrl: String
	let country: String
	let language: String
	let tags: String
	let votes: Int
	let bitrate: Int
}

class RadioBrowserClient {
	static let shared = RadioBrowserClient()
	private var baseUrl = "https://de1.api.radio-browser.info"

	struct SearchParams {
		var name: String = ""
		var limit: Int = 50
		var offset: Int = 0
		var order: String = "votes"
		var reverse: Bool = true
		var hidebroken: Bool = true
	}

	func search(
		params: SearchParams,
		completion: @escaping ([RadioBrowserStation]) -> Void
	) {
		var components = URLComponents(
			string: "\(baseUrl)/json/stations/search"
		)!
		var items: [URLQueryItem] = [
			URLQueryItem(name: "limit", value: String(params.limit)),
			URLQueryItem(name: "offset", value: String(params.offset)),
			URLQueryItem(name: "order", value: params.order),
			URLQueryItem(
				name: "reverse",
				value: params.reverse ? "true" : "false"
			),
			URLQueryItem(
				name: "hidebroken",
				value: params.hidebroken ? "true" : "false"
			),
		]
		if !params.name.isEmpty {
			items.append(URLQueryItem(name: "name", value: params.name))
		}
		components.queryItems = items

		guard let url = components.url else { return }
		var request = URLRequest.noCacheRequest(url: url)
		request.setValue("TaigaStream/1.0", forHTTPHeaderField: "User-Agent")

		URLSession.shared.dataTask(with: request) { data, _, error in
			guard let data, error == nil,
				let json = try? JSONSerialization.jsonObject(with: data)
					as? [[String: Any]]
			else {
				completion([])
				return
			}
			let stations = json.compactMap { dict -> RadioBrowserStation? in
				guard
					let url = dict["url_resolved"] as? String ?? dict["url"]
						as? String,
					!url.isEmpty
				else { return nil }
				return RadioBrowserStation(
					id: dict["stationuuid"] as? String ?? UUID().uuidString,
					name: dict["name"] as? String ?? "",
					url: url,
					faviconUrl: dict["favicon"] as? String ?? "",
					country: dict["country"] as? String ?? "",
					language: dict["language"] as? String ?? "",
					tags: dict["tags"] as? String ?? "",
					votes: dict["votes"] as? Int ?? 0,
					bitrate: dict["bitrate"] as? Int ?? 0
				)
			}
			completion(stations)
		}.resume()
	}

	func recordClick(stationId: String) {
		guard let url = URL(string: "\(baseUrl)/json/url/\(stationId)") else {
			return
		}
		var request = URLRequest(url: url)
		request.setValue("TaigaStream/1.0", forHTTPHeaderField: "User-Agent")
		URLSession.shared.dataTask(with: request).resume()
	}
}

struct RadioBrowserSearchSheet: View {
	let slotIndex: Int
	@Binding var isPresented: Bool
	@EnvironmentObject var streamInfo: StreamInfo

	@State private var searchName = ""
	@State private var results: [RadioBrowserStation] = []
	@State private var isLoading = false
	@State private var hasSearched = false
	@State private var currentOffset = 0
	private let pageSize = 50

	var body: some View {
		NavigationView {
			VStack(spacing: 0) {
				VStack(spacing: 8) {
					HStack {
						Image(systemName: "magnifyingglass")
							.foregroundColor(color3)
						TextField("", text: $searchName)
							.autocorrectionDisabled()
							.onSubmit {
								if !searchName.isEmpty { performSearch() }
							}
					}
					.padding()
					.background(
						RoundedRectangle(cornerRadius: 10)
							.fill(
								color4
							)
					)

					Button(action: performSearch) {
						HStack {
							Spacer()
							if isLoading {
								ProgressView().padding(.trailing, 8)
							}
							Text("Search")
								.bold()
								.foregroundColor(
									isLoading || searchName.isEmpty
										? color3 : .white
								)
							Spacer()
						}
						.padding()
						.background(
							RoundedRectangle(cornerRadius: 10)
								.fill(
									color4
								)
						)
					}
					.disabled(isLoading || searchName.isEmpty)

					Button(action: { isPresented = false }) {
						HStack {
							Spacer()
							Text("Cancel")
								.bold()
								.foregroundColor(.white)
							Spacer()
						}
						.padding()
						.background(
							RoundedRectangle(cornerRadius: 10)
								.fill(
									color4
								)
						)
					}
				}
				.padding()
				if hasSearched && results.isEmpty && !isLoading {
					Spacer()
					Text("No Results")
						.foregroundColor(color3)
					Spacer()
				} else {
					List {
						ForEach(results) { station in
							RadioBrowserResultRow(station: station)
								.contentShape(Rectangle())
								.onTapGesture {
									selectStation(station)
								}
						}
						if results.count == pageSize
							* (currentOffset / pageSize + 1)
							&& !isLoading
						{
							Button(action: loadMore) {
								Text("More Results")
									.frame(maxWidth: .infinity, alignment: .leading)
									.padding(.leading, 48)
							}
						}
						if isLoading && !results.isEmpty {
							HStack {
								Spacer()
								ProgressView()
								Spacer()
							}
						}
					}
					.listStyle(.plain)
				}
			}
			.preferredColorScheme(.dark)
			.navigationTitle("Search")
			.navigationBarTitleDisplayMode(.inline)
		}
	}

	private var allFieldsEmpty: Bool { searchName.isEmpty }
	private func performSearch() {
		currentOffset = 0
		results = []
		hasSearched = true
		isLoading = true
		let params = RadioBrowserClient.SearchParams(
			name: searchName,
			limit: pageSize,
			offset: 0
		)
		RadioBrowserClient.shared.search(params: params) { stations in
			DispatchQueue.main.async {
				results = stations
				isLoading = false
			}
		}
	}

	private func loadMore() {
		isLoading = true
		currentOffset += pageSize
		let params = RadioBrowserClient.SearchParams(
			name: searchName,
			limit: pageSize,
			offset: currentOffset
		)
		RadioBrowserClient.shared.search(params: params) { stations in
			DispatchQueue.main.async {
				results.append(contentsOf: stations)
				isLoading = false
			}
		}
	}

	private func selectStation(_ station: RadioBrowserStation) {
		let saved = RadioStation(
			url: station.url,
			name: station.name,
			faviconUrl: station.faviconUrl
		)
		streamInfo.saveStation(saved, at: slotIndex)
		RadioBrowserClient.shared.recordClick(stationId: station.id)
		isPresented = false
	}
}

struct RadioBrowserResultRow: View {
	let station: RadioBrowserStation
	@State private var favicon: UIImage? = nil

	var body: some View {
		HStack(spacing: 12) {
			Group {
				if let favicon {
					Image(uiImage: favicon)
						.resizable()
						.aspectRatio(contentMode: .fit)
				} else {
					Image(systemName: "antenna.radiowaves.left.and.right")
						.resizable()
						.aspectRatio(contentMode: .fit)
						.foregroundColor(.white)
				}
			}
			.frame(width: 36, height: 36)
			.clipShape(RoundedRectangle(cornerRadius: 6))

			VStack(alignment: .leading, spacing: 2) {
				Text(station.name)
					.font(.body)
					.lineLimit(1)
				HStack(spacing: 6) {
					if !station.country.isEmpty {
						Text(station.country)
							.font(.caption)
							.foregroundColor(color3)
					}
					if !station.tags.isEmpty {
						Text(
							station.tags.components(separatedBy: ",").prefix(2)
								.joined(separator: ", ")
						)
						.font(.caption)
						.foregroundColor(color3)
						.lineLimit(1)
					}
				}
				if station.bitrate > 0 {
					Text("\(station.bitrate) kbps")
						.font(.caption2)
						.foregroundColor(color3)
				}
			}

			Spacer()

			Image(systemName: "chevron.right")
				.font(.caption)
				.foregroundColor(color3)
		}
		.padding(.vertical, 4)
		.onAppear { loadFavicon() }
	}

	private func loadFavicon() {
		guard !station.faviconUrl.isEmpty,
			let url = URL(string: station.faviconUrl)
		else { return }
		URLSession.shared.dataTask(with: url) { data, _, _ in
			if let data, let image = UIImage(data: data) {
				DispatchQueue.main.async { favicon = image }
			}
		}.resume()
	}
}

struct StreamSlotRow: View {
	let index: Int
	@EnvironmentObject var streamInfo: StreamInfo
	@State private var showingOptions = false
	@State private var showingManualEntry = false
	@State private var showingSearch = false
	@State private var manualUrl = ""

	var station: RadioStation { streamInfo.stations[index] }

	var body: some View {
		Button(action: { showingOptions = true }) {
			HStack(spacing: 12) {
				if !station.name.isEmpty {
					Text(station.name)
						.font(.body)
						.foregroundColor(.white)
						.lineLimit(1)
				} else if !station.url.isEmpty {
					Text(station.url)
						.font(.body)
						.foregroundColor(.white)
						.lineLimit(1)
						.truncationMode(.middle)
				}
				Spacer()
			}
			.padding()
			.frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
			.background(
				RoundedRectangle(cornerRadius: 10)
					.fill(
						color1
					)
			)
		}
		.buttonStyle(.plain)
		.sheet(isPresented: $showingOptions) {
			StreamOptionsSheet(
				index: index,
				isPresented: $showingOptions,
				showingSearch: $showingSearch,
				showingManualEntry: $showingManualEntry,
				manualUrl: $manualUrl
			)
			.environmentObject(streamInfo)
		}
		.sheet(isPresented: $showingSearch) {
			RadioBrowserSearchSheet(
				slotIndex: index,
				isPresented: $showingSearch
			)
			.environmentObject(streamInfo)
		}
		.sheet(isPresented: $showingManualEntry) {
			ManualURLSheet(
				slotIndex: index,
				isPresented: $showingManualEntry,
				manualUrl: $manualUrl
			)
			.environmentObject(streamInfo)
		}
	}
}

struct StreamOptionsSheet: View {
	let index: Int
	@Binding var isPresented: Bool
	@Binding var showingSearch: Bool
	@Binding var showingManualEntry: Bool
	@Binding var manualUrl: String
	@EnvironmentObject var streamInfo: StreamInfo

	var station: RadioStation { streamInfo.stations[index] }

	var body: some View {
		NavigationView {
			VStack(spacing: 0) {
				VStack(spacing: 8) {
					optionButton("Search") {
						isPresented = false
						DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
							showingSearch = true
						}
					}
					optionButton("Enter URL") {
						manualUrl = station.url
						isPresented = false
						DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
							showingManualEntry = true
						}
					}
					if !station.url.isEmpty {
						optionButton("Clear", role: .destructive) {
							streamInfo.saveStation(.empty, at: index)
							isPresented = false
						}
					}
					optionButton("Cancel") {
						isPresented = false
					}
				}
				.padding()

				Spacer()
			}
			.preferredColorScheme(.dark)
			.navigationTitle("Stream \(index + 1)")
			.navigationBarTitleDisplayMode(.inline)
		}
	}

	@ViewBuilder
	private func optionButton(
		_ title: LocalizedStringResource,
		role: ButtonRole? = nil,
		action: @escaping () -> Void
	) -> some View {
		Button(action: action) {
			HStack {
				Spacer()
				Text(title)
					.bold()
					.foregroundColor(role == .destructive ? .red : .white)
				Spacer()
			}
			.padding()
			.background(
				RoundedRectangle(cornerRadius: 10)
					.fill(
						color4
					)
			)
		}
		.buttonStyle(.plain)
	}
}

struct ManualURLSheet: View {
	let slotIndex: Int
	@Binding var isPresented: Bool
	@Binding var manualUrl: String
	@EnvironmentObject var streamInfo: StreamInfo

	var station: RadioStation { streamInfo.stations[slotIndex] }

	var body: some View {
		NavigationView {
			VStack(spacing: 0) {
				VStack(spacing: 8) {
					HStack {
						Image(systemName: "link")
							.foregroundColor(color3)
						TextField("", text: $manualUrl)
							.autocorrectionDisabled()
							.autocapitalization(.none)
							.onSubmit { save() }
					}
					.padding()
					.background(
						RoundedRectangle(cornerRadius: 10)
							.fill(
								color4
							)
					)

					Button(action: save) {
						HStack {
							Spacer()
							Text("Save")
								.bold()
								.foregroundColor(
									manualUrl.isEmpty ? color3 : .white
								)
							Spacer()
						}
						.padding()
						.background(
							RoundedRectangle(cornerRadius: 10)
								.fill(
									color4
								)
						)
					}
					.disabled(manualUrl.isEmpty)

					Button(action: { isPresented = false }) {
						HStack {
							Spacer()
							Text("Cancel")
								.bold()
								.foregroundColor(.white)
							Spacer()
						}
						.padding()
						.background(
							RoundedRectangle(cornerRadius: 10)
								.fill(
									color4
								)
						)
					}
				}
				.padding()

				Spacer()
			}
			.preferredColorScheme(.dark)
			.navigationTitle("Enter URL")
			.navigationBarTitleDisplayMode(.inline)
		}
	}

	private func save() {
		let saved = RadioStation(
			url: manualUrl.trimmingCharacters(in: .whitespaces),
			name: station.name,
			faviconUrl: station.faviconUrl
		)
		streamInfo.saveStation(saved, at: slotIndex)
		isPresented = false
	}
}

struct PlayButton: View {
	let streamNumber: Int
	@ObservedObject var streamInfo = StreamInfo.shared

	private var isPlaying: Bool {
		streamInfo.isPlaying && streamInfo.currentStream == streamNumber
			&& streamInfo.stream[streamNumber - 1] != ""
	}

	private var isConfigured: Bool {
		streamInfo.stream[streamNumber - 1] == ""
	}

	var body: some View {
		Button(action: { PlayStream.shared.play(streamNumber: streamNumber) }) {
			if isPlaying {
				Text(Image(systemName: "stop.fill"))
					.font(.title3)
					.frame(maxWidth: .infinity, maxHeight: 50)
			} else {
				Text("\(streamNumber)")
					.font(.title3)
					.foregroundColor(isConfigured ? color4 : .white)
					.frame(maxWidth: .infinity, maxHeight: 50)
			}
		}
		.frame(width: 50, height: 50)
		.buttonStyle(.borderedProminent)
		.buttonBorderShape(.circle)
		.tint(isPlaying ? color2 : color1)
	}
}
