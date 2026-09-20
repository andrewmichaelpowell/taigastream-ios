//  Taiga Stream (iOS)
//  github.com/andrewmichaelpowell

import Foundation
import SwiftUI

struct FaviconView: View {
	let station: RadioStation
	@State private var favicon: UIImage? = nil
	@State private var faviconIsTransparent = false
	@State private var faviconLoadFailed = false
	@State private var fallbackIcon: UIImage? = nil

	private var isSavedWithoutFavicon: Bool {
		!station.url.isEmpty
			&& (faviconLoadFailed || URL(string: station.faviconUrl) == nil
				|| station.faviconUrl.isEmpty)
	}

	var body: some View {
		Group {
			if let favicon {
				Image(uiImage: favicon)
					.resizable()
					.aspectRatio(contentMode: .fit)
					.scaleEffect(
						faviconIsTransparent
							? StreamInfo.transparentIconInset : 1
					)
					.frame(width: 36, height: 36)
					.background(
						faviconIsTransparent ? Color.white : Color.clear
					)
			} else if isSavedWithoutFavicon,
				let appIcon = StreamInfo.shared.appIcon
			{
				Image(uiImage: appIcon)
					.resizable()
					.aspectRatio(contentMode: .fit)
			} else if let fallbackIcon {
				Image(uiImage: fallbackIcon)
					.resizable()
					.renderingMode(.template)
					.foregroundColor(
						station.url.isEmpty
							? Color(.secondarySystemBackground) : Color(.label)
					)
					.aspectRatio(contentMode: .fit)
			} else {
				Color(.systemBackground)
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

	private func normalizeImage(_ image: UIImage) -> UIImage {
		let renderer = UIGraphicsImageRenderer(size: image.size)
		return renderer.image { _ in
			image.draw(in: CGRect(origin: .zero, size: image.size))
		}
	}

	private func loadFavicon() {
		faviconLoadFailed = false
		guard !station.faviconUrl.isEmpty,
			let url = URL(string: station.faviconUrl)
		else {
			favicon = nil
			faviconIsTransparent = false
			return
		}
		URLSession.shared.dataTask(with: url) { data, _, _ in
			if let data, let image = UIImage(data: data) {
				let normalized = self.normalizeImage(image)
				let isTransparent = StreamInfo.hasTransparency(normalized)
				DispatchQueue.main.async {
					favicon = normalized
					faviconIsTransparent = isTransparent
				}
			} else {
				DispatchQueue.main.async { faviconLoadFailed = true }
			}
		}.resume()
	}
}
