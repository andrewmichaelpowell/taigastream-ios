//  Taiga Stream
//  github.com/andrewmichaelpowell

import Foundation
import SwiftUI

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
					.foregroundColor(
						isConfigured ? Color(.quaternaryLabel) : Color(.label)
					)
					.frame(maxWidth: .infinity, maxHeight: 50)
			}
		}
		.frame(width: 50, height: 50)
		.buttonStyle(.borderedProminent)
		.buttonBorderShape(.circle)
		.tint(isPlaying ? Color(.mint) : Color(.secondarySystemBackground))
	}
}
