//  Taiga Stream
//  github.com/andrewmichaelpowell

import SwiftUI
import AppIntents
import AVFoundation
import Combine
import MediaPlayer
import WidgetKit

public class StreamData: NSObject, ObservableObject
{
	static let shared = StreamData()
	let streamState = UserDefaults(suiteName: "group.xyz.andrewmichaelpowell.taigastream")!
	var playerCancellables = Set<AnyCancellable>()
	var sessionCancellables = Set<AnyCancellable>()
	var metadataCancellable: AnyCancellable?
	var playbackHeartbeat: AnyCancellable?
	
	var currentStream: Int
	{
		get
		{
			streamState.integer(forKey: "CurrentStreamKey")
		}
		set
		{
			streamState.set(newValue, forKey: "CurrentStreamKey")
			streamState.synchronize()
		}
	}
	
	var isPlaying: Bool
	{
		get
		{
			streamState.bool(forKey: "PlayingKey")
		}
		set
		{
			streamState.set(newValue, forKey: "PlayingKey")
			streamState.synchronize()
			objectWillChange.send()
			DispatchQueue.main.async
			{
				ControlCenter.shared.reloadAllControls()
			}
			updatePlaybackState()
		}
	}
	
	@Published var audioPlayer = AVPlayer()
	@Published var streams: [String] = (1...32).map
	{
		NSUbiquitousKeyValueStore.default.string(forKey: "Stream\($0)Key") ?? ""
	}
	
	override init()
	{
		super.init()
		playerObservers()
		sessionObservers()
		setupCommandCenter()
	}
	
	private func setupCommandCenter()
	{
		let commandCenter = MPRemoteCommandCenter.shared()
		commandCenter.playCommand.isEnabled = true
		commandCenter.playCommand.addTarget
		{
			[weak self] _ in
			self?.audioPlayer.play()
			return .success
		}
		
		commandCenter.stopCommand.isEnabled = true
		commandCenter.stopCommand.addTarget
		{
			[weak self] _ in
			self?.audioPlayer.pause()
			try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
			self?.clearNowPlaying()
			return .success
		}
		
		commandCenter.togglePlayPauseCommand.isEnabled = true
		commandCenter.togglePlayPauseCommand.addTarget
		{
			[weak self] _ in
			guard let self = self else
			{
				return .commandFailed
			}
			
			if self.isPlaying
			{
				self.audioPlayer.pause()
				try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
				self.clearNowPlaying()
			}
			else
			{
				self.audioPlayer.play()
			}
			return .success
		}
		commandCenter.pauseCommand.isEnabled = true
		commandCenter.pauseCommand.addTarget
		{
			[weak self] _ in
			guard let self = self else
			{
				return .commandFailed
			}
			
			self.audioPlayer.pause()
			try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
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
	
	func updateNowPlaying(artist: String = "", title: String = "")
	{
		let existingArtwork = MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyArtwork]
		var nowPlayingInfo = [String: Any]()
		nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = true
		nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
		nowPlayingInfo[MPNowPlayingInfoPropertyDefaultPlaybackRate] = 1.0
		nowPlayingInfo[MPMediaItemPropertyArtist] = artist.isEmpty ? "Taiga Stream" : artist
		nowPlayingInfo[MPMediaItemPropertyTitle]  = title.isEmpty  ? "Stream \(currentStream)" : title
		
		if let existingArtwork = existingArtwork
		{
			nowPlayingInfo[MPMediaItemPropertyArtwork] = existingArtwork
		}
		
		MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
	}
	
	private func updatePlaybackState()
	{
		if var nowPlaying = MPNowPlayingInfoCenter.default().nowPlayingInfo
		{
			nowPlaying[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
			MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlaying
		}
		else
		{
			updateNowPlaying()
		}
	}
	
	func clearNowPlaying()
	{
		MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
	}
	
	private var metadataOutput: AVPlayerItemMetadataOutput?
	
	func observeMetadata()
	{
		if let existingOutput = metadataOutput
		{
			audioPlayer.currentItem?.remove(existingOutput)
		}
		
		let output = AVPlayerItemMetadataOutput(identifiers: nil)
		output.setDelegate(self, queue: .main)
		audioPlayer.currentItem?.add(output)
		metadataOutput = output
	}
	
	public typealias metadataApiFetcher = (URL) -> String?
	
	private let metadataApis: [String: String] =
	[
		"bbc_1xtra" : "https://rms.api.bbc.co.uk/v2/services/bbc_1xtra/segments/latest?experience=domestic&offset=0&limit=1",
		"bbc_6music" : "https://rms.api.bbc.co.uk/v2/services/bbc_6music/segments/latest?experience=domestic&offset=0&limit=1",
		"bbc_radio_one" : "https://rms.api.bbc.co.uk/v2/services/bbc_radio_one/segments/latest?experience=domestic&offset=0&limit=1",
		"bbc_radio_two" : "https://rms.api.bbc.co.uk/v2/services/bbc_radio_two/segments/latest?experience=domestic&offset=0&limit=1",
		"bbc_radio_three" : "https://rms.api.bbc.co.uk/v2/services/bbc_radio_three/segments/latest?experience=domestic&offset=0&limit=1",
		"streamguys1.com/live/abccountry" : "https://music.abcradio.net.au/api/v1/plays/country/now.json",
		"streamguys1.com/live/abcjazz" : "https://music.abcradio.net.au/api/v1/plays/jazz/now.json",
		"streamguys1.com/live/classicfmnsw" : "https://music.abcradio.net.au/api/v1/plays/classic/now.json",
		"streamguys1.com/live/classic2" : "https://music.abcradio.net.au/api/v1/plays/classic2/now.json",
		"streamguys1.com/live/doublejnsw" : "https://music.abcradio.net.au/api/v1/plays/doublej/now.json",
		"streamguys1.com/live/triplejnsw" : "https://music.abcradio.net.au/api/v1/plays/triplej/now.json",
		"streamguys1.com/live/triplejhottest" : "https://music.abcradio.net.au/api/v1/plays/h100/now.json",
		"streamguys1.com/live/triplejunearthed" : "https://music.abcradio.net.au/api/v1/plays/unearthed/now.json",
		"streaming.abc-cdn.net.au/audio/hls/abccountry.m3u8" : "https://music.abcradio.net.au/api/v1/plays/country/now.json",
		"streaming.abc-cdn.net.au/audio/hls/abcjazz.m3u8" : "https://music.abcradio.net.au/api/v1/plays/jazz/now.json",
		"streaming.abc-cdn.net.au/audio/hls/classicfmnsw.m3u8" : "https://music.abcradio.net.au/api/v1/plays/classic/now.json",
		"streaming.abc-cdn.net.au/audio/hls/classic2.m3u8" : "https://music.abcradio.net.au/api/v1/plays/classic2/now.json",
		"streaming.abc-cdn.net.au/audio/hls/doublejnsw.m3u8" : "https://music.abcradio.net.au/api/v1/plays/doublej/now.json",
		"streaming.abc-cdn.net.au/audio/hls/triplejnsw.m3u8" : "https://music.abcradio.net.au/api/v1/plays/triplej/now.json",
		"streaming.abc-cdn.net.au/audio/hls/triplejhottest.m3u8" : "https://music.abcradio.net.au/api/v1/plays/h100/now.json",
		"streaming.abc-cdn.net.au/audio/hls/triplejunearthed.m3u8" : "https://music.abcradio.net.au/api/v1/plays/unearthed/now.json",
	]
	
	private var icyPollTimer: AnyCancellable?
	private var lastIcyTitle: String = ""
	
	func startIcyPolling(streamUrl: URL)
	{
		stopIcyPolling()
		lastIcyTitle = ""
		let streamString = streamUrl.absoluteString
		let apiUrlString = metadataApis.first(where: { streamString.contains($0.key) })?.value
		
		if streamString.contains("somafm.com"), let host = streamUrl.host, host.contains("somafm"), !streamUrl.pathComponents.isEmpty
		{
			let mountName = streamUrl.pathComponents
				.first(where: { !$0.isEmpty && $0 != "/" }) ?? ""
			let channel = mountName.components(separatedBy: "-").first ?? ""
			if !channel.isEmpty, let somaApi = URL(string: "https://somafm.com/songs/\(channel).json")
			{
				pollSomaFmMetadata(apiUrl: somaApi)
				icyPollTimer = Timer.publish(every: 15.0, on: .main, in: .common)
					.autoconnect()
					.sink
				{
					[weak self] _ in self?.pollSomaFmMetadata(apiUrl: somaApi)
				}
				return
			}
		}
		
		if let apiUrlString = apiUrlString, let apiUrl = URL(string: apiUrlString)
		{
			if apiUrlString.contains("rms.api.bbc.co.uk")
			{
				pollBbcRadioMetadata(apiUrl: apiUrl)
				icyPollTimer = Timer.publish(every: 15.0, on: .main, in: .common)
					.autoconnect()
					.sink
				{
					[weak self] _ in self?.pollBbcRadioMetadata(apiUrl: apiUrl)
				}
			}
			else if apiUrlString.contains("music.abcradio.net.au")
			{
				pollAbcRadioMetadata(apiUrl: apiUrl)
				icyPollTimer = Timer.publish(every: 15.0, on: .main, in: .common)
					.autoconnect()
					.sink
				{
					[weak self] _ in self?.pollAbcRadioMetadata(apiUrl: apiUrl)
				}
			}
			else if apiUrlString.contains("somafm.com")
			{
				pollSomaFmMetadata(apiUrl: apiUrl)
				icyPollTimer = Timer.publish(every: 15.0, on: .main, in: .common)
					.autoconnect()
					.sink
				{
					[weak self] _ in self?.pollSomaFmMetadata(apiUrl: apiUrl)
				}
			}
		}
		else
		{
			guard var components = URLComponents(url: streamUrl, resolvingAgainstBaseURL: false) else
			{
				return
			}
			components.path = "/status-json.xsl"
			components.query = nil
			components.scheme = "https"
			guard let statusUrl = components.url else
			{
				return
			}
			let mountPath = streamUrl.path
			pollIcyMetadata(statusUrl: statusUrl, mountPath: mountPath)
			icyPollTimer = Timer.publish(every: 15.0, on: .main, in: .common)
				.autoconnect()
				.sink
			{
				[weak self] _ in self?.pollIcyMetadata(statusUrl: statusUrl, mountPath: mountPath)
			}
		}
	}
	
	func stopIcyPolling()
	{
		icyPollTimer = nil
		lastIcyTitle = ""
	}
	
	private func pollAbcRadioMetadata(apiUrl: URL)
	{
		URLSession.shared.dataTask(with: apiUrl)
		{
			[weak self] data, _, error in
			guard let self = self,
				  let data = data,
				  error == nil,
				  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
				  let now = json["now"] as? [String: Any],
				  let recording = now["recording"] as? [String: Any]
			else
			{
				return
			}
			
			let title = (recording["title"] as? String ?? "").trimmingCharacters(in: .whitespaces)
			var artist = ""
			
			if let artists = recording["artists"] as? [[String: Any]]
			{
				artist = artists.compactMap { $0["name"] as? String }.joined(separator: ", ")
			}
			
			let combined = "\(artist)|\(title)"
			guard !title.isEmpty, combined != self.lastIcyTitle else
			{
				return
			}
			self.lastIcyTitle = combined
			let resolvedArtist = artist.isEmpty ? "Taiga Stream" : artist
			let resolvedTitle  = title.isEmpty  ? "Stream \(self.currentStream)" : title
			DispatchQueue.main.async
			{
				self.updateNowPlaying(artist: resolvedArtist, title: resolvedTitle)
				self.fetchArtwork(artist: resolvedArtist, title: resolvedTitle)
			}
		}
		.resume()
	}
	
	private func pollBbcRadioMetadata(apiUrl: URL)
	{
		var request = URLRequest(url: apiUrl)
		request.setValue("application/json", forHTTPHeaderField: "Accept")
		URLSession.shared.dataTask(with: request)
		{
			[weak self] data, _, error in
			guard let self = self,
				  let data = data,
				  error == nil,
				  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
				  let dataArray = json["data"] as? [[String: Any]],
				  let nowPlaying = dataArray.first(where: {($0["offset"] as? [String: Any])?["now_playing"] as? Bool == true}) ?? dataArray.first,
				  let titles = nowPlaying["titles"] as? [String: Any]
			else
			{
				return
			}
			
			let artist = (titles["primary"] as? String ?? "").trimmingCharacters(in: .whitespaces)
			let title  = (titles["secondary"] as? String ?? "").trimmingCharacters(in: .whitespaces)
			let combined = "\(artist)|\(title)"
			guard !title.isEmpty, combined != self.lastIcyTitle else
			{
				return
			}
			
			self.lastIcyTitle = combined
			let resolvedArtist = artist.isEmpty ? "Taiga Stream" : artist
			let resolvedTitle  = title.isEmpty  ? "Stream \(self.currentStream)" : title
			DispatchQueue.main.async
			{
				self.updateNowPlaying(artist: resolvedArtist, title: resolvedTitle)
				self.fetchArtwork(artist: resolvedArtist, title: resolvedTitle)
			}
		}
		.resume()
	}
	
	private func pollSomaFmMetadata(apiUrl: URL)
	{
		URLSession.shared.dataTask(with: apiUrl)
		{
			[weak self] data, _, error in
			guard let self = self,
				  let data = data,
				  error == nil,
				  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
				  let songs = json["songs"] as? [[String: Any]],
				  let first = songs.first
			else
			{
				return
			}
			
			let title  = (first["title"] as? String ?? "").trimmingCharacters(in: .whitespaces)
			let artist = (first["artist"] as? String ?? "").trimmingCharacters(in: .whitespaces)
			let combined = "\(artist)|\(title)"
			guard !title.isEmpty, combined != self.lastIcyTitle else
			{
				return
			}
			
			self.lastIcyTitle = combined
			let resolvedArtist = artist.isEmpty ? "Taiga Stream" : artist
			let resolvedTitle  = title.isEmpty  ? "Stream \(self.currentStream)" : title
			DispatchQueue.main.async
			{
				self.updateNowPlaying(artist: resolvedArtist, title: resolvedTitle)
				self.fetchArtwork(artist: resolvedArtist, title: resolvedTitle)
			}
		}
		.resume()
	}
	
	private func pollIcyMetadata(statusUrl: URL, mountPath: String)
	{
		URLSession.shared.dataTask(with: statusUrl)
		{
			[weak self] data, _, error in
			guard let self = self,
				  let data = data,
				  error == nil,
				  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
				  let iceStats = json["icestats"] as? [String: Any]
			else
			{
				return
			}
			
			var sources: [[String: Any]] = []
			if let array = iceStats["source"] as? [[String: Any]]
			{
				sources = array
			}
			else if let single = iceStats["source"] as? [String: Any]
			{
				sources = [single]
			}
			
			let match = sources.first { ($0["listenurl"] as? String)?.hasSuffix(mountPath) == true } ?? sources.first
			
			guard let source = match,
				  let rawTitle = source["title"] as? String
			else
			{
				return
			}
			
			let title = rawTitle.trimmingCharacters(in: .whitespaces)
			guard !title.isEmpty, title != self.lastIcyTitle else { return }
			self.lastIcyTitle = title
			let parts = title.components(separatedBy: " - ")
			let artist: String
			let songTitle: String
			
			if parts.count >= 2
			{
				artist = self.cleanMetadataString(parts[0].trimmingCharacters(in: .whitespaces))
				songTitle = self.cleanMetadataString(parts.dropFirst().joined(separator: " - ").trimmingCharacters(in: .whitespaces))
			}
			else
			{
				artist = "Taiga Stream"
				songTitle = self.cleanMetadataString(title)
			}
			
			let resolvedArtist = artist.isEmpty ? "Taiga Stream" : artist
			let resolvedTitle  = songTitle.isEmpty ? "Stream \(self.currentStream)" : songTitle
			DispatchQueue.main.async
			{
				self.updateNowPlaying(artist: resolvedArtist, title: resolvedTitle)
				self.fetchArtwork(artist: resolvedArtist, title: resolvedTitle)
			}
		}
		.resume()
	}
	
	private func cleanMetadataString(_ artist: String) -> String
	{
		let isrcPattern = #"\s*-\s*[A-Z][A-Z0-9]{7,11}$"#
		var cleaned = artist
		
		if let range = cleaned.range(of: isrcPattern, options: .regularExpression)
		{
			cleaned = String(cleaned[cleaned.startIndex..<range.lowerBound])
		}
		
		let trailingHyphenPattern = #"\s*-\s*$"#
		
		if let range = cleaned.range(of: trailingHyphenPattern, options: .regularExpression)
		{
			cleaned = String(cleaned[cleaned.startIndex..<range.lowerBound])
		}
		
		let bracketedCodePattern = #"\s*\[[A-Za-z0-9]{3,4}\]\s*$"#
		
		if let range = cleaned.range(of: bracketedCodePattern, options: .regularExpression)
		{
			cleaned = String(cleaned[cleaned.startIndex..<range.lowerBound])
		}
		
		return cleaned.trimmingCharacters(in: .whitespaces)
	}
	
	private func junkMetadata(_ value: String) -> Bool
	{
		let trimmedValue = value.trimmingCharacters(in: .whitespaces)
		if trimmedValue.isEmpty
		{
			return true
		}
		
		let stationIdPattern = #"^zc\d+$"#
		if trimmedValue.range(of: stationIdPattern, options: [.regularExpression, .caseInsensitive]) != nil
		{
			return true
		}
		
		let technicalIdPattern = #"^[a-z0-9]*_[a-z0-9_]+$"#
		if trimmedValue.range(of: technicalIdPattern, options: [.regularExpression, .caseInsensitive]) != nil
		{
			return true
		}
		
		if trimmedValue.contains("/") || trimmedValue.contains("://")
		{
			return true
		}
		
		let adMarkerPattern = #"(?i)(spot\s+block|ad\s+break|commercial\s+break)"#
		
		if trimmedValue.range(of: adMarkerPattern, options: .regularExpression) != nil
		{
			return true
		}
		
		let xmlAttributePattern = #"\w+\s*=\s*""#
		
		if trimmedValue.range(of: xmlAttributePattern, options: .regularExpression) != nil
		{
			return true
		}
		
		return false
	}
	
	private func parseMetadata(_ metadataItems: [AVMetadataItem])
	{
		Task
		{
			var artist = ""
			var title = ""
			for item in metadataItems
			{
				if item.commonKey == .commonKeyArtist,
				   let value = try? await item.load(.stringValue)
				{
					let cleaned = cleanMetadataString(value)
					artist = junkMetadata(cleaned) ? "" : cleaned
				}
				
				else if item.commonKey == .commonKeyTitle, let value = try? await item.load(.stringValue)
				{
					let parts = value.components(separatedBy: " - ")
					let isrcPattern = #"^[A-Z][A-Z0-9]{7,11}$"#
					let lastPart = parts.last?.trimmingCharacters(in: .whitespaces) ?? ""
					let lastIsIsrc = lastPart.range(of: isrcPattern, options: .regularExpression) != nil
					let lastIsEmpty = lastPart.isEmpty
					
					if lastIsIsrc || lastIsEmpty
					{
						let cleanParts = parts.dropLast().map
						{
							$0.trimmingCharacters(in: .whitespaces)
						}
						title = cleanMetadataString(cleanParts.first ?? "")
						artist = cleanMetadataString(cleanParts.dropFirst().joined(separator: " - "))
					}
					
					else if parts.count >= 2
					{
						artist = cleanMetadataString(parts[0].trimmingCharacters(in: .whitespaces))
						title = cleanMetadataString(parts.dropFirst().joined(separator: " - ").trimmingCharacters(in: .whitespaces))
					}
					
					else
					{
						title = cleanMetadataString(value)
					}
				}
				
				if junkMetadata(title)
				{
					title = ""
				}
				
				if junkMetadata(artist)
				{
					artist = ""
				}
			}
			
			let resolvedArtist = artist.isEmpty ? "Taiga Stream" : artist
			let resolvedTitle  = title.isEmpty  ? "Stream \(currentStream)" : title
			
			await MainActor.run
			{
				updateNowPlaying(artist: resolvedArtist, title: resolvedTitle)
				fetchArtwork(artist: resolvedArtist, title: resolvedTitle)
			}
		}
	}
	
	var isFallbackArtworkSet = false
	
	private func fetchArtwork(artist: String, title: String)
	{
		guard artist != "Taiga Stream" || title != "Stream \(currentStream)" else
		{
			if !isFallbackArtworkSet
			{
				setFallbackArtwork()
				isFallbackArtworkSet = true
			}
			
			return
		}
		
		isFallbackArtworkSet = false
		let nowPlayingQuery = "\(artist) \(title)"
			.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
		let urlString = "https://itunes.apple.com/search?term=\(nowPlayingQuery)&entity=song&limit=1"
		
		guard let searchUrl = URL(string: urlString) else
		{
			setFallbackArtwork()
			return
		}
		
		URLSession.shared.dataTask(with: searchUrl)
		{
			[weak self] data, _, error in
			guard let self = self,
				  let data = data,
				  error == nil,
				  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
				  let results = json["results"] as? [[String: Any]],
				  let firstResult = results.first,
				  let artworkString = firstResult["artworkUrl100"] as? String
			else
			{
				DispatchQueue.main.async
				{
					self?.setFallbackArtwork()
				}
				return
			}
			
			let highResArtworkString = artworkString.replacingOccurrences(of: "100x100bb", with: "600x600bb")
			guard let artworkUrl = URL(string: highResArtworkString) else
			{
				DispatchQueue.main.async
				{
					self.setFallbackArtwork()
				}
				return
			}
			
			URLSession.shared.dataTask(with: artworkUrl)
			{
				[weak self] imageData, _, imageError in
				guard let self = self,
					  let imageData = imageData,
					  imageError == nil,
					  let artworkImage = UIImage(data: imageData)
				else
				{
					DispatchQueue.main.async
					{
						self?.setFallbackArtwork()
					}
					return
				}
				
				DispatchQueue.main.async
				{
					self.applyArtwork(artworkImage)
				}
			}
			.resume()
		}
		.resume()
	}
	
	private func applyArtwork(_ Image: UIImage)
	{
		let artwork = MPMediaItemArtwork(boundsSize: Image.size)
		{
			_ in Image
		}
		
		if var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
		{
			nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
			MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
		}
	}
	
	func setFallbackArtwork()
	{
		let appIcon = appIconImage() ?? UIImage(systemName: "radio")
		guard let icon = appIcon else
		{
			return
		}
		applyArtwork(icon)
	}
	
	private func appIconImage() -> UIImage?
	{
		guard
			let icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
			let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
			let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
			let lastIcon = iconFiles.last
		else
		{
			return nil
		}
		return UIImage(named: lastIcon)
	}
	
	private func playerObservers()
	{
		playerCancellables.removeAll()
		
		audioPlayer.publisher(for: \.timeControlStatus)
			.receive(on: DispatchQueue.main)
			.sink
		{
			[weak self] streamStatus in
			if streamStatus == .paused
			{
				self?.isPlaying = false
			}
			else if streamStatus == .playing
			{
				self?.isPlaying = true
			}
		}
		.store(in: &playerCancellables)
		
		audioPlayer.publisher(for: \.currentItem?.status)
			.receive(on: DispatchQueue.main)
			.sink
		{
			[weak self] streamStatus in
			if streamStatus == .failed
			{
				self?.isPlaying = false
			}
		}
		.store(in: &playerCancellables)
		
		NotificationCenter.default.publisher(for: .AVPlayerItemFailedToPlayToEndTime)
			.receive(on: DispatchQueue.main)
			.sink
		{
			[weak self] _ in self?.isPlaying = false
		}
		.store(in: &playerCancellables)
		
		NotificationCenter.default.publisher(for: .AVPlayerItemPlaybackStalled)
			.receive(on: DispatchQueue.main)
			.sink
		{
			[weak self] _ in self?.isPlaying = false
		}
		.store(in: &playerCancellables)
	}
	
	private func sessionObservers()
	{
		sessionCancellables.removeAll()
		
		NotificationCenter.default.publisher(for: AVAudioSession.interruptionNotification)
			.receive(on: DispatchQueue.main)
			.sink
		{
			[weak self] streamNotification in
			guard let streamUserInfo = streamNotification.userInfo,
				  let streamTypeValue = streamUserInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
				  let streamType = AVAudioSession.InterruptionType(rawValue: streamTypeValue) else
			{
				return
			}
			if streamType == .began
			{
				self?.isPlaying = false
				self?.audioPlayer.pause()
			}
		}
		.store(in: &sessionCancellables)
		
		NotificationCenter.default.publisher(for: AVAudioSession.silenceSecondaryAudioHintNotification)
			.receive(on: DispatchQueue.main)
			.sink
		{
			[weak self] streamNotification in
			guard let streamUserInfo = streamNotification.userInfo,
				  let streamTypeValue = streamUserInfo[AVAudioSessionSilenceSecondaryAudioHintTypeKey] as? UInt,
				  let streamType = AVAudioSession.SilenceSecondaryAudioHintType(rawValue: streamTypeValue) else
			{
				return
			}
			if streamType == .begin
			{
				self?.isPlaying = false
				self?.audioPlayer.pause()
			}
		}
		.store(in: &sessionCancellables)
		
		NotificationCenter.default.publisher(for: AVAudioSession.routeChangeNotification)
			.receive(on: DispatchQueue.main)
			.sink
		{
			[weak self] streamNotification in
			guard let streamUserInfo = streamNotification.userInfo,
				  let streamTypeValue = streamUserInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
				  let streamType = AVAudioSession.RouteChangeReason(rawValue: streamTypeValue) else
			{
				return
			}
			if streamType == .categoryChange
			{
				if AVAudioSession.sharedInstance().secondaryAudioShouldBeSilencedHint
				{
					self?.isPlaying = false
					self?.audioPlayer.pause()
				}
			}
		}
		.store(in: &sessionCancellables)
		
		NotificationCenter.default.publisher(for: AVAudioSession.mediaServicesWereLostNotification)
			.sink
		{
			[weak self] _ in
			self?.isPlaying = false
			self?.audioPlayer.pause()
		}
		.store(in: &sessionCancellables)
		
		NotificationCenter.default.publisher(for: AVAudioSession.mediaServicesWereResetNotification)
			.sink
		{
			[weak self] _ in
			self?.isPlaying = false
			self?.audioPlayer.pause()
		}
		.store(in: &sessionCancellables)
	}
	
	func startPlaybackHeartbeat()
	{
		playbackHeartbeat = Timer.publish(every: 1.0, on: .main, in: .common)
			.autoconnect()
			.sink
		{
			[weak self] _ in
			guard let self = self else
			{
				return
			}
			let actuallyPlaying = self.audioPlayer.timeControlStatus == .playing
			if !actuallyPlaying && self.isPlaying
			{
				self.isPlaying = false
			}
		}
	}
	
	func stopPlaybackHeartbeat()
	{
		playbackHeartbeat = nil
	}
}

extension StreamData: AVPlayerItemMetadataOutputPushDelegate
{
	public func metadataOutput(
		_ output: AVPlayerItemMetadataOutput,
		didOutputTimedMetadataGroups groups: [AVTimedMetadataGroup],
		from track: AVPlayerItemTrack?)
	{
		let metadataItems = groups.flatMap
		{
			$0.items
		}
		parseMetadata(metadataItems)
	}
}

class PlayStream
{
	static let shared = PlayStream()
	
	private func startStream(_ streamUrl: URL, streamNumber: Int)
	{
		let newStreamItem = AVPlayerItem(url: streamUrl)
		let data = StreamData.shared
		
		try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
		try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
		try? AVAudioSession.sharedInstance().setActive(true)
		
		data.audioPlayer.replaceCurrentItem(with: newStreamItem)
		data.audioPlayer.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
		data.currentStream = streamNumber
		data.isFallbackArtworkSet = false
		data.updateNowPlaying(title: "Stream \(streamNumber)")
		data.setFallbackArtwork()
		data.isFallbackArtworkSet = true
		data.observeMetadata()
		data.audioPlayer.play()
		data.startPlaybackHeartbeat()
		data.startIcyPolling(streamUrl: streamUrl)
	}
	
	private func playButtonAction(streamUrl: URL, streamNumber: Int)
	{
		let data = StreamData.shared
		if data.isPlaying && data.currentStream == streamNumber
		{
			data.audioPlayer.pause()
			data.stopPlaybackHeartbeat()
			data.stopIcyPolling()
			try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
			data.clearNowPlaying()
		}
		else
		{
			try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
			startStream(streamUrl, streamNumber: streamNumber)
		}
	}
	
	public func play(streamNumber: Int)
	{
		guard let url = URL(string: StreamData.shared.streams[streamNumber - 1]) else
		{
			return
		}
		playButtonAction(streamUrl: url, streamNumber: streamNumber)
	}
}

private func makeStreamControl(streamNumber: Int) -> some ControlWidgetConfiguration
{
	let kind = "xyz.andrewmichaelpowell.taigastream.stream\(streamNumber)"
	return StaticControlConfiguration(kind: kind)
	{
		let streamState = UserDefaults(suiteName: "group.xyz.andrewmichaelpowell.taigastream")
		let streamStatus = (streamState?.bool(forKey: "PlayingKey") ?? false)
		&& (streamState?.integer(forKey: "CurrentStreamKey") ?? 0) == streamNumber
		return ControlWidgetToggle(isOn: streamStatus, action: PlayStreamToggleIntent(streamNumber: streamNumber))
		{
			Label("Stream \(streamNumber)", systemImage: "\(streamNumber).circle")
		}
	}
	.displayName("Stream \(streamNumber)")
}



struct PlayStreamToggleIntent: SetValueIntent, AudioPlaybackIntent
{
	static let title: LocalizedStringResource = "Play Stream"
	@Parameter(title: "Stream Number") var streamNumber: Int
	@Parameter(title: "Stream Status") var value: Bool
	
	init(streamNumber: Int)
	{
		self.streamNumber = streamNumber
	}
	
	init()
	{
		self.streamNumber = 1
	}
	
	@MainActor func perform() async throws -> some IntentResult
	{
		PlayStream.shared.play(streamNumber: streamNumber)
		return .result()
	}
}

struct WidgetControl1: ControlWidget
{
	var body: some ControlWidgetConfiguration
	{
		makeStreamControl(streamNumber: 1)
	}
}

struct WidgetControl2: ControlWidget
{
	var body: some ControlWidgetConfiguration
	{
		makeStreamControl(streamNumber: 2)
	}
}

struct WidgetControl3: ControlWidget
{
	var body: some ControlWidgetConfiguration
	{
		makeStreamControl(streamNumber: 3)
	}
}

struct WidgetControl4: ControlWidget
{
	var body: some ControlWidgetConfiguration
	{
		makeStreamControl(streamNumber: 4)
	}
}

struct WidgetControl5: ControlWidget
{
	var body: some ControlWidgetConfiguration
	{
		makeStreamControl(streamNumber: 5)
	}
}

struct WidgetControl6: ControlWidget
{
	var body: some ControlWidgetConfiguration
	{
		makeStreamControl(streamNumber: 6)
	}
}

struct WidgetControl7: ControlWidget
{
	var body: some ControlWidgetConfiguration
	{
		makeStreamControl(streamNumber: 7)
	}
}

struct WidgetControl8: ControlWidget
{
	var body: some ControlWidgetConfiguration
	{
		makeStreamControl(streamNumber: 8)
	}
}

struct WidgetControl9: ControlWidget
{
	var body: some ControlWidgetConfiguration
	{
		makeStreamControl(streamNumber: 9)
	}
}

struct WidgetControl10: ControlWidget
{
	var body: some ControlWidgetConfiguration
	{
		makeStreamControl(streamNumber: 10)
	}
}

struct WidgetControl11: ControlWidget
{
	var body: some ControlWidgetConfiguration
	{
		makeStreamControl(streamNumber: 11)
	}
}

struct WidgetControl12: ControlWidget
{
	var body: some ControlWidgetConfiguration
	{
		makeStreamControl(streamNumber: 12)
	}
}

struct WidgetControl13: ControlWidget
{
	var body: some ControlWidgetConfiguration
	{
		makeStreamControl(streamNumber: 13)
	}
}

struct WidgetControl14: ControlWidget
{
	var body: some ControlWidgetConfiguration
	{
		makeStreamControl(streamNumber: 14)
	}
}

struct WidgetControl15: ControlWidget
{
	var body: some ControlWidgetConfiguration
	{
		makeStreamControl(streamNumber: 15)
	}
}

struct WidgetControl16: ControlWidget
{
	var body: some ControlWidgetConfiguration
	{
		makeStreamControl(streamNumber: 16)
	}
}

struct WidgetControl17: ControlWidget
{
	var body: some ControlWidgetConfiguration
	{
		makeStreamControl(streamNumber: 17)
	}
}

struct WidgetControl18: ControlWidget
{
	var body: some ControlWidgetConfiguration
	{
		makeStreamControl(streamNumber: 18)
	}
}

struct WidgetControl19: ControlWidget
{
	var body: some ControlWidgetConfiguration
	{
		makeStreamControl(streamNumber: 19)
	}
}

struct WidgetControl20: ControlWidget
{
	var body: some ControlWidgetConfiguration
	{
		makeStreamControl(streamNumber: 20)
	}
}

struct WidgetControl21: ControlWidget
{
	var body: some ControlWidgetConfiguration
	{
		makeStreamControl(streamNumber: 21)
	}
}

struct WidgetControl22: ControlWidget
{
	var body: some ControlWidgetConfiguration
	{
		makeStreamControl(streamNumber: 22)
	}
}

struct WidgetControl23: ControlWidget
{
	var body: some ControlWidgetConfiguration
	{
		makeStreamControl(streamNumber: 23)
	}
}

struct WidgetControl24: ControlWidget
{
	var body: some ControlWidgetConfiguration
	{
		makeStreamControl(streamNumber: 24)
	}
}

struct WidgetControl25: ControlWidget
{
	var body: some ControlWidgetConfiguration
	{
		makeStreamControl(streamNumber: 25)
	}
}

struct WidgetControl26: ControlWidget
{
	var body: some ControlWidgetConfiguration
	{
		makeStreamControl(streamNumber: 26)
	}
}

struct WidgetControl27: ControlWidget
{
	var body: some ControlWidgetConfiguration
	{
		makeStreamControl(streamNumber: 27)
	}
}

struct WidgetControl28: ControlWidget
{
	var body: some ControlWidgetConfiguration
	{
		makeStreamControl(streamNumber: 28)
	}
}

struct WidgetControl29: ControlWidget
{
	var body: some ControlWidgetConfiguration
	{
		makeStreamControl(streamNumber: 29)
	}
}

struct WidgetControl30: ControlWidget
{
	var body: some ControlWidgetConfiguration
	{
		makeStreamControl(streamNumber: 30)
	}
}

struct WidgetControl31: ControlWidget
{
	var body: some ControlWidgetConfiguration
	{
		makeStreamControl(streamNumber: 31)
	}
}

struct WidgetControl32: ControlWidget
{
	var body: some ControlWidgetConfiguration
	{
		makeStreamControl(streamNumber: 32)
	}
}
