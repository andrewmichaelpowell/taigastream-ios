//  Taiga Stream
//  github.com/andrewmichaelpowell

import Foundation
import SwiftUI

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
						.foregroundColor(Color(.label))
				}
			}
			.frame(width: 36, height: 36)
			.clipShape(RoundedRectangle(cornerRadius: 6))

			VStack(alignment: .leading, spacing: 2) {
				Text(station.name)
					.font(.body)
					.lineLimit(1)
				if !station.state.isEmpty {
					Text(station.state)
						.font(.caption)
						.foregroundColor(Color(.tertiaryLabel))
						.lineLimit(1)
				}
				if !station.country.isEmpty {
					Text(station.country)
						.font(.caption)
						.foregroundColor(Color(.tertiaryLabel))
						.lineLimit(1)
				}
				if !station.tags.isEmpty {
					Text(
						station.tags.components(separatedBy: ",").prefix(2)
							.joined(separator: ", ")
					)
					.font(.caption)
					.foregroundColor(Color(.tertiaryLabel))
					.lineLimit(1)
				}
				if station.bitrate > 0 {
					Text("\(station.bitrate) kbps")
						.font(.caption2)
						.foregroundColor(Color(.tertiaryLabel))
				}
			}
			Spacer()
			Image(systemName: "chevron.right")
				.font(.caption)
				.foregroundColor(Color(.tertiaryLabel))
		}
		.padding(.vertical, 4)
		.onAppear { loadFavicon() }
	}

	private func normalizeImage(_ image: UIImage) -> UIImage {
		let renderer = UIGraphicsImageRenderer(size: image.size)
		return renderer.image { _ in
			image.draw(in: CGRect(origin: .zero, size: image.size))
		}
	}

	private func loadFavicon() {
		guard !station.faviconUrl.isEmpty,
			let url = URL(string: station.faviconUrl)
		else { return }
		URLSession.shared.dataTask(with: url) { data, _, _ in
			if let data, let image = UIImage(data: data) {
				let normalized = self.normalizeImage(image)
				DispatchQueue.main.async { favicon = normalized }
			}
		}.resume()
	}
}
