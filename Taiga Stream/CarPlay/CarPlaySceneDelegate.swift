//  Taiga Stream (iOS)
//  github.com/andrewmichaelpowell

import CarPlay
import Combine
import Foundation
import UIKit

class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
	private let streamInfo = StreamInfo.shared
	private var interfaceController: CPInterfaceController?
	private var listTemplate: CPListTemplate?
	private var cancellables = Set<AnyCancellable>()
	private var listImages: [String: UIImage] = [:]
	private var loadingImages = Set<String>()

	func templateApplicationScene(
		_ templateApplicationScene: CPTemplateApplicationScene,
		didConnect interfaceController: CPInterfaceController
	) {
		self.interfaceController = interfaceController
		let template = CPListTemplate(title: "Taiga Stream", sections: [])
		template.emptyViewTitleVariants = [
			String(localized: "No stations")
		]
		listTemplate = template
		updateList()
		interfaceController.setRootTemplate(
			template,
			animated: false,
			completion: nil
		)

		streamInfo.objectWillChange
			.debounce(for: .milliseconds(100), scheduler: RunLoop.main)
			.sink { [weak self] _ in self?.updateList() }
			.store(in: &cancellables)
	}

	func templateApplicationScene(
		_ templateApplicationScene: CPTemplateApplicationScene,
		didDisconnectInterfaceController interfaceController:
			CPInterfaceController
	) {
		cancellables.removeAll()
		listTemplate = nil
		self.interfaceController = nil
	}

	private func updateList() {
		guard let listTemplate else { return }
		let items = streamInfo.stations.enumerated()
			.filter { !$0.element.url.isEmpty }
			.map { index, station in listItem(for: station, number: index + 1) }
		listTemplate.updateSections([CPListSection(items: items)])
	}

	private func listItem(for station: RadioStation, number: Int)
		-> CPListItem
	{
		let item = CPListItem(
			text: streamInfo.fallbackTitle(forSlot: number),
			detailText: String(localized: "Stream \(number)"),
			image: listImage(for: station)
		)
		item.isPlaying = isPlaying(number)
		item.playingIndicatorLocation = .trailing
		item.handler = { [weak self] _, completion in
			guard let self else { return completion() }
			Task { @MainActor in
				if !self.isPlaying(number) {
					await PlayStream.shared.play(streamNumber: number)
				}
				self.showNowPlaying()
				completion()
			}
		}
		return item
	}

	private func isPlaying(_ number: Int) -> Bool {
		streamInfo.isPlaying && streamInfo.currentStream == number
	}

	private func showNowPlaying() {
		guard let interfaceController,
			!(interfaceController.topTemplate is CPNowPlayingTemplate)
		else { return }
		interfaceController.pushTemplate(
			CPNowPlayingTemplate.shared,
			animated: true,
			completion: nil
		)
	}

	private func listImage(for station: RadioStation) -> UIImage? {
		let urlString = station.faviconUrl
			.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !urlString.isEmpty, let url = URL(string: urlString) else {
			return streamInfo.appIcon
		}
		if let image = listImages[urlString] { return image }
		loadImage(url, key: urlString)
		return UIImage(systemName: "antenna.radiowaves.left.and.right")
	}

	private func loadImage(_ url: URL, key: String) {
		guard !loadingImages.contains(key) else { return }
		loadingImages.insert(key)
		Task { @MainActor [weak self] in
			guard let self else { return }
			let data = try? await URLSession.shared.data(from: url).0
			let source = data.flatMap { UIImage(data: $0) }
			self.loadingImages.remove(key)
			self.listImages[key] =
				source.map(Self.composeListImage) ?? self.streamInfo.appIcon
			self.updateList()
		}
	}

	private static func composeListImage(from source: UIImage) -> UIImage {
		let size = CPListItem.maximumImageSize
		let treatment = StreamInfo.faviconTreatment(for: source)
		return UIGraphicsImageRenderer(size: size).image { context in
			let bounds = CGRect(origin: .zero, size: size)
			UIBezierPath(roundedRect: bounds, cornerRadius: size.width / 6)
				.addClip()
			if treatment.needsBackground {
				UIColor.white.setFill()
				context.fill(bounds)
			}
			guard source.size.width > 0, source.size.height > 0 else { return }
			let scale =
				min(
					size.width / source.size.width,
					size.height / source.size.height
				)
				* (treatment.needsInset ? StreamInfo.transparentIconInset : 1)
			let drawSize = CGSize(
				width: source.size.width * scale,
				height: source.size.height * scale
			)
			source.draw(
				in: CGRect(
					x: (size.width - drawSize.width) / 2,
					y: (size.height - drawSize.height) / 2,
					width: drawSize.width,
					height: drawSize.height
				)
			)
		}
	}
}
