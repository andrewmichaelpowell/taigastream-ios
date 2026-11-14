//  Taiga Stream (iOS)
//  github.com/andrewmichaelpowell

import CarPlay
import Combine
import Foundation
import UIKit

class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate,
	CPNowPlayingTemplateObserver
{
	private let streamInfo = StreamInfo.shared
	private let library = PodcastLibrary.shared
	private let player = PodcastPlayer.shared
	private var interfaceController: CPInterfaceController?
	private var radioTemplate: CPListTemplate?
	private var podcastTemplate: CPListTemplate?
	private weak var episodesTemplate: CPListTemplate?
	private var cancellables = Set<AnyCancellable>()
	private var listImages: [String: UIImage] = [:]
	private var loadingImages = Set<String>()

	func templateApplicationScene(
		_ templateApplicationScene: CPTemplateApplicationScene,
		didConnect interfaceController: CPInterfaceController
	) {
		self.interfaceController = interfaceController

		let radio = CPListTemplate(
			title: String(localized: "Radio"),
			sections: []
		)
		radio.tabTitle = String(localized: "Radio")
		radio.tabImage = UIImage(systemName: "radio")
		radio.emptyViewTitleVariants = [String(localized: "No stations")]
		radioTemplate = radio

		let podcasts = CPListTemplate(
			title: String(localized: "Podcasts"),
			sections: []
		)
		podcasts.tabTitle = String(localized: "Podcasts")
		podcasts.tabImage = UIImage(systemName: "mic")
		podcasts.emptyViewTitleVariants = [String(localized: "No podcasts")]
		podcastTemplate = podcasts

		updateLists()
		interfaceController.setRootTemplate(
			CPTabBarTemplate(templates: [radio, podcasts]),
			animated: false,
			completion: nil
		)

		CPNowPlayingTemplate.shared.add(self)
		if #available(iOS 27.0, *) {
			CPNowPlayingTemplate.shared.allowsMiniPlayer = false
		}
		updateNowPlayingButtons()

		Publishers.Merge4(
			streamInfo.objectWillChange.map { _ in () },
			library.objectWillChange.map { _ in () },
			player.$activePodcastID.map { _ in () },
			player.$activeEpisode.map { _ in () }
		)
		.debounce(for: .milliseconds(100), scheduler: RunLoop.main)
		.sink { [weak self] _ in
			self?.updateLists()
			self?.updateNowPlayingButtons()
		}
		.store(in: &cancellables)
	}

	func templateApplicationScene(
		_ templateApplicationScene: CPTemplateApplicationScene,
		didDisconnectInterfaceController interfaceController:
			CPInterfaceController
	) {
		CPNowPlayingTemplate.shared.remove(self)
		cancellables.removeAll()
		radioTemplate = nil
		podcastTemplate = nil
		self.interfaceController = nil
	}

	private func updateLists() {
		updateRadioList()
		updatePodcastList()
		if let episodesTemplate, let id = player.activePodcastID {
			episodesTemplate.updateSections([episodeSection(podcastID: id)])
		}
	}

	private func updateRadioList() {
		guard let radioTemplate else { return }
		let items = streamInfo.stations.enumerated()
			.filter { !$0.element.url.isEmpty }
			.map { index, station in
				stationItem(for: station, number: index + 1)
			}
		radioTemplate.updateSections([CPListSection(items: items)])
	}

	private func stationItem(for station: RadioStation, number: Int)
		-> CPListItem
	{
		let item = CPListItem(
			text: streamInfo.fallbackTitle(forSlot: number),
			detailText: String(localized: "Stream \(number)"),
			image: listImage(
				urlString: station.faviconUrl,
				fallbackSymbol: "antenna.radiowaves.left.and.right"
			)
		)
		item.isPlaying = isStationPlaying(number)
		item.playingIndicatorLocation = .trailing
		item.handler = { [weak self] _, completion in
			guard let self else { return completion() }
			Task { @MainActor in
				if !self.isStationPlaying(number) {
					await PlayStream.shared.play(streamNumber: number)
				}
				self.showNowPlaying()
				completion()
			}
		}
		return item
	}

	private func isStationPlaying(_ number: Int) -> Bool {
		streamInfo.isPlaying && streamInfo.currentStream == number
	}

	private func updatePodcastList() {
		guard let podcastTemplate else { return }
		let items = library.podcasts.enumerated().map { index, podcast in
			podcastItem(for: podcast, number: index + 1)
		}
		podcastTemplate.updateSections([CPListSection(items: items)])
	}

	private func podcastItem(for podcast: Podcast, number: Int) -> CPListItem {
		let name = podcast.name.trimmingCharacters(in: .whitespaces)
		let episode = library.currentEpisode(for: podcast)
		let item = CPListItem(
			text: name.isEmpty ? String(localized: "Podcast \(number)") : name,
			detailText: episode?.title,
			image: listImage(
				urlString: podcast.artworkUrl,
				fallbackSymbol: "mic"
			)
		)
		item.isPlaying = player.isPlaying(podcastID: podcast.id)
		item.playingIndicatorLocation = .trailing
		item.handler = { [weak self] _, completion in
			guard let self else { return completion() }
			Task { @MainActor in
				if !self.player.isPlaying(podcastID: podcast.id) {
					await self.player.play(podcastNumber: number)
				}
				self.showNowPlaying()
				completion()
			}
		}
		return item
	}

	private func updateNowPlayingButtons() {
		let nowPlaying = CPNowPlayingTemplate.shared
		let title = player.isActive ? String(localized: "Episodes") : ""
		if nowPlaying.upNextTitle != title { nowPlaying.upNextTitle = title }
		if nowPlaying.isUpNextButtonEnabled != player.isActive {
			nowPlaying.isUpNextButtonEnabled = player.isActive
		}
	}

	func nowPlayingTemplateUpNextButtonTapped(
		_ nowPlayingTemplate: CPNowPlayingTemplate
	) {
		guard let id = player.activePodcastID,
			let podcast = library.podcast(id: id)
		else { return }
		let template = CPListTemplate(
			title: podcast.name.isEmpty
				? String(localized: "Episodes") : podcast.name,
			sections: [episodeSection(podcastID: id)]
		)
		template.emptyViewTitleVariants = [String(localized: "No episodes")]
		episodesTemplate = template
		interfaceController?.pushTemplate(
			template,
			animated: true,
			completion: nil
		)
		if library.feeds[id] == nil {
			Task { @MainActor in
				await library.refreshFeed(for: podcast)
				template.updateSections([episodeSection(podcastID: id)])
			}
		}
	}

	private func episodeSection(podcastID: UUID) -> CPListSection {
		guard let podcast = library.podcast(id: podcastID) else {
			return CPListSection(items: [])
		}
		let currentID = library.currentEpisode(for: podcast)?.id
		let episodes = library.feeds[podcastID]?.episodes ?? []
		let items = episodes.map { episode in
			let position = library.savedPosition(
				podcastID: podcastID,
				episode: episode
			)
			let detail = [
				PodcastFormat.date(episode.publishedAt),
				PodcastFormat.remaining(
					position: position,
					duration: episode.duration
				) ?? episode.duration.map { PodcastFormat.duration($0) },
			].compactMap { $0 }.joined(separator: " · ")
			let item = CPListItem(
				text: episode.title.isEmpty ? episode.audioUrl : episode.title,
				detailText: detail
			)
			item.isPlaying = episode.id == currentID
			item.playingIndicatorLocation = .leading
			if let progress = library.progress(
				podcastID: podcastID,
				episode: episode
			) {
				item.playbackProgress = progress
			}
			item.handler = { [weak self] _, completion in
				guard let self else { return completion() }
				Task { @MainActor in
					self.library.selectEpisode(episode, for: podcast)
					await self.player.play(episode, of: podcast)
					self.interfaceController?.popTemplate(
						animated: true,
						completion: nil
					)
					completion()
				}
			}
			return item
		}
		return CPListSection(items: items)
	}

	private func showNowPlaying() {
		updateNowPlayingButtons()
		guard let interfaceController,
			!(interfaceController.topTemplate is CPNowPlayingTemplate)
		else { return }
		interfaceController.pushTemplate(
			CPNowPlayingTemplate.shared,
			animated: true,
			completion: nil
		)
	}

	private func listImage(urlString: String, fallbackSymbol: String)
		-> UIImage?
	{
		let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !trimmed.isEmpty, let url = URL(string: trimmed) else {
			return streamInfo.appIcon
		}
		if let image = listImages[trimmed] { return image }
		loadImage(url, key: trimmed)
		return UIImage(systemName: fallbackSymbol)
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
			self.updateLists()
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
