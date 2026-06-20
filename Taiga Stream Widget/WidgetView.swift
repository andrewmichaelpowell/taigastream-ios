//  Taiga Stream
//  github.com/andrewmichaelpowell

import AVFoundation
import AppIntents
import Combine
import MediaPlayer
import SwiftUI
import WidgetKit

protocol MetadataProvider {
	func matches(streamUrl: URL) -> Bool
	func poll(
		streamUrl: URL,
		completion: @escaping (_ artist: String, _ title: String) -> Void
	)
	var pollInterval: TimeInterval? { get }
}

extension URLRequest {
	static func noCacheRequest(url: URL) -> URLRequest {
		URLRequest(
			url: url,
			cachePolicy: .reloadIgnoringLocalCacheData,
			timeoutInterval: 10
		)
	}
}

struct AudioAddictProvider: MetadataProvider {
	private static let networks = [
		"di", "jazzradio", "rockradio", "radiotunes", "classicalradio",
		"zenradio",
	]

	func matches(streamUrl: URL) -> Bool {
		guard
			let items = URLComponents(
				url: streamUrl,
				resolvingAgainstBaseURL: false
			)?.queryItems,
			let network = items.first(where: { $0.name == "network" })?.value
		else { return false }
		return Self.networks.contains(network)
	}

	func poll(
		streamUrl: URL,
		completion: @escaping (String, String) -> Void
	) {
		guard
			let items = URLComponents(
				url: streamUrl,
				resolvingAgainstBaseURL: false
			)?.queryItems,
			let network = items.first(where: { $0.name == "network" })?.value,
			let channelId = items.first(where: { $0.name == "channel_id" })?
				.value,
			let apiUrl = URL(
				string:
					"https://api.audioaddict.com/v1/\(network)/currently_playing"
			)
		else { return }

		URLSession.shared.dataTask(with: .noCacheRequest(url: apiUrl)) { data, _, error in
			guard let data, error == nil,
				let channels = try? JSONSerialization.jsonObject(with: data)
					as? [[String: Any]],
				let match = channels.first(where: {
					if let id = $0["channel_id"] as? Int {
						return String(id) == channelId
					}
					if let id = $0["channel_id"] as? String {
						return id == channelId
					}
					return false
				}),
				let track = match["track"] as? [String: Any]
			else { return }

			let artist = (track["display_artist"] as? String ?? "")
				.trimmingCharacters(in: .whitespaces)
			let title = (track["display_title"] as? String ?? "")
				.trimmingCharacters(in: .whitespaces)
			completion(artist, title)
		}.resume()
	}

	var pollInterval: TimeInterval? { 15 }
}

struct RTLRadioProvider: MetadataProvider {
	func matches(streamUrl: URL) -> Bool {
		guard let host = streamUrl.host else { return false }
		return streamUrl.absoluteString.contains("streamabc.net")
			&& host.contains("rtl")
	}

	private func channelKey(from streamUrl: URL) -> String? {
		guard
			let pathFirst = streamUrl.pathComponents.first(where: {
				!$0.isEmpty && $0 != "/"
			})
		else { return nil }
		let parts = pathFirst.components(separatedBy: "-")
		let key = parts.dropFirst().prefix(while: {
			Int($0) == nil && $0 != "mp3" && $0 != "aac"
				&& !["128", "64", "192", "320"].contains($0)
		}).joined(separator: "-")
		return key.isEmpty ? nil : key
	}

	func poll(
		streamUrl: URL,
		completion: @escaping (String, String) -> Void
	) {
		guard let channelKey = channelKey(from: streamUrl),
			let apiUrl = URL(
				string:
					"https://www.rtlradio.de/services/program-info/live/lux"
			)
		else { return }

		URLSession.shared.dataTask(with: .noCacheRequest(url: apiUrl)) { data, _, error in
			guard let data, error == nil,
				let channels = try? JSONSerialization.jsonObject(with: data)
					as? [[String: Any]]
			else { return }

			let normalizedTarget = channelKey.replacingOccurrences(
				of: "-",
				with: ""
			)
			guard
				let match = channels.first(where: {
					let key = ($0["channelKey"] as? String ?? "")
						.replacingOccurrences(of: "-", with: "")
					return key == normalizedTarget
				}),
				let history = (match["playHistories"] as? [[String: Any]])?
					.first,
				let track = history["track"] as? [String: Any]
			else { return }

			let artist = (track["artist"] as? String ?? "")
				.trimmingCharacters(in: .whitespaces)
			let title = (track["title"] as? String ?? "")
				.trimmingCharacters(in: .whitespaces)

			if let artworkUrlString = track["itunesCover"] as? String,
				let artworkUrl = URL(string: artworkUrlString)
			{
				URLSession.shared.dataTask(with: .noCacheRequest(url: artworkUrl)) {
					imageData,
					_,
					imageError in
					if let imageData, imageError == nil,
						let image = UIImage(data: imageData)
					{
						DispatchQueue.main.async {
							StreamInfo.shared.applyArtwork(image)
						}
					}
				}.resume()
			}

			completion(artist, title)
		}.resume()
	}

	var pollInterval: TimeInterval? { 15 }
}

struct SomaFMProvider: MetadataProvider {
	func matches(streamUrl: URL) -> Bool {
		guard let host = streamUrl.host else { return false }
		return streamUrl.absoluteString.contains("somafm.com")
			&& host.contains("somafm")
	}

	private func apiUrl(from streamUrl: URL) -> URL? {
		let mountName =
			streamUrl.pathComponents.first(where: { !$0.isEmpty && $0 != "/" })
			?? ""
		let channel = mountName.components(separatedBy: "-").first ?? ""
		guard !channel.isEmpty else { return nil }
		return URL(string: "https://somafm.com/songs/\(channel).json")
	}

	func poll(
		streamUrl: URL,
		completion: @escaping (String, String) -> Void
	) {
		guard let apiUrl = apiUrl(from: streamUrl) else { return }
		URLSession.shared.dataTask(with: .noCacheRequest(url: apiUrl)) { data, _, error in
			guard let data, error == nil,
				let json = try? JSONSerialization.jsonObject(with: data)
					as? [String: Any],
				let songs = json["songs"] as? [[String: Any]],
				let first = songs.first
			else { return }

			let title = (first["title"] as? String ?? "")
				.trimmingCharacters(in: .whitespaces)
			let artist = (first["artist"] as? String ?? "")
				.trimmingCharacters(in: .whitespaces)
			completion(artist, title)
		}.resume()
	}

	var pollInterval: TimeInterval? { 15 }
}

struct BBCRadioProvider: MetadataProvider {
	private static let serviceMap: [String: String] = [
		"bbc_1xtra":
			"https://rms.api.bbc.co.uk/v2/services/bbc_1xtra/segments/latest?experience=domestic&offset=0&limit=1",
		"bbc_6music":
			"https://rms.api.bbc.co.uk/v2/services/bbc_6music/segments/latest?experience=domestic&offset=0&limit=1",
		"bbc_radio_one":
			"https://rms.api.bbc.co.uk/v2/services/bbc_radio_one/segments/latest?experience=domestic&offset=0&limit=1",
		"bbc_radio_two":
			"https://rms.api.bbc.co.uk/v2/services/bbc_radio_two/segments/latest?experience=domestic&offset=0&limit=1",
		"bbc_radio_three":
			"https://rms.api.bbc.co.uk/v2/services/bbc_radio_three/segments/latest?experience=domestic&offset=0&limit=1",
	]

	func matches(streamUrl: URL) -> Bool {
		let s = streamUrl.absoluteString
		return Self.serviceMap.keys.contains(where: { s.contains($0) })
	}

	private func apiUrl(from streamUrl: URL) -> URL? {
		let s = streamUrl.absoluteString
		guard
			let urlString = Self.serviceMap.first(where: { s.contains($0.key) }
			)?.value
		else { return nil }
		return URL(string: urlString)
	}

	func poll(
		streamUrl: URL,
		completion: @escaping (String, String) -> Void
	) {
		guard let apiUrl = apiUrl(from: streamUrl) else { return }
		var request = URLRequest.noCacheRequest(url: apiUrl)
		request.setValue("application/json", forHTTPHeaderField: "Accept")

		URLSession.shared.dataTask(with: request) { data, _, error in
			guard let data, error == nil,
				let json = try? JSONSerialization.jsonObject(with: data)
					as? [String: Any],
				let dataArray = json["data"] as? [[String: Any]],
				let nowPlaying = dataArray.first(where: {
					($0["offset"] as? [String: Any])?["now_playing"] as? Bool
						== true
				}) ?? dataArray.first,
				let titles = nowPlaying["titles"] as? [String: Any]
			else { return }

			let artist = (titles["primary"] as? String ?? "")
				.trimmingCharacters(in: .whitespaces)
			let title = (titles["secondary"] as? String ?? "")
				.trimmingCharacters(in: .whitespaces)
			completion(artist, title)
		}.resume()
	}

	var pollInterval: TimeInterval? { 15 }
}

struct NRKProvider: MetadataProvider {
	private static let channelMap: [String: String] = [
		"p1": "https://psapi.nrk.no/channels/p1/liveelements",
		"p1pluss": "https://psapi.nrk.no/channels/p1pluss/liveelements",
		"p2": "https://psapi.nrk.no/channels/p2/liveelements",
		"p3": "https://psapi.nrk.no/channels/p3/liveelements",
		"p3musikk": "https://psapi.nrk.no/channels/p3musikk/liveelements",
		"mp3": "https://psapi.nrk.no/channels/mp3/liveelements",
		"nyheter": "https://psapi.nrk.no/channels/nyheter/liveelements",
		"radio_super": "https://psapi.nrk.no/channels/radio_super/liveelements",
		"klassisk": "https://psapi.nrk.no/channels/klassisk/liveelements",
		"sapmi": "https://psapi.nrk.no/channels/sapmi/liveelements",
		"jazz": "https://psapi.nrk.no/channels/jazz/liveelements",
		"folkemusikk": "https://psapi.nrk.no/channels/folkemusikk/liveelements",
		"sport": "https://psapi.nrk.no/channels/sport/liveelements",
	]

	func matches(streamUrl: URL) -> Bool {
		guard let host = streamUrl.host else { return false }
		return host.contains("nrk-live-radio-world.akamaized.net")
	}

	private func apiUrl(from streamUrl: URL) -> URL? {
		let s = streamUrl.absoluteString
		guard
			let urlString = Self.channelMap.first(where: { s.contains($0.key) }
			)?
			.value
		else { return nil }
		return URL(string: urlString)
	}

	func poll(
		streamUrl: URL,
		completion: @escaping (String, String) -> Void
	) {
		guard let apiUrl = apiUrl(from: streamUrl) else { return }
		var request = URLRequest.noCacheRequest(url: apiUrl)
		request.setValue("application/json", forHTTPHeaderField: "Accept")

		URLSession.shared.dataTask(with: request) { data, _, error in
			guard let data, error == nil,
				let elements = try? JSONSerialization.jsonObject(with: data)
					as? [[String: Any]]
			else { return }

			let current =
				elements.reversed().first {
					($0["relativeTimeType"] as? String) == "Present"
						&& ($0["type"] as? String) == "Music"
				}
				?? elements.reversed().first {
					($0["relativeTimeType"] as? String) == "Past"
						&& ($0["type"] as? String) == "Music"
				}

			guard let element = current else { return }

			let title = (element["title"] as? String ?? "")
				.trimmingCharacters(in: .whitespaces)
			let artist = (element["description"] as? String ?? "")
				.trimmingCharacters(in: .whitespaces)
			guard !title.isEmpty else { return }

			if let imageUrlString = element["imageUrl"] as? String,
				!imageUrlString.isEmpty,
				let imageUrl = URL(string: imageUrlString)
			{
				URLSession.shared.dataTask(with: .noCacheRequest(url: imageUrl)) {
					imageData,
					_,
					imageError in
					if let imageData, imageError == nil,
						let image = UIImage(data: imageData)
					{
						DispatchQueue.main.async {
							StreamInfo.shared.updateNowPlaying(
								artist: artist.isEmpty
									? "Taiga Stream" : artist,
								title: title
							)
							StreamInfo.shared.applyArtwork(image)
						}
						return
					}
					completion(artist, title)
				}.resume()
			} else {
				completion(artist, title)
			}
		}.resume()
	}

	var pollInterval: TimeInterval? { 15 }
}

struct RadioFranceProvider: MetadataProvider {
	private static let streamToApi: [String: String] = [
		"icecast.radiofrance.fr/fb100pour100annees80":
			"https://api.radiofrance.fr/livemeta/live/5602/transistor_musical_player",
		"icecast.radiofrance.fr/fbchansonfrancaise":
			"https://api.radiofrance.fr/livemeta/live/5601/transistor_musical_player",
		"icecast.radiofrance.fr/fip-hifi":
			"https://api.radiofrance.fr/livemeta/live/7/transistor_musical_player",
		"icecast.radiofrance.fr/fip-midfi":
			"https://api.radiofrance.fr/livemeta/live/7/transistor_musical_player",
		"icecast.radiofrance.fr/fipcultes":
			"https://api.radiofrance.fr/livemeta/live/709/transistor_musical_player",
		"icecast.radiofrance.fr/fipelectro":
			"https://api.radiofrance.fr/livemeta/live/74/transistor_musical_player",
		"icecast.radiofrance.fr/fipgroove":
			"https://api.radiofrance.fr/livemeta/live/66/transistor_musical_player",
		"icecast.radiofrance.fr/fiphiphop":
			"https://api.radiofrance.fr/livemeta/live/95/transistor_musical_player",
		"icecast.radiofrance.fr/fipjazz":
			"https://api.radiofrance.fr/livemeta/live/65/transistor_musical_player",
		"icecast.radiofrance.fr/fipmetal":
			"https://api.radiofrance.fr/livemeta/live/77/transistor_musical_player",
		"icecast.radiofrance.fr/fipmonde":
			"https://api.radiofrance.fr/livemeta/live/69/transistor_musical_player",
		"icecast.radiofrance.fr/fipnouveautes":
			"https://api.radiofrance.fr/livemeta/live/70/transistor_musical_player",
		"icecast.radiofrance.fr/fippop":
			"https://api.radiofrance.fr/livemeta/live/78/transistor_musical_player",
		"icecast.radiofrance.fr/fipreggae":
			"https://api.radiofrance.fr/livemeta/live/71/transistor_musical_player",
		"icecast.radiofrance.fr/fiprock":
			"https://api.radiofrance.fr/livemeta/live/64/transistor_musical_player",
		"icecast.radiofrance.fr/fipsacrefrancais":
			"https://api.radiofrance.fr/livemeta/live/96/transistor_musical_player",
		"icecast.radiofrance.fr/franceinter-hifi":
			"https://api.radiofrance.fr/livemeta/live/1/transistor_inter_player",
		"icecast.radiofrance.fr/franceinter-midfi":
			"https://api.radiofrance.fr/livemeta/live/1/transistor_inter_player",
		"icecast.radiofrance.fr/franceinterlamusiqueinter":
			"https://api.radiofrance.fr/livemeta/live/1101/transistor_musical_player",
		"icecast.radiofrance.fr/francemusique-hifi":
			"https://api.radiofrance.fr/livemeta/live/4/transistor_musique_player",
		"icecast.radiofrance.fr/francemusique-midfi":
			"https://api.radiofrance.fr/livemeta/live/4/transistor_musique_player",
		"icecast.radiofrance.fr/francemusiquebaroque":
			"https://api.radiofrance.fr/livemeta/live/408/transistor_musical_player",
		"icecast.radiofrance.fr/francemusiqueclassiquelove":
			"https://api.radiofrance.fr/livemeta/live/411/transistor_musical_player",
		"icecast.radiofrance.fr/francemusiqueclassiqueplus":
			"https://api.radiofrance.fr/livemeta/live/402/transistor_musical_player",
		"icecast.radiofrance.fr/francemusiqueconcertsradiofrance":
			"https://api.radiofrance.fr/livemeta/live/403/transistor_musical_player",
		"icecast.radiofrance.fr/francemusiqueeasyclassique":
			"https://api.radiofrance.fr/livemeta/live/401/transistor_musical_player",
		"icecast.radiofrance.fr/francemusiquelajazz":
			"https://api.radiofrance.fr/livemeta/live/407/transistor_musical_player",
		"icecast.radiofrance.fr/francemusiquelacontemporaine":
			"https://api.radiofrance.fr/livemeta/live/406/transistor_musical_player",
		"icecast.radiofrance.fr/francemusiquelalabo":
			"https://api.radiofrance.fr/livemeta/live/405/transistor_musical_player",
		"icecast.radiofrance.fr/francemusiquecoramonde":
			"https://api.radiofrance.fr/livemeta/live/404/transistor_musical_player",
		"icecast.radiofrance.fr/francemusiqueOpera":
			"https://api.radiofrance.fr/livemeta/live/409/transistor_musical_player",
		"icecast.radiofrance.fr/francemusiquepianozen":
			"https://api.radiofrance.fr/livemeta/live/410/transistor_musical_player",
		"icecast.radiofrance.fr/mouv-hifi":
			"https://api.radiofrance.fr/livemeta/live/6/transistor_mouv_player",
		"icecast.radiofrance.fr/mouv-midfi":
			"https://api.radiofrance.fr/livemeta/live/6/transistor_mouv_player",
	]

	func matches(streamUrl: URL) -> Bool {
		let s = streamUrl.absoluteString
		return Self.streamToApi.keys.contains(where: { s.contains($0) })
	}

	private func apiUrl(from streamUrl: URL) -> URL? {
		let s = streamUrl.absoluteString
		guard
			let urlString = Self.streamToApi.first(where: { s.contains($0.key) }
			)?
			.value
		else { return nil }
		return URL(string: urlString)
	}

	var pollInterval: TimeInterval? { nil }

	func poll(
		streamUrl: URL,
		completion: @escaping (String, String) -> Void
	) {
		guard let apiUrl = apiUrl(from: streamUrl) else { return }
		pollRadioFrance(
			apiUrl: apiUrl,
			streamUrl: streamUrl,
			completion: completion
		)
	}

	private func pollRadioFrance(
		apiUrl: URL,
		streamUrl: URL,
		completion: @escaping (String, String) -> Void
	) {
		var request = URLRequest(url: apiUrl)
		request.setValue("application/json", forHTTPHeaderField: "Accept")

		URLSession.shared.dataTask(with: request) { data, _, error in
			guard let data, error == nil,
				let json = try? JSONSerialization.jsonObject(with: data)
					as? [String: Any]
			else { return }

			if let delay = json["delayToRefresh"] as? TimeInterval {
				let interval = max(delay / 1000, 10)
				DispatchQueue.main.async {
					DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
						[self] in
						guard StreamInfo.shared.currentStreamUrl == streamUrl
						else { return }
						self.pollRadioFrance(
							apiUrl: apiUrl,
							streamUrl: streamUrl,
							completion: completion
						)
					}
				}
			}

			let nowBlock = json["now"] as? [String: Any]
			let nextBlock = (json["next"] as? [[String: Any]])?.first
			let block: [String: Any]?
			if nowBlock?["favoriteUuid"] is String {
				block = nowBlock
			} else if nextBlock?["favoriteUuid"] is String {
				block = nextBlock
			} else {
				block = nowBlock
			}

			guard let activeBlock = block else { return }

			let firstLine = (activeBlock["firstLine"] as? String ?? "")
				.trimmingCharacters(in: .whitespaces)
			let secondLine = (activeBlock["secondLine"] as? String ?? "")
				.trimmingCharacters(in: .whitespaces)
			let parts = secondLine.components(separatedBy: " • ")

			let artist: String
			let title: String
			if parts.count >= 2 {
				artist = StreamInfo.shared.cleanMetadataString(
					parts[0].trimmingCharacters(in: .whitespaces)
				)
				title = StreamInfo.shared.cleanMetadataString(
					parts.dropFirst().joined(separator: " • ")
						.trimmingCharacters(in: .whitespaces)
				)
			} else {
				artist = ""
				title = StreamInfo.shared.cleanMetadataString(firstLine)
			}

			guard !title.isEmpty, !StreamInfo.shared.junkMetadata(title) else {
				return
			}
			completion(artist, title)
		}.resume()
	}
}

struct ABCRadioProvider: MetadataProvider {
	private static let streamToApi: [String: String] = [
		"streamguys1.com/live/abccountry":
			"https://music.abcradio.net.au/api/v1/plays/country/now.json",
		"streamguys1.com/live/abcjazz":
			"https://music.abcradio.net.au/api/v1/plays/jazz/now.json",
		"streamguys1.com/live/classicfmnsw":
			"https://music.abcradio.net.au/api/v1/plays/classic/now.json",
		"streamguys1.com/live/classic2":
			"https://music.abcradio.net.au/api/v1/plays/classic2/now.json",
		"streamguys1.com/live/doublejnsw":
			"https://music.abcradio.net.au/api/v1/plays/doublej/now.json",
		"streamguys1.com/live/triplejnsw":
			"https://music.abcradio.net.au/api/v1/plays/triplej/now.json",
		"streamguys1.com/live/triplejhottest":
			"https://music.abcradio.net.au/api/v1/plays/h100/now.json",
		"streamguys1.com/live/triplejunearthed":
			"https://music.abcradio.net.au/api/v1/plays/unearthed/now.json",
		"streaming.abc-cdn.net.au/audio/hls/abccountry":
			"https://music.abcradio.net.au/api/v1/plays/country/now.json",
		"streaming.abc-cdn.net.au/audio/hls/abcjazz":
			"https://music.abcradio.net.au/api/v1/plays/jazz/now.json",
		"streaming.abc-cdn.net.au/audio/hls/classicfmnsw":
			"https://music.abcradio.net.au/api/v1/plays/classic/now.json",
		"streaming.abc-cdn.net.au/audio/hls/classic2":
			"https://music.abcradio.net.au/api/v1/plays/classic2/now.json",
		"streaming.abc-cdn.net.au/audio/hls/doublejnsw":
			"https://music.abcradio.net.au/api/v1/plays/doublej/now.json",
		"streaming.abc-cdn.net.au/audio/hls/triplejnsw":
			"https://music.abcradio.net.au/api/v1/plays/triplej/now.json",
		"streaming.abc-cdn.net.au/audio/hls/triplejhottest":
			"https://music.abcradio.net.au/api/v1/plays/h100/now.json",
		"streaming.abc-cdn.net.au/audio/hls/triplejunearthed":
			"https://music.abcradio.net.au/api/v1/plays/unearthed/now.json",
	]

	func matches(streamUrl: URL) -> Bool {
		let s = streamUrl.absoluteString
		return Self.streamToApi.keys.contains(where: { s.contains($0) })
	}

	private func apiUrl(from streamUrl: URL) -> URL? {
		let s = streamUrl.absoluteString
		guard
			let urlString = Self.streamToApi.first(where: { s.contains($0.key) }
			)?
			.value
		else { return nil }
		return URL(string: urlString)
	}

	func poll(
		streamUrl: URL,
		completion: @escaping (String, String) -> Void
	) {
		guard let apiUrl = apiUrl(from: streamUrl) else { return }
		URLSession.shared.dataTask(with: .noCacheRequest(url: apiUrl)) { data, _, error in
			guard let data, error == nil,
				let json = try? JSONSerialization.jsonObject(with: data)
					as? [String: Any],
				let now = json["now"] as? [String: Any],
				let recording = now["recording"] as? [String: Any]
			else { return }

			let title = (recording["title"] as? String ?? "")
				.trimmingCharacters(in: .whitespaces)
			var artist = ""
			if let artists = recording["artists"] as? [[String: Any]] {
				artist = artists.compactMap { $0["name"] as? String }
					.joined(separator: ", ")
			}
			completion(artist, title)
		}.resume()
	}

	var pollInterval: TimeInterval? { 15 }
}

struct RTERadioProvider: MetadataProvider {
	private static let streamToApi: [String: String] = [
		"rte.ie/radio1" : "https://onair.radioapi.io/rte/rteradio1/onair.json",
		"streamtheworld.com/RTE_RADIO1" : "https://onair.radioapi.io/rte/rteradio1/onair.json",
		"rte.ie/2fm" : "https://onair.radioapi.io/rte/rte2fm/onair.json",
		"streamtheworld.com/RTE_2FM": "https://onair.radioapi.io/rte/rte2fm/onair.json",
		"rte.ie/lyricfm": "https://onair.radioapi.io/rte/rtelyricfm/onair.json",
		"streamtheworld.com/RTE_LYRIC" : "https://onair.radioapi.io/rte/rtelyricfm/onair.json",
		"rte.ie/rnag" : "https://onair.radioapi.io/rte/rteraidionagaeltachta/onair.json",
		"streamtheworld.com/RTE_RNAG" : "https://onair.radioapi.io/rte/rteraidionagaeltachta/onair.json",
		"icecast1.rte.ie/gold" : "https://onair.radioapi.io/rte/rtegold/onair.json",
		"streamtheworld.com/RTE_GOLD" : "https://onair.radioapi.io/rte/rtegold/onair.json",
	]

	func matches(streamUrl: URL) -> Bool {
		let s = streamUrl.absoluteString
		return Self.streamToApi.keys.contains(where: { s.contains($0) })
	}

	private func apiUrl(from streamUrl: URL) -> URL? {
		let s = streamUrl.absoluteString
		guard let urlString = Self.streamToApi.first(where: { s.contains($0.key) })?.value
		else { return nil }
		return URL(string: urlString)
	}

	func poll(streamUrl: URL, completion: @escaping (String, String) -> Void) {
		guard let apiUrl = apiUrl(from: streamUrl) else { return }

		URLSession.shared.dataTask(with: .noCacheRequest(url: apiUrl)) { data, _, error in
			guard let data, error == nil,
				let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
				let nowplaying = json["nowplaying"] as? [[String: Any]],
				let current = nowplaying.first(where: { ($0["status"] as? String) == "playing" })
					?? nowplaying.first
			else { return }

			let artist = (current["artist"] as? String ?? "")
				.trimmingCharacters(in: .whitespaces)
			let title = (current["title"] as? String ?? "")
				.trimmingCharacters(in: .whitespaces)
			guard !title.isEmpty else { return }

			if let imageUrlString = current["imageUrl"] as? String,
			   !imageUrlString.isEmpty,
			   let imageUrl = URL(string: imageUrlString)
			{
				URLSession.shared.dataTask(with: .noCacheRequest(url: imageUrl)) { imageData, _, imageError in
					if let imageData, imageError == nil,
					   let image = UIImage(data: imageData)
					{
						DispatchQueue.main.async {
							StreamInfo.shared.applyArtwork(image)
						}
					}
				}.resume()
			}

			completion(artist, title)
		}.resume()
	}

	var pollInterval: TimeInterval? { 15 }
}

struct IcecastProvider: MetadataProvider {
	func matches(streamUrl: URL) -> Bool { true }

	func poll(
		streamUrl: URL,
		completion: @escaping (String, String) -> Void
	) {
		guard
			var components = URLComponents(
				url: streamUrl,
				resolvingAgainstBaseURL: false
			)
		else { return }
		components.path = "/status-json.xsl"
		components.query = nil
		components.scheme = "https"
		guard let statusUrl = components.url else { return }
		let mountPath = streamUrl.path

		URLSession.shared.dataTask(with: .noCacheRequest(url: statusUrl)) { data, _, error in
			guard let data, error == nil,
				let json = try? JSONSerialization.jsonObject(with: data)
					as? [String: Any],
				let iceStats = json["icestats"] as? [String: Any]
			else { return }

			var sources: [[String: Any]] = []
			if let array = iceStats["source"] as? [[String: Any]] {
				sources = array
			} else if let single = iceStats["source"] as? [String: Any] {
				sources = [single]
			}

			let match =
				sources.first {
					($0["listenurl"] as? String)?.hasSuffix(mountPath) == true
				} ?? sources.first
			guard let source = match,
				let rawTitle = source["title"] as? String
			else { return }

			if let rawArtist = source["artist"] as? String,
				!rawArtist.trimmingCharacters(in: .whitespaces).isEmpty
			{
				let artist = StreamInfo.shared.cleanMetadataString(
					rawArtist.trimmingCharacters(in: .whitespaces)
				)
				let title = StreamInfo.shared.cleanMetadataString(
					rawTitle.trimmingCharacters(in: .whitespaces)
				)
				guard !title.isEmpty else { return }
				completion(artist, title)
				return
			}

			let title = rawTitle.trimmingCharacters(in: .whitespaces)
			guard !title.isEmpty else { return }
			let (parsedArtist, parsedTitle) = StreamInfo.shared
				.splitArtistTitle(
					from: title
				)
			let resolvedTitle =
				parsedTitle.isEmpty
				? StreamInfo.shared.cleanMetadataString(title) : parsedTitle
			completion(parsedArtist, resolvedTitle)
		}.resume()
	}

	var pollInterval: TimeInterval? { 15 }
}

public class StreamInfo: NSObject, ObservableObject {
	static let shared = StreamInfo()
	let streamState = UserDefaults(
		suiteName: "group.xyz.andrewmichaelpowell.taigastream"
	)!
	var playerCancellables = Set<AnyCancellable>()
	var sessionCancellables = Set<AnyCancellable>()
	var metadataCancellable: AnyCancellable?
	var playbackHeartbeat: AnyCancellable?
	var currentStreamUrl: URL?
	private var lastKnownArtist: String = ""
	private var lastKnownTitle: String = ""
	private var lastKnownArtwork: UIImage?
	private var lastPolledTitle: String = ""
	private var lastStreamTitle: String = ""
	private var apiMetadataActive = false

	private let metadataProviders: [MetadataProvider] = [
		AudioAddictProvider(),
		RTLRadioProvider(),
		SomaFMProvider(),
		BBCRadioProvider(),
		NRKProvider(),
		RadioFranceProvider(),
		ABCRadioProvider(),
		RTERadioProvider(),
		IcecastProvider(),
	]

	var currentStream: Int {
		get { streamState.integer(forKey: "CurrentStreamKey") }
		set {
			streamState.set(newValue, forKey: "CurrentStreamKey")
			streamState.synchronize()
		}
	}

	var isPlaying: Bool {
		get { streamState.bool(forKey: "PlayingKey") }
		set {
			streamState.set(newValue, forKey: "PlayingKey")
			streamState.synchronize()
			objectWillChange.send()
			DispatchQueue.main.async {
				ControlCenter.shared.reloadAllControls()
			}
			updatePlaybackState()
		}
	}

	@Published var audioPlayer = AVPlayer()
	@Published var stream: [String] = (1...32).map {
		NSUbiquitousKeyValueStore.default.string(forKey: "Stream\($0)Key") ?? ""
	}

	override init() {
		super.init()
		playerObservers()
		sessionObservers()
		commandCenter()
	}

	private func commandCenter() {
		let commandCenter = MPRemoteCommandCenter.shared()
		commandCenter.playCommand.isEnabled = true
		commandCenter.playCommand.addTarget { [weak self] _ in
			guard let self else { return .commandFailed }
			self.audioPlayer.play()
			if let streamUrl = self.currentStreamUrl {
				self.startPlaybackHeartbeat()
				self.startMetadataPolling(streamUrl: streamUrl)
				if !self.lastKnownTitle.isEmpty {
					self.updateNowPlaying(
						artist: self.lastKnownArtist,
						title: self.lastKnownTitle
					)
					if let artwork = self.lastKnownArtwork {
						self.applyArtwork(artwork)
					}
				}
			}
			return .success
		}

		commandCenter.stopCommand.isEnabled = true
		commandCenter.stopCommand.addTarget { [weak self] _ in
			self?.audioPlayer.pause()
			self?.stopPlaybackHeartbeat()
			self?.stopMetadataPolling()
			try? AVAudioSession.sharedInstance().setActive(
				false,
				options: .notifyOthersOnDeactivation
			)
			self?.clearNowPlaying()
			return .success
		}

		commandCenter.togglePlayPauseCommand.isEnabled = true
		commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
			guard let self else { return .commandFailed }
			if self.isPlaying {
				self.audioPlayer.pause()
				self.stopPlaybackHeartbeat()
				self.stopMetadataPolling()
				try? AVAudioSession.sharedInstance().setActive(
					false,
					options: .notifyOthersOnDeactivation
				)
				self.clearNowPlaying()
			} else {
				self.audioPlayer.play()
				if let streamUrl = self.currentStreamUrl {
					self.startPlaybackHeartbeat()
					self.startMetadataPolling(streamUrl: streamUrl)
					if !self.lastKnownTitle.isEmpty {
						self.updateNowPlaying(
							artist: self.lastKnownArtist,
							title: self.lastKnownTitle
						)
						if let artwork = self.lastKnownArtwork {
							self.applyArtwork(artwork)
						}
					}
				}
			}
			return .success
		}

		commandCenter.pauseCommand.isEnabled = true
		commandCenter.pauseCommand.addTarget { [weak self] _ in
			guard let self else { return .commandFailed }
			self.audioPlayer.pause()
			self.stopPlaybackHeartbeat()
			self.stopMetadataPolling()
			try? AVAudioSession.sharedInstance().setActive(
				false,
				options: .notifyOthersOnDeactivation
			)
			self.clearNowPlaying()
			return .success
		}

		commandCenter.skipForwardCommand.isEnabled = false
		commandCenter.skipForwardCommand.preferredIntervals = []
		commandCenter.skipBackwardCommand.isEnabled = false
		commandCenter.skipBackwardCommand.preferredIntervals = []
		commandCenter.nextTrackCommand.isEnabled = false
		commandCenter.previousTrackCommand.isEnabled = false
		commandCenter.changePlaybackPositionCommand.isEnabled = false
	}

	func updateNowPlaying(artist: String = "", title: String = "") {
		let existingArtwork = MPNowPlayingInfoCenter.default().nowPlayingInfo?[
			MPMediaItemPropertyArtwork
		]
		var nowPlayingInfo = [String: Any]()
		nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = true
		nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] =
			isPlaying ? 1.0 : 0.0
		nowPlayingInfo[MPNowPlayingInfoPropertyDefaultPlaybackRate] = 1.0
		nowPlayingInfo[MPMediaItemPropertyArtist] =
			artist.isEmpty ? "Taiga Stream" : artist
		nowPlayingInfo[MPMediaItemPropertyTitle] =
			title.isEmpty ? "Stream \(currentStream)" : title
		if let existingArtwork {
			nowPlayingInfo[MPMediaItemPropertyArtwork] = existingArtwork
		}
		MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
	}

	private func updatePlaybackState() {
		if var nowPlaying = MPNowPlayingInfoCenter.default().nowPlayingInfo {
			nowPlaying[MPNowPlayingInfoPropertyPlaybackRate] =
				isPlaying ? 1.0 : 0.0
			MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlaying
		} else {
			updateNowPlaying()
		}
	}

	func clearNowPlaying() {
		MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
	}

	private var icyPollTimer: AnyCancellable?
	private var lastIcyTitle: String = ""

	func startMetadataPolling(streamUrl: URL) {
		stopMetadataPolling()
		lastPolledTitle = ""
		lastStreamTitle = ""
		apiMetadataActive = false

		guard
			let provider = metadataProviders.first(where: {
				$0.matches(streamUrl: streamUrl)
			})
		else { return }

		let completion = makeCompletion(for: streamUrl)
		provider.poll(streamUrl: streamUrl, completion: completion)

		if provider is IcecastProvider {
			observeMetadata()
		}

		guard let interval = provider.pollInterval else { return }

		icyPollTimer = Timer.publish(every: interval, on: .main, in: .common)
			.autoconnect()
			.sink { [weak self] _ in
				guard let self, self.currentStreamUrl == streamUrl else {
					return
				}
				provider.poll(
					streamUrl: streamUrl,
					completion: self.makeCompletion(for: streamUrl)
				)
			}
	}

	private func makeCompletion(for streamUrl: URL) -> (String, String) -> Void
	{
		{ [weak self] artist, title in
			guard let self else { return }
			let combined = "\(artist)|\(title)"
			guard !title.isEmpty, combined != self.lastPolledTitle else {
				return
			}
			self.lastPolledTitle = combined
			self.apiMetadataActive = true

			let resolvedArtist = artist.isEmpty ? "Taiga Stream" : artist
			let resolvedTitle =
				title.isEmpty ? "Stream \(self.currentStream)" : title

			DispatchQueue.main.async {
				self.lastKnownArtist = resolvedArtist
				self.lastKnownTitle = resolvedTitle
				self.updateNowPlaying(
					artist: resolvedArtist,
					title: resolvedTitle
				)
				self.fetchArtwork(artist: resolvedArtist, title: resolvedTitle)
			}
		}
	}

	func stopMetadataPolling() {
		icyPollTimer = nil
		lastPolledTitle = ""
		lastStreamTitle = ""
		apiMetadataActive = false
	}

	private var metadataOutput: AVPlayerItemMetadataOutput?

	func observeMetadata() {
		if let existingOutput = metadataOutput {
			audioPlayer.currentItem?.remove(existingOutput)
		}
		let output = AVPlayerItemMetadataOutput(identifiers: nil)
		output.setDelegate(self, queue: .main)
		audioPlayer.currentItem?.add(output)
		metadataOutput = output
	}

	func cleanMetadataString(_ input: String) -> String {
		var cleaned = input

		let hostedPlatformPrefixPattern =
			#"(?i)^(visit us at [^\s]+\s*-\s*|\[[^\]]+\]\s*)"#
		if let range = cleaned.range(
			of: hostedPlatformPrefixPattern,
			options: .regularExpression
		) {
			cleaned = String(cleaned[range.upperBound...])
		}

		let isrcPattern = #"\s*-\s*[A-Z][A-Z0-9]{7,11}$"#
		if let range = cleaned.range(
			of: isrcPattern,
			options: .regularExpression
		) {
			cleaned = String(cleaned[cleaned.startIndex..<range.lowerBound])
		}

		let trailingHyphenPattern = #"\s*-\s*$"#
		if let range = cleaned.range(
			of: trailingHyphenPattern,
			options: .regularExpression
		) {
			cleaned = String(cleaned[cleaned.startIndex..<range.lowerBound])
		}

		let bracketedCodePattern = #"\s*\[[A-Za-z0-9]{3,4}\]\s*$"#
		if let range = cleaned.range(
			of: bracketedCodePattern,
			options: .regularExpression
		) {
			cleaned = String(cleaned[cleaned.startIndex..<range.lowerBound])
		}

		return cleaned.trimmingCharacters(in: .whitespaces)
	}

	func junkMetadata(_ value: String) -> Bool {
		let trimmed = value.trimmingCharacters(in: .whitespaces)
		if trimmed.isEmpty { return true }

		if trimmed.range(
			of: #"^zc\d+$"#,
			options: [.regularExpression, .caseInsensitive]
		) != nil {
			return true
		}

		if trimmed.range(
			of: #"^[a-z0-9]*_[a-z0-9_]+$"#,
			options: [.regularExpression, .caseInsensitive]
		) != nil {
			return true
		}

		if trimmed.contains("/") || trimmed.contains("://") { return true }

		if trimmed.range(
			of: #"(?i)(spot\s+block|ad\s+break|commercial\s+break)"#,
			options: .regularExpression
		) != nil {
			return true
		}

		if trimmed.range(
			of: #"\w+\s*=\s*""#,
			options: .regularExpression
		) != nil {
			return true
		}

		return false
	}

	func splitArtistTitle(from raw: String) -> (artist: String, title: String) {
		let separators = [" — ", " – ", " - ", " / ", " · ", " | "]
		for separator in separators {
			let parts = raw.components(separatedBy: separator)
			if parts.count >= 2 {
				let artist = cleanMetadataString(
					parts[0].trimmingCharacters(in: .whitespaces)
				)
				let title = cleanMetadataString(
					parts.dropFirst().joined(separator: separator)
						.trimmingCharacters(in: .whitespaces)
				)
				if !artist.isEmpty && !title.isEmpty {
					return (artist, title)
				}
			}
		}
		return (
			"", cleanMetadataString(raw.trimmingCharacters(in: .whitespaces))
		)
	}

	private func parseMetadata(_ metadataItems: [AVMetadataItem]) {
		guard !apiMetadataActive else { return }
		Task {
			var artist = ""
			var title = ""
			for item in metadataItems {
				if item.commonKey == .commonKeyArtist,
					let value = try? await item.load(.stringValue)
				{
					let cleaned = cleanMetadataString(value)
					artist = junkMetadata(cleaned) ? "" : cleaned
				} else if item.commonKey == .commonKeyTitle,
					let value = try? await item.load(.stringValue)
				{
					let parts = value.components(separatedBy: " - ")
					let isrcPattern = #"^[A-Z][A-Z0-9]{7,11}$"#
					let lastPart =
						parts.last?.trimmingCharacters(in: .whitespaces) ?? ""
					let lastIsIsrc =
						lastPart.range(
							of: isrcPattern,
							options: .regularExpression
						) != nil
					let lastIsEmpty = lastPart.isEmpty

					if lastIsIsrc || lastIsEmpty {
						let cleanParts = parts.dropLast().map {
							$0.trimmingCharacters(in: .whitespaces)
						}
						title = cleanMetadataString(cleanParts.first ?? "")
						artist = cleanMetadataString(
							cleanParts.dropFirst().joined(separator: " - ")
						)
					} else {
						let (parsedArtist, parsedTitle) = splitArtistTitle(
							from: value
						)
						if !parsedArtist.isEmpty {
							artist = parsedArtist
							title = parsedTitle
						} else {
							title =
								parsedTitle.isEmpty
								? cleanMetadataString(value) : parsedTitle
						}
					}
				}

				if junkMetadata(title) { title = "" }
				if junkMetadata(artist) { artist = "" }
			}

			let resolvedArtist = artist.isEmpty ? "Taiga Stream" : artist
			let resolvedTitle =
				title.isEmpty ? "Stream \(currentStream)" : title

			await MainActor.run {
				let combined = "\(resolvedArtist)|\(resolvedTitle)"
				guard combined != self.lastStreamTitle else { return }
				self.lastStreamTitle = combined
				self.lastKnownArtist = resolvedArtist
				self.lastKnownTitle = resolvedTitle
				updateNowPlaying(artist: resolvedArtist, title: resolvedTitle)
				fetchArtwork(artist: resolvedArtist, title: resolvedTitle)
			}
		}
	}

	var isFallbackArtworkSet = false

	private func fetchArtwork(artist: String, title: String) {
		guard artist != "Taiga Stream" || title != "Stream \(currentStream)"
		else {
			if !isFallbackArtworkSet {
				setFallbackArtwork()
				isFallbackArtworkSet = true
			}
			return
		}

		isFallbackArtworkSet = false
		let nowPlayingQuery =
			"\(artist) \(title)"
			.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
			?? ""
		let urlString =
			"https://itunes.apple.com/search?term=\(nowPlayingQuery)&entity=song&limit=1"
		guard let searchUrl = URL(string: urlString) else {
			setFallbackArtwork()
			return
		}

		URLSession.shared.dataTask(with: .noCacheRequest(url: searchUrl)) {
			[weak self] data, _, error in
			guard let self, let data, error == nil,
				let json = try? JSONSerialization.jsonObject(with: data)
					as? [String: Any],
				let results = json["results"] as? [[String: Any]],
				let firstResult = results.first,
				let artworkString = firstResult["artworkUrl100"] as? String
			else {
				DispatchQueue.main.async { self?.setFallbackArtwork() }
				return
			}

			let highResArtworkString = artworkString.replacingOccurrences(
				of: "100x100bb",
				with: "600x600bb"
			)
			guard let artworkUrl = URL(string: highResArtworkString) else {
				DispatchQueue.main.async { self.setFallbackArtwork() }
				return
			}

			URLSession.shared.dataTask(with: .noCacheRequest(url: artworkUrl)) {
				[weak self] imageData, _, imageError in
				guard let self, let imageData, imageError == nil,
					let artworkImage = UIImage(data: imageData)
				else {
					DispatchQueue.main.async { self?.setFallbackArtwork() }
					return
				}
				DispatchQueue.main.async { self.applyArtwork(artworkImage) }
			}.resume()
		}.resume()
	}

	func applyArtwork(_ image: UIImage) {
		lastKnownArtwork = image
		let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
		if var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
		{
			nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
			MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
		}
	}

	func setFallbackArtwork() {
		let icon = appIconImage() ?? UIImage(systemName: "radio")
		guard let icon else { return }
		applyArtwork(icon)
	}

	private func appIconImage() -> UIImage? {
		guard
			let icons = Bundle.main.infoDictionary?["CFBundleIcons"]
				as? [String: Any],
			let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
			let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
			let lastIcon = iconFiles.last
		else { return nil }
		return UIImage(named: lastIcon)
	}

	private func playerObservers() {
		playerCancellables.removeAll()

		audioPlayer.publisher(for: \.timeControlStatus)
			.receive(on: DispatchQueue.main)
			.sink { [weak self] status in
				if status == .paused {
					self?.isPlaying = false
				} else if status == .playing {
					self?.isPlaying = true
				}
			}
			.store(in: &playerCancellables)

		audioPlayer.publisher(for: \.currentItem?.status)
			.receive(on: DispatchQueue.main)
			.sink { [weak self] status in
				if status == .failed { self?.isPlaying = false }
			}
			.store(in: &playerCancellables)

		NotificationCenter.default.publisher(
			for: .AVPlayerItemFailedToPlayToEndTime
		)
		.receive(on: DispatchQueue.main)
		.sink { [weak self] _ in self?.isPlaying = false }
		.store(in: &playerCancellables)

		NotificationCenter.default.publisher(for: .AVPlayerItemPlaybackStalled)
			.receive(on: DispatchQueue.main)
			.sink { [weak self] _ in self?.isPlaying = false }
			.store(in: &playerCancellables)
	}

	private func sessionObservers() {
		sessionCancellables.removeAll()

		NotificationCenter.default.publisher(
			for: AVAudioSession.interruptionNotification
		)
		.receive(on: DispatchQueue.main)
		.sink { [weak self] notification in
			guard let userInfo = notification.userInfo,
				let typeValue = userInfo[AVAudioSessionInterruptionTypeKey]
					as? UInt,
				let type = AVAudioSession.InterruptionType(rawValue: typeValue)
			else { return }
			if type == .began {
				self?.isPlaying = false
				self?.audioPlayer.pause()
			}
		}
		.store(in: &sessionCancellables)

		NotificationCenter.default.publisher(
			for: AVAudioSession.silenceSecondaryAudioHintNotification
		)
		.receive(on: DispatchQueue.main)
		.sink { [weak self] notification in
			guard let userInfo = notification.userInfo,
				let typeValue = userInfo[
					AVAudioSessionSilenceSecondaryAudioHintTypeKey
				] as? UInt,
				let type = AVAudioSession.SilenceSecondaryAudioHintType(
					rawValue: typeValue
				)
			else { return }
			if type == .begin {
				self?.isPlaying = false
				self?.audioPlayer.pause()
			}
		}
		.store(in: &sessionCancellables)

		NotificationCenter.default.publisher(
			for: AVAudioSession.routeChangeNotification
		)
		.receive(on: DispatchQueue.main)
		.sink { [weak self] notification in
			guard let userInfo = notification.userInfo,
				let typeValue = userInfo[AVAudioSessionRouteChangeReasonKey]
					as? UInt,
				let type = AVAudioSession.RouteChangeReason(rawValue: typeValue)
			else { return }
			if type == .categoryChange,
				AVAudioSession.sharedInstance()
					.secondaryAudioShouldBeSilencedHint
			{
				self?.isPlaying = false
				self?.audioPlayer.pause()
			}
		}
		.store(in: &sessionCancellables)

		NotificationCenter.default.publisher(
			for: AVAudioSession.mediaServicesWereLostNotification
		)
		.sink { [weak self] _ in
			self?.isPlaying = false
			self?.audioPlayer.pause()
		}
		.store(in: &sessionCancellables)

		NotificationCenter.default.publisher(
			for: AVAudioSession.mediaServicesWereResetNotification
		)
		.sink { [weak self] _ in
			self?.isPlaying = false
			self?.audioPlayer.pause()
		}
		.store(in: &sessionCancellables)
	}

	func startPlaybackHeartbeat() {
		playbackHeartbeat = Timer.publish(every: 1.0, on: .main, in: .common)
			.autoconnect()
			.sink { [weak self] _ in
				guard let self else { return }
				if self.audioPlayer.timeControlStatus != .playing
					&& self.isPlaying
				{
					self.isPlaying = false
				}
			}
	}

	func stopPlaybackHeartbeat() {
		playbackHeartbeat = nil
	}
}

extension StreamInfo: AVPlayerItemMetadataOutputPushDelegate {
	public func metadataOutput(
		_ output: AVPlayerItemMetadataOutput,
		didOutputTimedMetadataGroups groups: [AVTimedMetadataGroup],
		from track: AVPlayerItemTrack?
	) {
		parseMetadata(groups.flatMap { $0.items })
	}
}

class PlayStream {
	static let shared = PlayStream()

	private func startStream(_ streamUrl: URL, streamNumber: Int) {
		let newStreamItem = AVPlayerItem(url: streamUrl)
		let data = StreamInfo.shared

		try? AVAudioSession.sharedInstance().setActive(
			false,
			options: .notifyOthersOnDeactivation
		)
		try? AVAudioSession.sharedInstance().setCategory(
			.playback,
			mode: .default,
			options: []
		)
		try? AVAudioSession.sharedInstance().setActive(true)

		data.audioPlayer.replaceCurrentItem(with: newStreamItem)
		data.audioPlayer.audiovisualBackgroundPlaybackPolicy =
			.continuesIfPossible
		data.currentStream = streamNumber
		data.currentStreamUrl = streamUrl
		data.isFallbackArtworkSet = false
		data.updateNowPlaying(title: "Stream \(streamNumber)")
		data.setFallbackArtwork()
		data.isFallbackArtworkSet = true
		data.observeMetadata()
		data.audioPlayer.play()
		data.startPlaybackHeartbeat()
		data.startMetadataPolling(streamUrl: streamUrl)
	}

	private func playAction(streamUrl: URL, streamNumber: Int) {
		let data = StreamInfo.shared
		if data.isPlaying && data.currentStream == streamNumber {
			data.audioPlayer.pause()
			data.stopPlaybackHeartbeat()
			data.stopMetadataPolling()
			try? AVAudioSession.sharedInstance().setActive(
				false,
				options: .notifyOthersOnDeactivation
			)
			data.clearNowPlaying()
		} else {
			try? AVAudioSession.sharedInstance().setActive(
				false,
				options: .notifyOthersOnDeactivation
			)
			startStream(streamUrl, streamNumber: streamNumber)
		}
	}

	public func play(streamNumber: Int) {
		guard let url = URL(string: StreamInfo.shared.stream[streamNumber - 1])
		else { return }
		playAction(streamUrl: url, streamNumber: streamNumber)
	}
}

private func configureControl(streamNumber: Int)
	-> some ControlWidgetConfiguration
{
	let kind = "xyz.andrewmichaelpowell.taigastream.stream\(streamNumber)"
	return StaticControlConfiguration(kind: kind) {
		let streamState = UserDefaults(
			suiteName: "group.xyz.andrewmichaelpowell.taigastream"
		)
		let streamStatus =
			(streamState?.bool(forKey: "PlayingKey") ?? false)
			&& (streamState?.integer(forKey: "CurrentStreamKey") ?? 0)
				== streamNumber
		return ControlWidgetToggle(
			isOn: streamStatus,
			action: ToggleIntent(streamNumber: streamNumber)
		) {
			Label(
				"Stream \(streamNumber)",
				systemImage: "\(streamNumber).circle"
			)
		}
	}
	.displayName("Stream \(streamNumber)")
}

struct ToggleIntent: SetValueIntent, AudioPlaybackIntent {
	static let title: LocalizedStringResource = "Play Stream"
	@Parameter(title: "Stream Number") var streamNumber: Int
	@Parameter(title: "Stream Status") var value: Bool

	init(streamNumber: Int) { self.streamNumber = streamNumber }
	init() { self.streamNumber = 1 }

	@MainActor func perform() async throws -> some IntentResult {
		PlayStream.shared.play(streamNumber: streamNumber)
		return .result()
	}
}

struct Control1: ControlWidget {
	var body: some ControlWidgetConfiguration {
		configureControl(streamNumber: 1)
	}
}
struct Control2: ControlWidget {
	var body: some ControlWidgetConfiguration {
		configureControl(streamNumber: 2)
	}
}
struct Control3: ControlWidget {
	var body: some ControlWidgetConfiguration {
		configureControl(streamNumber: 3)
	}
}
struct Control4: ControlWidget {
	var body: some ControlWidgetConfiguration {
		configureControl(streamNumber: 4)
	}
}
struct Control5: ControlWidget {
	var body: some ControlWidgetConfiguration {
		configureControl(streamNumber: 5)
	}
}
struct Control6: ControlWidget {
	var body: some ControlWidgetConfiguration {
		configureControl(streamNumber: 6)
	}
}
struct Control7: ControlWidget {
	var body: some ControlWidgetConfiguration {
		configureControl(streamNumber: 7)
	}
}
struct Control8: ControlWidget {
	var body: some ControlWidgetConfiguration {
		configureControl(streamNumber: 8)
	}
}
struct Control9: ControlWidget {
	var body: some ControlWidgetConfiguration {
		configureControl(streamNumber: 9)
	}
}
struct Control10: ControlWidget {
	var body: some ControlWidgetConfiguration {
		configureControl(streamNumber: 10)
	}
}
struct Control11: ControlWidget {
	var body: some ControlWidgetConfiguration {
		configureControl(streamNumber: 11)
	}
}
struct Control12: ControlWidget {
	var body: some ControlWidgetConfiguration {
		configureControl(streamNumber: 12)
	}
}
struct Control13: ControlWidget {
	var body: some ControlWidgetConfiguration {
		configureControl(streamNumber: 13)
	}
}
struct Control14: ControlWidget {
	var body: some ControlWidgetConfiguration {
		configureControl(streamNumber: 14)
	}
}
struct Control15: ControlWidget {
	var body: some ControlWidgetConfiguration {
		configureControl(streamNumber: 15)
	}
}
struct Control16: ControlWidget {
	var body: some ControlWidgetConfiguration {
		configureControl(streamNumber: 16)
	}
}
struct Control17: ControlWidget {
	var body: some ControlWidgetConfiguration {
		configureControl(streamNumber: 17)
	}
}
struct Control18: ControlWidget {
	var body: some ControlWidgetConfiguration {
		configureControl(streamNumber: 18)
	}
}
struct Control19: ControlWidget {
	var body: some ControlWidgetConfiguration {
		configureControl(streamNumber: 19)
	}
}
struct Control20: ControlWidget {
	var body: some ControlWidgetConfiguration {
		configureControl(streamNumber: 20)
	}
}
struct Control21: ControlWidget {
	var body: some ControlWidgetConfiguration {
		configureControl(streamNumber: 21)
	}
}
struct Control22: ControlWidget {
	var body: some ControlWidgetConfiguration {
		configureControl(streamNumber: 22)
	}
}
struct Control23: ControlWidget {
	var body: some ControlWidgetConfiguration {
		configureControl(streamNumber: 23)
	}
}
struct Control24: ControlWidget {
	var body: some ControlWidgetConfiguration {
		configureControl(streamNumber: 24)
	}
}
struct Control25: ControlWidget {
	var body: some ControlWidgetConfiguration {
		configureControl(streamNumber: 25)
	}
}
struct Control26: ControlWidget {
	var body: some ControlWidgetConfiguration {
		configureControl(streamNumber: 26)
	}
}
struct Control27: ControlWidget {
	var body: some ControlWidgetConfiguration {
		configureControl(streamNumber: 27)
	}
}
struct Control28: ControlWidget {
	var body: some ControlWidgetConfiguration {
		configureControl(streamNumber: 28)
	}
}
struct Control29: ControlWidget {
	var body: some ControlWidgetConfiguration {
		configureControl(streamNumber: 29)
	}
}
struct Control30: ControlWidget {
	var body: some ControlWidgetConfiguration {
		configureControl(streamNumber: 30)
	}
}
struct Control31: ControlWidget {
	var body: some ControlWidgetConfiguration {
		configureControl(streamNumber: 31)
	}
}
struct Control32: ControlWidget {
	var body: some ControlWidgetConfiguration {
		configureControl(streamNumber: 32)
	}
}
