//  Taiga Stream
//  github.com/andrewmichaelpowell

import Foundation
import AVFoundation

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
