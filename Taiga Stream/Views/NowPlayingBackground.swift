//  Taiga Stream (iOS)
//  github.com/andrewmichaelpowell

import Foundation
import SwiftUI

struct NowPlayingBackground: View {
	@ObservedObject private var streamInfo = StreamInfo.shared
	@ObservedObject private var player = PodcastPlayer.shared

	private var artwork: UIImage? {
		guard streamInfo.isPlaying || player.isActive else { return nil }
		return streamInfo.nowPlayingArtwork
	}

	private var contentID: String {
		artwork.map { "artwork-\(ObjectIdentifier($0).hashValue)" } ?? "app"
	}

	var body: some View {
		GeometryReader { geometry in
			ZStack {
				image
					.resizable()
					.aspectRatio(contentMode: .fill)
					.frame(
						width: geometry.size.width,
						height: geometry.size.height
					)
					.clipped()
					.id(contentID)
					.transition(.opacity)
			}
			.animation(.easeInOut(duration: 0.5), value: contentID)
			.blur(radius: 60, opaque: true)
			.overlay(Color(.systemBackground).opacity(0.55))
		}
		.ignoresSafeArea()
	}

	private var image: Image {
		artwork.map { Image(uiImage: $0) } ?? Image("FallbackIcon")
	}
}
