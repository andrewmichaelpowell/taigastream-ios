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

struct RadioStation: Codable, Equatable, Identifiable {
	let id: UUID
	var url: String
	var name: String
	var faviconUrl: String

	init(id: UUID = UUID(), url: String, name: String, faviconUrl: String) {
		self.id = id
		self.url = url
		self.name = name
		self.faviconUrl = faviconUrl
	}

	static let empty = RadioStation(url: "", name: "", faviconUrl: "")
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

		URLSession.shared.dataTask(with: .noCacheRequest(url: apiUrl)) {
			data,
			_,
			error in
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

struct StarFMProvider: MetadataProvider {
	var pollInterval: TimeInterval? { nil }

	private static let streamToWebSocket: [String: String] = [
		"stream.starfm.de/berlin":
			"wss://api.streamabc.net/metadata/channel/30_vqtea82nbeon_wvxg",
		"stream.starfm.de/nbg":
			"wss://api.streamabc.net/metadata/channel/30_nbw9xzg7b53v_rgfj",
		"stream.starfm.de/sachsen":
			"wss://api.streamabc.net/metadata/channel/30_ngfg2edxug0a_dtze",
		"stream.starfm.de/nrw":
			"wss://api.streamabc.net/metadata/channel/30_7hciprr0pewh_dkmc",
		"stream.starfm.de/national":
			"wss://api.streamabc.net/metadata/channel/30_2d7qgd0rqsqd_w0dh",
		"stream.starfm.de/alternat":
			"wss://api.streamabc.net/metadata/channel/30_9cjjuqbztc7b_w6tv",
		"stream.starfm.de/90srock":
			"wss://api.streamabc.net/metadata/channel/30_eoplhpklkmnv_zqnc",
		"stream.regenbogen2.de/festivalradio":
			"wss://api.streamabc.net/metadata/channel/atsw_tit9bqllti_g79y",
		"stream.starfm.de/newmetal":
			"wss://api.streamabc.net/metadata/channel/30_nz784lvvrv58_unsh",
		"stream.starfm.de/hardrock":
			"wss://api.streamabc.net/metadata/channel/30_x7lg1zfcn9df_3swf",
		"stream.starfm.de/fromhell":
			"wss://api.streamabc.net/metadata/channel/30_lpuzm574hotr_d953",
		"stream.starfm.de/80srock":
			"wss://api.streamabc.net/metadata/channel/30_lu3nhavsoefx_avs0",
		"stream.starfm.de/classic":
			"wss://api.streamabc.net/metadata/channel/30_wiqder3bbvvp_amxb",
		"stream.starfm.de/blues":
			"wss://api.streamabc.net/metadata/channel/30_yn083yo8fisj_ccoq",
		"stream.starfm.de/ballads":
			"wss://api.streamabc.net/metadata/channel/30_7fh19amhhhoe_d25l",
		"stream.starfm.de/country":
			"wss://api.streamabc.net/metadata/channel/30_euch8c5krctp_dirs",
		"stream.starfm.de/xmas":
			"wss://api.streamabc.net/metadata/channel/30_1x9rkasxzg6m_isgi",
		"stream.starfm.de/newrock":
			"wss://api.streamabc.net/metadata/channel/30_etgneoupeuu8_vu9s",
		"stream.starfm.de/bbrock":
			"wss://api.streamabc.net/metadata/channel/30_vchltty8vm2i_1gq3",
	]

	func matches(streamUrl: URL) -> Bool {
		let s = streamUrl.absoluteString
		return Self.streamToWebSocket.keys.contains(where: { s.contains($0) })
	}

	private func wsUrl(from streamUrl: URL) -> URL? {
		let s = streamUrl.absoluteString
		guard
			let urlString = Self.streamToWebSocket.first(where: {
				s.contains($0.key)
			})?.value
		else { return nil }
		return URL(string: urlString)
	}

	func poll(streamUrl: URL, completion: @escaping (String, String) -> Void) {
		guard let wsUrl = wsUrl(from: streamUrl) else { return }

		let session = URLSession(configuration: .default)
		let task = session.webSocketTask(with: wsUrl)

		func receive() {
			task.receive { result in
				guard StreamInfo.shared.currentStreamUrl == streamUrl else {
					task.cancel()
					return
				}
				switch result {
				case .success(let message):
					if case .string(let text) = message,
						let data = text.data(using: .utf8),
						let json = try? JSONSerialization.jsonObject(with: data)
							as? [String: Any]
					{
						let artist = (json["artist"] as? String ?? "")
							.trimmingCharacters(in: .whitespaces)
						let title = (json["song"] as? String ?? "")
							.trimmingCharacters(in: .whitespaces)
						if !title.isEmpty
							&& !StreamInfo.shared.junkMetadata(title)
						{
							completion(artist, title)
						}
					}
					receive()
				case .failure:
					task.cancel()
				}
			}
		}

		task.resume()
		receive()
	}
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

		URLSession.shared.dataTask(with: .noCacheRequest(url: apiUrl)) {
			data,
			_,
			error in
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
				URLSession.shared.dataTask(
					with: .noCacheRequest(url: artworkUrl)
				) {
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
		URLSession.shared.dataTask(with: .noCacheRequest(url: apiUrl)) {
			data,
			_,
			error in
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
				URLSession.shared.dataTask(with: .noCacheRequest(url: imageUrl))
				{
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
		URLSession.shared.dataTask(with: .noCacheRequest(url: apiUrl)) {
			data,
			_,
			error in
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
		"rte.ie/radio1": "https://onair.radioapi.io/rte/rteradio1/onair.json",
		"streamtheworld.com/RTE_RADIO1":
			"https://onair.radioapi.io/rte/rteradio1/onair.json",
		"rte.ie/2fm": "https://onair.radioapi.io/rte/rte2fm/onair.json",
		"streamtheworld.com/RTE_2FM":
			"https://onair.radioapi.io/rte/rte2fm/onair.json",
		"rte.ie/lyricfm": "https://onair.radioapi.io/rte/rtelyricfm/onair.json",
		"streamtheworld.com/RTE_LYRIC":
			"https://onair.radioapi.io/rte/rtelyricfm/onair.json",
		"rte.ie/rnag":
			"https://onair.radioapi.io/rte/rteraidionagaeltachta/onair.json",
		"streamtheworld.com/RTE_RNAG":
			"https://onair.radioapi.io/rte/rteraidionagaeltachta/onair.json",
		"icecast1.rte.ie/gold":
			"https://onair.radioapi.io/rte/rtegold/onair.json",
		"streamtheworld.com/RTE_GOLD":
			"https://onair.radioapi.io/rte/rtegold/onair.json",
	]

	func matches(streamUrl: URL) -> Bool {
		let s = streamUrl.absoluteString
		return Self.streamToApi.keys.contains(where: { s.contains($0) })
	}

	private func apiUrl(from streamUrl: URL) -> URL? {
		let s = streamUrl.absoluteString
		guard
			let urlString = Self.streamToApi.first(where: { s.contains($0.key) }
			)?.value
		else { return nil }
		return URL(string: urlString)
	}

	func poll(streamUrl: URL, completion: @escaping (String, String) -> Void) {
		guard let apiUrl = apiUrl(from: streamUrl) else { return }

		URLSession.shared.dataTask(with: .noCacheRequest(url: apiUrl)) {
			data,
			_,
			error in
			guard let data, error == nil,
				let json = try? JSONSerialization.jsonObject(with: data)
					as? [String: Any],
				let nowplaying = json["nowplaying"] as? [[String: Any]],
				let current = nowplaying.first(where: {
					($0["status"] as? String) == "playing"
				})
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
				URLSession.shared.dataTask(with: .noCacheRequest(url: imageUrl))
				{ imageData, _, imageError in
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

struct RadioSwissProvider: MetadataProvider {

	private static let streamToApi: [String: String] = [
		"srg-ssr.ch/srgssr/rsp":
			"https://api.radioswisspop.ch/api/v1/rsp/en/current",
		"srg-ssr.ch/m/rsp":
			"https://api.radioswisspop.ch/api/v1/rsp/en/current",
		"srg-ssr.ch/rsp": "https://api.radioswisspop.ch/api/v1/rsp/en/current",
		"radioswisspop.ch":
			"https://api.radioswisspop.ch/api/v1/rsp/en/current",
		"srg-ssr.ch/srgssr/rsj":
			"https://api.radioswissjazz.ch/api/v1/rsj/en/current",
		"srg-ssr.ch/m/rsj":
			"https://api.radioswissjazz.ch/api/v1/rsj/en/current",
		"srg-ssr.ch/rsj": "https://api.radioswissjazz.ch/api/v1/rsj/en/current",
		"radioswissjazz.ch":
			"https://api.radioswissjazz.ch/api/v1/rsj/en/current",
		"srg-ssr.ch/srgssr/rsc":
			"https://api.radioswissclassic.ch/api/v1/rsc/en/current",
		"srg-ssr.ch/m/rsc":
			"https://api.radioswissclassic.ch/api/v1/rsc/en/current",
		"srg-ssr.ch/rsc":
			"https://api.radioswissclassic.ch/api/v1/rsc/en/current",
		"radioswissclassic.ch":
			"https://api.radioswissclassic.ch/api/v1/rsc/en/current",
	]

	func matches(streamUrl: URL) -> Bool {
		let s = streamUrl.absoluteString
		return Self.streamToApi.keys.contains(where: { s.contains($0) })
	}

	private func apiUrl(from streamUrl: URL) -> URL? {
		let s = streamUrl.absoluteString
		guard
			let urlString = Self.streamToApi.first(where: { s.contains($0.key) }
			)?.value
		else { return nil }
		return URL(string: urlString)
	}

	func poll(streamUrl: URL, completion: @escaping (String, String) -> Void) {
		guard let apiUrl = apiUrl(from: streamUrl) else { return }
		let request = URLRequest.noCacheRequest(url: apiUrl)

		URLSession.shared.dataTask(with: request) { data, _, error in
			guard let data, error == nil,
				let json = try? JSONSerialization.jsonObject(with: data)
					as? [String: Any],
				let channel = json["channel"] as? [String: Any],
				let playingNow = channel["playingnow"] as? [String: Any],
				let current = playingNow["current"] as? [String: Any],
				let metadata = current["metadata"] as? [String: Any]
			else { return }

			let title = (metadata["title"] as? String ?? "")
				.trimmingCharacters(in: .whitespaces)
			guard !title.isEmpty else { return }

			let artist =
				[metadata["artist"], metadata["composer"]]
				.compactMap { $0 as? String }
				.map { $0.trimmingCharacters(in: .whitespaces) }
				.first(where: { !$0.isEmpty }) ?? ""

			completion(artist, title)
		}.resume()
	}

	var pollInterval: TimeInterval? { 15 }
}

struct VirginRadioFranceProvider: MetadataProvider {

	private static let streamToApi: [String: (apiUrl: String, key: String)] = [
		"virginradio.ice.infomaniak.ch": (
			"https://virginradio.fr/lite/update_onair", "1"
		),
		"virginclassiquerock.ice.infomaniak.ch": (
			"https://virginradio.fr/lite/update_onair", "5"
		),
		"virginrocklive.ice.infomaniak.ch": (
			"https://virginradio.fr/lite/update_onair", "4"
		),
		"virginrockfrancais.ice.infomaniak.ch": (
			"https://virginradio.fr/lite/update_onair", "8"
		),
		"virginlegendesdurock.ice.infomaniak.ch": (
			"https://virginradio.fr/lite/update_onair", "7"
		),
		"virginmetal.ice.infomaniak.ch": (
			"https://virginradio.fr/lite/update_onair", "9"
		),
		"virginrockannees60.ice.infomaniak.ch": (
			"https://virginradio.fr/lite/update_onair", "15"
		),
		"virginrockannees70.ice.infomaniak.ch": (
			"https://virginradio.fr/lite/update_onair", "16"
		),
		"virginrockannees80.ice.infomaniak.ch": (
			"https://virginradio.fr/lite/update_onair", "10"
		),
		"virginrockannees90.ice.infomaniak.ch": (
			"https://virginradio.fr/lite/update_onair", "6"
		),
		"virginrockannees2000.ice.infomaniak.ch": (
			"https://virginradio.fr/lite/update_onair", "3"
		),
		"virginrockamericain.ice.infomaniak.ch": (
			"https://virginradio.fr/lite/update_onair", "11"
		),
		"virginnoveauxtalents.ice.infomaniak.ch": (
			"https://virginradio.fr/lite/update_onair", "14"
		),
		"virginrockparty.ice.infomaniak.ch": (
			"https://virginradio.fr/lite/update_onair", "13"
		),
		"virginrockanglais.ice.infomaniak.ch": (
			"https://virginradio.fr/lite/update_onair", "12"
		),
		"virginradiorockballad.ice.infomaniak.ch": (
			"https://virginradio.fr/lite/update_onair", "19"
		),
	]

	func matches(streamUrl: URL) -> Bool {
		let s = streamUrl.absoluteString
		return Self.streamToApi.keys.contains(where: { s.contains($0) })
	}

	private func apiEntry(from streamUrl: URL) -> (apiUrl: String, key: String)?
	{
		let s = streamUrl.absoluteString
		return Self.streamToApi.first(where: { s.contains($0.key) })?.value
	}

	func poll(streamUrl: URL, completion: @escaping (String, String) -> Void) {
		guard let entry = apiEntry(from: streamUrl),
			let apiUrl = URL(string: entry.apiUrl),
			let siteUrl = URL(string: "https://virginradio.fr")
		else { return }

		let sessionConfig = URLSessionConfiguration.ephemeral
		sessionConfig.httpCookieAcceptPolicy = .always
		sessionConfig.httpShouldSetCookies = true
		let session = URLSession(configuration: sessionConfig)

		session.dataTask(with: URLRequest.noCacheRequest(url: siteUrl)) {
			_,
			_,
			_ in
			self.fetchOnAir(
				session: session,
				apiUrl: apiUrl,
				entry: entry,
				completion: completion
			)
		}.resume()
	}

	private func fetchOnAir(
		session: URLSession,
		apiUrl: URL,
		entry: (apiUrl: String, key: String),
		completion: @escaping (String, String) -> Void
	) {
		var request = URLRequest.noCacheRequest(url: apiUrl)
		request.httpMethod = "POST"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		request.setValue("*/*", forHTTPHeaderField: "Accept")
		request.setValue(
			"https://virginradio.fr/",
			forHTTPHeaderField: "Referer"
		)
		request.setValue("https://virginradio.fr", forHTTPHeaderField: "Origin")
		request.setValue(
			"Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1",
			forHTTPHeaderField: "User-Agent"
		)
		request.httpBody = try? JSONSerialization.data(
			withJSONObject: ["radio_ids": [entry.key]]
		)

		session.dataTask(with: request) { data, response, error in
			guard let data, error == nil,
				let json = try? JSONSerialization.jsonObject(with: data)
					as? [String: Any],
				let station = json[entry.key] as? [String: Any]
			else { return }

			let artist = (station["artist"] as? String ?? "")
				.trimmingCharacters(in: .whitespaces)
			let title = (station["title"] as? String ?? "")
				.trimmingCharacters(in: .whitespaces)
			guard !title.isEmpty else { return }

			if let coverString = station["cover"] as? String,
				!coverString.isEmpty,
				!coverString.hasPrefix("/"),
				let coverUrl = URL(string: coverString)
			{
				session.dataTask(with: coverUrl) { imageData, _, imageError in
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

struct VirginRadioRomaniaProvider: MetadataProvider {

	func matches(streamUrl: URL) -> Bool {
		streamUrl.host?.contains("astreaming.edi.ro") == true
	}

	func poll(streamUrl: URL, completion: @escaping (String, String) -> Void) {
		guard let apiUrl = URL(string: "https://virginradio.ro/track_info.json")
		else { return }

		let request = URLRequest.noCacheRequest(url: apiUrl)

		URLSession.shared.dataTask(with: request) { data, _, error in
			guard let data, error == nil,
				let json = try? JSONSerialization.jsonObject(with: data)
					as? [String: Any],
				let songs = json["songs"] as? [[String: Any]],
				let current = songs.first
			else { return }

			let artist = (current["artist"] as? String ?? "")
				.trimmingCharacters(in: .whitespaces)
			let title = (current["track"] as? String ?? "")
				.trimmingCharacters(in: .whitespaces)
			guard !title.isEmpty else { return }

			completion(artist, title)
		}.resume()
	}

	var pollInterval: TimeInterval? { 15 }
}

struct VirginRadioOmanProvider: MetadataProvider {

	func matches(streamUrl: URL) -> Bool {
		guard let host = streamUrl.host else { return false }
		return host == "uk5.internet-radio.com" && streamUrl.port == 8115
	}

	func poll(streamUrl: URL, completion: @escaping (String, String) -> Void) {
		guard
			let apiUrl = URL(
				string:
					"http://uk5.internet-radio.com:8115/played?sid=1&type=json&callback=cb&_=\(Int(Date().timeIntervalSince1970 * 1000))"
			)
		else { return }

		let request = URLRequest.noCacheRequest(url: apiUrl)

		URLSession.shared.dataTask(with: request) { data, _, error in
			guard let data, error == nil,
				var text = String(data: data, encoding: .utf8)
			else { return }

			if let start = text.firstIndex(of: "["),
				let end = text.lastIndex(of: "]")
			{
				text = String(text[start...end])
			}

			guard let jsonData = text.data(using: .utf8),
				let entries = try? JSONSerialization.jsonObject(with: jsonData)
					as? [[String: Any]],
				let current = entries.first,
				let metadata = current["metadata"] as? [String: Any],
				let urlString = metadata["url"] as? String
			else { return }

			let queryString =
				urlString.hasPrefix("&")
				? String(urlString.dropFirst())
				: urlString

			var params: [String: String] = [:]
			for pair in queryString.components(separatedBy: "&") {
				let parts = pair.components(separatedBy: "=")
				guard parts.count == 2 else { continue }
				let key = parts[0]
				let value =
					parts[1]
					.replacingOccurrences(of: "+", with: " ")
					.removingPercentEncoding ?? parts[1]
				params[key] = value
			}

			let artist = (params["artist"] ?? "").trimmingCharacters(
				in: .whitespaces
			)
			let title = (params["title"] ?? "").trimmingCharacters(
				in: .whitespaces
			)
			guard !title.isEmpty else { return }

			completion(artist, title)
		}.resume()
	}
	var pollInterval: TimeInterval? { 15 }
}

struct ZenoFMProvider: MetadataProvider {
	var pollInterval: TimeInterval? { 30 }
	func matches(streamUrl: URL) -> Bool {
		let result = streamUrl.host?.contains("stream.zeno.fm") == true
		return result
	}

	private func mountId(from streamUrl: URL) -> String? {
		streamUrl.pathComponents.first(where: { !$0.isEmpty && $0 != "/" })
	}

	func poll(streamUrl: URL, completion: @escaping (String, String) -> Void) {
		guard let mount = mountId(from: streamUrl),
			let apiUrl = URL(
				string: "https://api.zeno.fm/mounts/metadata/subscribe/\(mount)"
			)
		else { return }
		let config = URLSessionConfiguration.default
		config.timeoutIntervalForRequest = 60
		config.timeoutIntervalForResource = 3600
		let delegate = ZenoSSEDelegate(
			streamUrl: streamUrl,
			completion: completion
		)
		let session = URLSession(
			configuration: config,
			delegate: delegate,
			delegateQueue: nil
		)
		var request = URLRequest(url: apiUrl)
		request.timeoutInterval = 3600
		request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
		request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
		session.dataTask(with: request).resume()
		delegate.session = session
	}
}

private class ZenoSSEDelegate: NSObject, URLSessionDataDelegate {
	let streamUrl: URL
	let completion: (String, String) -> Void
	var buffer = ""
	var session: URLSession?
	init(streamUrl: URL, completion: @escaping (String, String) -> Void) {
		self.streamUrl = streamUrl
		self.completion = completion
	}

	func urlSession(
		_ session: URLSession,
		dataTask: URLSessionDataTask,
		didReceive data: Data
	) {
		guard let text = String(data: data, encoding: .utf8) else {
			return
		}
		buffer += text

		let events = buffer.components(separatedBy: "\n\n")
		buffer = events.last ?? ""

		for event in events.dropLast() {
			guard !event.isEmpty else { continue }
			for line in event.components(separatedBy: "\n") {
				let prefix = "data: "
				guard line.hasPrefix(prefix) else { continue }
				let jsonString = String(line.dropFirst(prefix.count))
				guard let jsonData = jsonString.data(using: .utf8),
					let json = try? JSONSerialization.jsonObject(with: jsonData)
						as? [String: Any]
				else { continue }
				guard StreamInfo.shared.currentStreamUrl == streamUrl else {
					return
				}
				let streamTitle = (json["streamTitle"] as? String ?? "")
					.trimmingCharacters(in: .whitespaces)
				guard !streamTitle.isEmpty else { continue }
				var normalized = streamTitle
				while normalized.contains("  ") {
					normalized = normalized.replacingOccurrences(
						of: "  ",
						with: " "
					)
				}
				var artist = ""
				var title = normalized

				if normalized.contains(" - ") {
					let (parsedArtist, parsedTitle) =
						StreamInfo.shared.splitArtistTitle(from: normalized)
					if !parsedArtist.isEmpty {
						artist = parsedArtist
						title = parsedTitle
					}
				} else if normalized.contains("-") {
					let parts = normalized.components(separatedBy: "-")
						.map { $0.trimmingCharacters(in: .whitespaces) }
						.filter { !$0.isEmpty }
					if parts.count >= 2 {
						let parsedArtist = StreamInfo.shared
							.cleanMetadataString(parts[0])
						let parsedTitle = StreamInfo.shared.cleanMetadataString(
							parts[1]
						)
						if !parsedArtist.isEmpty && !parsedTitle.isEmpty {
							artist = parsedArtist
							title = parsedTitle
						}
					}
				}

				guard !title.isEmpty,
					!StreamInfo.shared.junkMetadata(title)
				else { continue }
				completion(artist, title)
			}
		}
	}

	func urlSession(
		_ session: URLSession,
		task: URLSessionTask,
		didCompleteWithError error: Error?
	) {
		self.session = nil
	}
}

struct VRTRadioProvider: MetadataProvider {
	var pollInterval: TimeInterval? { 30 }

	private static let streamToPage: [String: String] = [
		"icecast.vrtcdn.be/radio1": "/vrtmax/livestream/audio/radio1/",
		"icecast.vrtcdn.be/ra2ant":
			"/vrtmax/livestream/audio/radio2-antwerpen/",
		"icecast.vrtcdn.be/ra2lim": "/vrtmax/livestream/audio/radio2-limburg/",
		"icecast.vrtcdn.be/ra2ovl":
			"/vrtmax/livestream/audio/radio2-oost-vlaanderen/",
		"icecast.vrtcdn.be/ra2vlb":
			"/vrtmax/livestream/audio/radio2-vlaams-brabant/",
		"icecast.vrtcdn.be/ra2wvl":
			"/vrtmax/livestream/audio/radio2-west-vlaanderen/",
		"icecast.vrtcdn.be/klara": "/vrtmax/livestream/audio/klara/",
		"icecast.vrtcdn.be/klaracontinuo":
			"/vrtmax/livestream/audio/klara-continuo/",
		"icecast.vrtcdn.be/stubru": "/vrtmax/livestream/audio/stubru/",
		"icecast.vrtcdn.be/mnm": "/vrtmax/livestream/audio/mnm/",
		"icecast.vrtcdn.be/mnm_hits": "/vrtmax/livestream/audio/mnm-hits/",
	]

	func matches(streamUrl: URL) -> Bool {
		let s = streamUrl.absoluteString
		return Self.streamToPage.keys.contains(where: { s.contains($0) })
	}

	private func pagePath(from streamUrl: URL) -> String? {
		let s = streamUrl.absoluteString
		return Self.streamToPage.first(where: { s.contains($0.key) })?.value
	}

	func poll(streamUrl: URL, completion: @escaping (String, String) -> Void) {
		guard let pagePath = pagePath(from: streamUrl),
			let apiUrl = URL(
				string: "https://www.vrt.be/vrtnu-api/graphql/public/v1"
			)
		else { return }

		let query = """
			{
			  "query": "query AudioLivestreamPage($path: ID!) { page(id: $path) { ... on AudioLivestreamPage { player { title subtitle maxAge } } } }",
			  "variables": { "path": "\(pagePath)" }
			}
			"""

		guard let bodyData = query.data(using: .utf8) else { return }

		var request = URLRequest.noCacheRequest(url: apiUrl)
		request.httpMethod = "POST"
		request.httpBody = bodyData
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		request.setValue("application/json", forHTTPHeaderField: "Accept")
		request.setValue("https://www.vrt.be", forHTTPHeaderField: "Origin")
		request.setValue(
			"https://www.vrt.be\(pagePath)",
			forHTTPHeaderField: "Referer"
		)
		request.setValue("WEB", forHTTPHeaderField: "x-vrt-client-name")
		request.setValue("1.5.17", forHTTPHeaderField: "x-vrt-client-version")
		request.setValue("default", forHTTPHeaderField: "x-vrt-zone")
		request.setValue(
			"Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1",
			forHTTPHeaderField: "User-Agent"
		)

		URLSession.shared.dataTask(with: request) { data, response, error in
			guard let data else { return }
			guard
				let json = try? JSONSerialization.jsonObject(with: data)
					as? [String: Any],
				let dataObj = json["data"] as? [String: Any],
				let page = dataObj["page"] as? [String: Any],
				let player = page["player"] as? [String: Any]
			else {
				return
			}

			let title = (player["title"] as? String ?? "")
				.trimmingCharacters(in: .whitespaces)
			let artist = (player["subtitle"] as? String ?? "")
				.trimmingCharacters(in: .whitespaces)

			guard !title.isEmpty,
				!StreamInfo.shared.junkMetadata(title)
			else { return }

			completion(artist, title)
		}.resume()
	}
}

struct DeutschlandfunkProvider: MetadataProvider {
	var pollInterval: TimeInterval? { 15 }

	private enum APIStyle { case nova, kultur }
	private struct APIConfig {
		let url: String
		let style: APIStyle
	}

	private static let streamToConfig: [String: APIConfig] = [
		"st03.sslstream.dlf.de": APIConfig(
			url:
				"https://static.deutschlandfunknova.de/actions/dradio/playlist/onair",
			style: .nova
		),
		"st03.dlf.de": APIConfig(
			url:
				"https://static.deutschlandfunknova.de/actions/dradio/playlist/onair",
			style: .nova
		),
		"/dlf/03/": APIConfig(
			url:
				"https://static.deutschlandfunknova.de/actions/dradio/playlist/onair",
			style: .nova
		),
		"st02.sslstream.dlf.de": APIConfig(
			url: "https://streamtext.dradio.de/drk_utf8.txt",
			style: .kultur
		),
		"st02.dlf.de": APIConfig(
			url: "https://streamtext.dradio.de/drk_utf8.txt",
			style: .kultur
		),
		"/dlf/02/": APIConfig(
			url: "https://streamtext.dradio.de/drk_utf8.txt",
			style: .kultur
		),
	]

	func matches(streamUrl: URL) -> Bool {
		let s = streamUrl.absoluteString
		return Self.streamToConfig.keys.contains(where: { s.contains($0) })
	}

	private func config(from streamUrl: URL) -> APIConfig? {
		let s = streamUrl.absoluteString
		return Self.streamToConfig.first(where: { s.contains($0.key) })?.value
	}

	func poll(streamUrl: URL, completion: @escaping (String, String) -> Void) {
		guard let config = config(from: streamUrl),
			let apiUrl = URL(string: config.url)
		else { return }

		let request = URLRequest.noCacheRequest(url: apiUrl)

		URLSession.shared.dataTask(with: request) { data, _, error in
			guard let data, error == nil else { return }

			switch config.style {
			case .nova:
				self.parseNova(data: data, completion: completion)
			case .kultur:
				self.parseKultur(data: data, completion: completion)
			}
		}.resume()
	}

	private func parseNova(
		data: Data,
		completion: @escaping (String, String) -> Void
	) {
		guard
			let json = try? JSONSerialization.jsonObject(with: data)
				as? [String: Any],
			let item = json["playlistItem"] as? [String: Any],
			(item["type"] as? String) == "Music"
		else { return }

		let title = (item["title"] as? String ?? "")
			.trimmingCharacters(in: .whitespaces)
		let artist = (item["artist"] as? String ?? "")
			.trimmingCharacters(in: .whitespaces)
		guard !title.isEmpty else { return }

		completion(artist, title)
	}

	private func parseKultur(
		data: Data,
		completion: @escaping (String, String) -> Void
	) {
		guard
			let text = String(data: data, encoding: .utf8)?
				.trimmingCharacters(in: .whitespacesAndNewlines)
		else { return }

		let (author, workTitle) = StreamInfo.shared.splitArtistTitle(from: text)
		guard !workTitle.isEmpty else { return }
		completion(author, workTitle)
	}
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

		URLSession.shared.dataTask(with: .noCacheRequest(url: statusUrl)) {
			data,
			_,
			error in
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
	var appIcon: UIImage? {
		appIconImage()
	}
	private var lastKnownArtist: String = ""
	private var lastKnownTitle: String = ""
	private var lastKnownArtwork: UIImage?
	private var lastPolledTitle: String = ""
	private var lastStreamTitle: String = ""
	private var apiMetadataActive = false

	@Published var stations: [RadioStation] = {
		(1...32).map { i in
			let url =
				NSUbiquitousKeyValueStore.default.string(
					forKey: "Stream\(i)Key"
				) ?? ""
			let name =
				NSUbiquitousKeyValueStore.default.string(
					forKey: "StationName\(i)Key"
				) ?? ""
			let favicon =
				NSUbiquitousKeyValueStore.default.string(
					forKey: "StationFavicon\(i)Key"
				) ?? ""
			let idString = NSUbiquitousKeyValueStore.default.string(
				forKey: "StationID\(i)Key"
			)
			let id = idString.flatMap { UUID(uuidString: $0) } ?? UUID()
			return RadioStation(url: url, name: name, faviconUrl: favicon)
		}
	}()

	func moveStation(from source: IndexSet, to destination: Int) {
		stations.move(fromOffsets: source, toOffset: destination)
		stream.move(fromOffsets: source, toOffset: destination)
		for i in 0..<32 {
			NSUbiquitousKeyValueStore.default.set(
				stations[i].id.uuidString,
				forKey: "StationID\(i + 1)Key"
			)
			NSUbiquitousKeyValueStore.default.set(
				stations[i].url,
				forKey: "Stream\(i + 1)Key"
			)
			NSUbiquitousKeyValueStore.default.set(
				stations[i].name,
				forKey: "StationName\(i + 1)Key"
			)
			NSUbiquitousKeyValueStore.default.set(
				stations[i].faviconUrl,
				forKey: "StationFavicon\(i + 1)Key"
			)
		}
		NSUbiquitousKeyValueStore.default.synchronize()
		if isPlaying {
			for i in 0..<32 {
				if stations[i].url == currentStreamUrl?.absoluteString {
					currentStream = i + 1
					break
				}
			}
		}
	}

	func saveStation(_ station: RadioStation, at index: Int) {
		guard index >= 0 && index < 32 else { return }
		let preserved = RadioStation(
			id: stations[index].id,
			url: station.url,
			name: station.name,
			faviconUrl: station.faviconUrl
		)
		stations[index] = preserved
		stream[index] = preserved.url
		NSUbiquitousKeyValueStore.default.set(
			preserved.url,
			forKey: "Stream\(index + 1)Key"
		)
		NSUbiquitousKeyValueStore.default.set(
			preserved.name,
			forKey: "StationName\(index + 1)Key"
		)
		NSUbiquitousKeyValueStore.default.set(
			preserved.faviconUrl,
			forKey: "StationFavicon\(index + 1)Key"
		)
		NSUbiquitousKeyValueStore.default.set(
			preserved.id.uuidString,
			forKey: "StationID\(index + 1)Key"
		)
		NSUbiquitousKeyValueStore.default.synchronize()
	}

	private let metadataProviders: [MetadataProvider] = [
		AudioAddictProvider(),
		StarFMProvider(),
		RTLRadioProvider(),
		SomaFMProvider(),
		BBCRadioProvider(),
		NRKProvider(),
		RadioFranceProvider(),
		ABCRadioProvider(),
		RTERadioProvider(),
		RadioSwissProvider(),
		VirginRadioFranceProvider(),
		VirginRadioRomaniaProvider(),
		VirginRadioOmanProvider(),
		ZenoFMProvider(),
		VRTRadioProvider(),
		DeutschlandfunkProvider(),
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
		var stoppedInfo = [String: Any]()
		stoppedInfo[MPNowPlayingInfoPropertyIsLiveStream] = false
		stoppedInfo[MPNowPlayingInfoPropertyPlaybackRate] = 0.0
		stoppedInfo[MPMediaItemPropertyTitle] = "Stream \(self.currentStream)"
		stoppedInfo[MPMediaItemPropertyArtist] = "Taiga Stream"
		if let icon = appIconImage() {
			let artworkSize = CGSize(width: 600, height: 600)
			let mediaArtwork = MPMediaItemArtwork(boundsSize: artworkSize) {
				requestedSize in
				let renderer = UIGraphicsImageRenderer(size: requestedSize)
				return renderer.image { _ in
					icon.draw(in: CGRect(origin: .zero, size: requestedSize))
				}
			}
			stoppedInfo[MPMediaItemPropertyArtwork] = mediaArtwork
		}
		MPNowPlayingInfoCenter.default().nowPlayingInfo = stoppedInfo
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

		while cleaned.contains("  ") {
			cleaned = cleaned.replacingOccurrences(of: "  ", with: " ")
		}

		return cleaned.trimmingCharacters(in: .whitespaces)
	}

	func junkMetadata(_ value: String) -> Bool {
		let trimmed = value.trimmingCharacters(in: .whitespaces)

		if trimmed.isEmpty { return true }

		if trimmed.range(
			of: #"title="[^"]*",artist=""#,
			options: .regularExpression
		) != nil {
			return true
		}

		if trimmed.contains("song_spot=") { return true }

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

		if trimmed.contains("://") { return true }
		if trimmed.hasPrefix("/") || trimmed.hasSuffix("/") { return true }
		if trimmed.components(separatedBy: "/").count > 2 { return true }

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

					if value.contains("title=") && value.contains("artist=") {
					}

					if value.contains("text=") && value.contains("song_spot=") {
						var parsedTitle = ""
						var parsedArtist = ""

						if let textRange = value.range(
							of: #"text="([^"]*)""#,
							options: .regularExpression
						) {
							let match = String(value[textRange])
							parsedTitle =
								match
								.replacingOccurrences(of: "text=\"", with: "")
								.replacingOccurrences(of: "\"", with: "")
								.trimmingCharacters(in: .whitespaces)
						}

						if let separatorRange = value.range(of: " - text=\"") {
							parsedArtist = String(
								value[..<separatorRange.lowerBound]
							)
							.trimmingCharacters(in: .whitespaces)
						}

						if !parsedTitle.isEmpty {
							title = cleanMetadataString(parsedTitle)
							if !parsedArtist.isEmpty {
								artist = cleanMetadataString(parsedArtist)
							}
							continue
						}
					}

					if value.contains("~") {
						let parts = value.components(separatedBy: "~")
							.map { $0.trimmingCharacters(in: .whitespaces) }
						let parsedArtist =
							parts.count > 0 ? cleanMetadataString(parts[0]) : ""
						let parsedTitle =
							parts.count > 1 ? cleanMetadataString(parts[1]) : ""
						if !parsedArtist.isEmpty && !parsedTitle.isEmpty {
							artist =
								junkMetadata(parsedArtist) ? "" : parsedArtist
							title = junkMetadata(parsedTitle) ? "" : parsedTitle
							continue
						}
					}
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

			var artistFieldTitle = ""
			if artist.contains(" - ") || artist.contains(" – ")
				|| artist.contains(" — ")
			{
				let (parsedArtist, parsedTitle) = splitArtistTitle(from: artist)
				if !parsedArtist.isEmpty && !parsedTitle.isEmpty {
					artist = parsedArtist
					artistFieldTitle = parsedTitle
				}
			} else if let range = artist.range(
				of: #"\s*-\s*"#,
				options: .regularExpression
			) {
				let parsedArtist = cleanMetadataString(
					String(artist[..<range.lowerBound])
				)
				let parsedTitle = cleanMetadataString(
					String(artist[range.upperBound...])
				)
				if !parsedArtist.isEmpty && !parsedTitle.isEmpty {
					artist = parsedArtist
					artistFieldTitle = parsedTitle
				}
			}

			if !artistFieldTitle.isEmpty {
				title = artistFieldTitle
			} else if !artist.isEmpty && !title.isEmpty {
				let separators = [
					" — ", " – ", " - ", " / ", " · ", " | ", "-",
				]
				for separator in separators {
					guard title.contains(separator) else { continue }
					let parts = title.components(separatedBy: separator)
						.map { $0.trimmingCharacters(in: .whitespaces) }
					guard parts.count > 1 else { continue }

					let firstPart = parts[0]
					let secondPart = parts[1]

					if firstPart.caseInsensitiveCompare(artist) == .orderedSame
					{
						let cleaned = cleanMetadataString(secondPart)
						if !cleaned.isEmpty {
							title = cleaned
							break
						}
					} else {
						let cleaned = cleanMetadataString(firstPart)
						if !cleaned.isEmpty {
							title = cleaned
							break
						}
					}
				}
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
		let artworkSize = CGSize(width: 600, height: 600)
		let artwork = MPMediaItemArtwork(boundsSize: artworkSize) {
			requestedSize in
			let renderer = UIGraphicsImageRenderer(size: requestedSize)
			return renderer.image { _ in
				image.draw(in: CGRect(origin: .zero, size: requestedSize))
			}
		}
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
