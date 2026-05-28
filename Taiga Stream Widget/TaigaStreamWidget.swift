//  Taiga Stream
//  github.com/andrewmichaelpowell

import SwiftUI
import AppIntents
import AVKit
import AVFoundation
import Combine
import MediaPlayer
import WidgetKit

public class PlayStreamData: NSObject, ObservableObject
{
    static let SharedResource = PlayStreamData()
    let StreamState = UserDefaults(suiteName: "group.xyz.andrewmichaelpowell.taigastream")!
    var PlayerCancellables = Set<AnyCancellable>()
    var SessionCancellables = Set<AnyCancellable>()
    var MetadataCancellable: AnyCancellable?
    var PlaybackHeartbeat: AnyCancellable?
    
    var CurrentStream: Int
    {
        get
        {
            StreamState.integer(forKey: "CurrentStreamKey")
        }
        set
        {
            StreamState.set(newValue, forKey: "CurrentStreamKey")
            StreamState.synchronize()
        }
    }
    
    var Playing: Bool
    {
        get
        {
            StreamState.bool(forKey: "PlayingKey")
        }
        set
        {
            StreamState.set(newValue, forKey: "PlayingKey")
            StreamState.synchronize()
            objectWillChange.send()
            DispatchQueue.main.async
            {
                ControlCenter.shared.reloadAllControls()
            }
            UpdateNowPlayingPlaybackState()
        }
    }
    
    @Published var PlayStream = AVPlayer()
    @Published var Stream1:String = NSUbiquitousKeyValueStore.default.string(forKey: "Stream1Key") ?? ""
    @Published var Stream2:String = NSUbiquitousKeyValueStore.default.string(forKey: "Stream2Key") ?? ""
    @Published var Stream3:String = NSUbiquitousKeyValueStore.default.string(forKey: "Stream3Key") ?? ""
    @Published var Stream4:String = NSUbiquitousKeyValueStore.default.string(forKey: "Stream4Key") ?? ""
    @Published var Stream5:String = NSUbiquitousKeyValueStore.default.string(forKey: "Stream5Key") ?? ""
    @Published var Stream6:String = NSUbiquitousKeyValueStore.default.string(forKey: "Stream6Key") ?? ""
    @Published var Stream7:String = NSUbiquitousKeyValueStore.default.string(forKey: "Stream7Key") ?? ""
    @Published var Stream8:String = NSUbiquitousKeyValueStore.default.string(forKey: "Stream8Key") ?? ""
    @Published var Stream9:String = NSUbiquitousKeyValueStore.default.string(forKey: "Stream9Key") ?? ""
    @Published var Stream10:String = NSUbiquitousKeyValueStore.default.string(forKey: "Stream10Key") ?? ""
    @Published var Stream11:String = NSUbiquitousKeyValueStore.default.string(forKey: "Stream11Key") ?? ""
    @Published var Stream12:String = NSUbiquitousKeyValueStore.default.string(forKey: "Stream12Key") ?? ""
    @Published var Stream13:String = NSUbiquitousKeyValueStore.default.string(forKey: "Stream13Key") ?? ""
    @Published var Stream14:String = NSUbiquitousKeyValueStore.default.string(forKey: "Stream14Key") ?? ""
    @Published var Stream15:String = NSUbiquitousKeyValueStore.default.string(forKey: "Stream15Key") ?? ""
    @Published var Stream16:String = NSUbiquitousKeyValueStore.default.string(forKey: "Stream16Key") ?? ""
    @Published var Stream17:String = NSUbiquitousKeyValueStore.default.string(forKey: "Stream17Key") ?? ""
    @Published var Stream18:String = NSUbiquitousKeyValueStore.default.string(forKey: "Stream18Key") ?? ""
    @Published var Stream19:String = NSUbiquitousKeyValueStore.default.string(forKey: "Stream19Key") ?? ""
    @Published var Stream20:String = NSUbiquitousKeyValueStore.default.string(forKey: "Stream20Key") ?? ""
    @Published var Stream21:String = NSUbiquitousKeyValueStore.default.string(forKey: "Stream21Key") ?? ""
    @Published var Stream22:String = NSUbiquitousKeyValueStore.default.string(forKey: "Stream22Key") ?? ""
    @Published var Stream23:String = NSUbiquitousKeyValueStore.default.string(forKey: "Stream23Key") ?? ""
    @Published var Stream24:String = NSUbiquitousKeyValueStore.default.string(forKey: "Stream24Key") ?? ""
    
    override init()
    {
        super.init()
        PlayerObservers()
        SessionObservers()
        SetupRemoteCommandCenter()
    }
    
    public func SetupRemoteCommandCenter()
    {
        let CommandCenter = MPRemoteCommandCenter.shared()
        CommandCenter.playCommand.isEnabled = true
        CommandCenter.playCommand.addTarget
        {
            [weak self] _ in
            self?.PlayStream.play()
            return .success
        }
        
        CommandCenter.stopCommand.isEnabled = true
        CommandCenter.stopCommand.addTarget
        {
            [weak self] _ in
            self?.PlayStream.pause()
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            return .success
        }
        
        CommandCenter.togglePlayPauseCommand.isEnabled = true
        CommandCenter.togglePlayPauseCommand.addTarget
        {
            [weak self] _ in
            guard let self = self else
            {
                return .commandFailed
            }
            
            if self.Playing
            {
                self.PlayStream.pause()
                try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            }
            else
            {
                self.PlayStream.play()
            }
            return .success
        }
        CommandCenter.pauseCommand.isEnabled = false
        CommandCenter.skipForwardCommand.isEnabled = false
        CommandCenter.skipForwardCommand.preferredIntervals = []
        CommandCenter.skipBackwardCommand.isEnabled = false
        CommandCenter.skipBackwardCommand.preferredIntervals = []
        CommandCenter.nextTrackCommand.isEnabled = false
        CommandCenter.previousTrackCommand.isEnabled = false
        CommandCenter.changePlaybackPositionCommand.isEnabled = false
    }
    
    public func UpdateNowPlayingInfo(artist: String = "", title: String = "")
    {
        let ExistingArtwork = MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyArtwork]
        var NowPlayingInfo = [String: Any]()
        NowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = true
        NowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = Playing ? 1.0 : 0.0
        NowPlayingInfo[MPNowPlayingInfoPropertyDefaultPlaybackRate] = 1.0
        NowPlayingInfo[MPMediaItemPropertyArtist] = artist.isEmpty ? "Taiga Stream" : artist
        NowPlayingInfo[MPMediaItemPropertyTitle]  = title.isEmpty  ? "Stream \(CurrentStream)" : title
        
        if let ExistingArtwork = ExistingArtwork
        {
            NowPlayingInfo[MPMediaItemPropertyArtwork] = ExistingArtwork
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = NowPlayingInfo
        MPNowPlayingInfoCenter.default().playbackState = Playing ? .playing : .paused
    }
    
    public func UpdateNowPlayingPlaybackState()
    {
        MPNowPlayingInfoCenter.default().playbackState = Playing ? .playing : .paused
        if var NowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
        {
            NowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = Playing ? 1.0 : 0.0
            MPNowPlayingInfoCenter.default().nowPlayingInfo = NowPlayingInfo
        }
        else
        {
            UpdateNowPlayingInfo()
        }
    }
    
    public func ClearNowPlayingInfo()
    {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        MPNowPlayingInfoCenter.default().playbackState = .stopped
    }
    
    var MetadataOutput: AVPlayerItemMetadataOutput?
    
    public func ObserveStreamMetadata()
    {
        if let ExistingOutput = MetadataOutput
        {
            PlayStream.currentItem?.remove(ExistingOutput)
        }
        
        let Output = AVPlayerItemMetadataOutput(identifiers: nil)
        Output.setDelegate(self, queue: .main)
        PlayStream.currentItem?.add(Output)
        MetadataOutput = Output
    }
    
    private func CleanMetadataString(_ Artist: String) -> String
    {
        let ISRCPattern = #"\s*-\s*[A-Z][A-Z0-9]{7,11}$"#
        var Cleaned = Artist
        
        if let Range = Cleaned.range(of: ISRCPattern, options: .regularExpression)
        {
            Cleaned = String(Cleaned[Cleaned.startIndex..<Range.lowerBound])
        }
        
        let TrailingHyphenPattern = #"\s*-\s*$"#
        
        if let Range = Cleaned.range(of: TrailingHyphenPattern, options: .regularExpression)
        {
            Cleaned = String(Cleaned[Cleaned.startIndex..<Range.lowerBound])
        }
        
        return Cleaned.trimmingCharacters(in: .whitespaces)
    }
    
    private func JunkMetadata(_ value: String) -> Bool
    {
        let TrimmedValue = value.trimmingCharacters(in: .whitespaces)
        if TrimmedValue.isEmpty
        {
            return true
        }
        
        let StationIDPattern = #"^zc\d+$"#
        if TrimmedValue.range(of: StationIDPattern, options: [.regularExpression, .caseInsensitive]) != nil
        {
            return true
        }
        
        let TechnicalIDPattern = #"^[a-z0-9]*_[a-z0-9_]+$"#
        if TrimmedValue.range(of: TechnicalIDPattern, options: [.regularExpression, .caseInsensitive]) != nil
        {
            return true
        }
        
        if TrimmedValue.contains("/") || TrimmedValue.contains("://")
        {
            return true
        }
        
        let AdMarkerPattern = #"(?i)(spot\s+block|ad\s+break|commercial\s+break)"#
        if TrimmedValue.range(of: AdMarkerPattern, options: .regularExpression) != nil
        {
            return true
        }
        
        let XMLAttributePattern = #"\w+\s*=\s*""#
        if TrimmedValue.range(of: XMLAttributePattern, options: .regularExpression) != nil
        {
            return true
        }
        
        return false
    }
    
    private func ParseMetadata(_ MetadataItems: [AVMetadataItem])
    {
        Task
        {
            var Artist = ""
            var Title = ""
            for Item in MetadataItems
            {
                if Item.commonKey == .commonKeyArtist,
                   let Value = try? await Item.load(.stringValue)
                {
                    let cleaned = CleanMetadataString(Value)
                    Artist = JunkMetadata(cleaned) ? "" : cleaned
                }
                else if Item.commonKey == .commonKeyTitle,
                        let Value = try? await Item.load(.stringValue)
                {
                    let Parts = Value.components(separatedBy: " - ")
                    let ISRCPattern = #"^[A-Z][A-Z0-9]{7,11}$"#
                    let LastPart = Parts.last?.trimmingCharacters(in: .whitespaces) ?? ""
                    let LastIsISRC = LastPart.range(of: ISRCPattern, options: .regularExpression) != nil
                    let LastIsEmpty = LastPart.isEmpty
                    
                    if LastIsISRC || LastIsEmpty
                    {
                        let CleanParts = Parts.dropLast().map
                        {
                            $0.trimmingCharacters(in: .whitespaces) }
                        Title = CleanMetadataString(CleanParts.first ?? "")
                        Artist = CleanMetadataString(CleanParts.dropFirst().joined(separator: " - "))
                    }
                    
                    else if Parts.count >= 2
                    {
                        Artist = CleanMetadataString(Parts[0].trimmingCharacters(in: .whitespaces))
                        Title = CleanMetadataString(Parts.dropFirst().joined(separator: " - ").trimmingCharacters(in: .whitespaces))
                    }
                    
                    else
                    {
                        Title = CleanMetadataString(Value)
                    }
                }
                if JunkMetadata(Title) { Title = "" }
                if JunkMetadata(Artist) { Artist = "" }
            }
            
            let ResolvedArtist = Artist.isEmpty ? "Taiga Stream" : Artist
            let ResolvedTitle  = Title.isEmpty  ? "Stream \(CurrentStream)" : Title
            
            await MainActor.run
            {
                UpdateNowPlayingInfo(artist: ResolvedArtist, title: ResolvedTitle)
                FetchArtwork(artist: ResolvedArtist, title: ResolvedTitle)
            }
        }
    }
    
    public var FallbackArtworkSet = false
    
    private func FetchArtwork(artist: String, title: String)
    {
        guard artist != "Taiga Stream" || title != "Stream \(CurrentStream)" else
        {
            if !FallbackArtworkSet
            {
                SetFallbackArtwork()
                FallbackArtworkSet = true
            }
            return
        }
        
        FallbackArtworkSet = false
        let NowPlayingQuery = "\(artist) \(title)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let URLString = "https://itunes.apple.com/search?term=\(NowPlayingQuery)&entity=song&limit=1"
        
        guard let SearchURL = URL(string: URLString) else
        {
            SetFallbackArtwork()
            return
        }
        
        URLSession.shared.dataTask(with: SearchURL)
        {
            [weak self] Data, _, Error in
            guard let self = self,
                  let Data = Data,
                  Error == nil,
                  let JSON = try? JSONSerialization.jsonObject(with: Data) as? [String: Any],
                  let Results = JSON["results"] as? [[String: Any]],
                  let FirstResult = Results.first,
                  let ArtworkString = FirstResult["artworkUrl100"] as? String
            else
            {
                DispatchQueue.main.async
                {
                    self?.SetFallbackArtwork()
                }
                return
            }
            
            let HighResArtworkString = ArtworkString
                .replacingOccurrences(of: "100x100bb", with: "600x600bb")
            guard let ArtworkURL = URL(string: HighResArtworkString) else
            {
                DispatchQueue.main.async
                {
                    self.SetFallbackArtwork()
                }
                return
            }
            
            URLSession.shared.dataTask(with: ArtworkURL)
            {
                [weak self] ImageData, _, ImageError in
                guard let self = self,
                      let ImageData = ImageData,
                      ImageError == nil,
                      let ArtworkImage = UIImage(data: ImageData)
                else
                {
                    DispatchQueue.main.async
                    {
                        self?.SetFallbackArtwork()
                    }
                    return
                }
                
                DispatchQueue.main.async
                {
                    self.ApplyArtwork(ArtworkImage)
                }
            }
            .resume()
        }
        .resume()
    }
    
    private func ApplyArtwork(_ Image: UIImage)
    {
        let Artwork = MPMediaItemArtwork(boundsSize: Image.size)
        {
            _ in Image
        }
        
        if var NowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
        {
            NowPlayingInfo[MPMediaItemPropertyArtwork] = Artwork
            MPNowPlayingInfoCenter.default().nowPlayingInfo = NowPlayingInfo
        }
    }
    
    internal func SetFallbackArtwork()
    {
        let AppIcon = AppIconImage() ?? UIImage(systemName: "radio")
        guard let Icon = AppIcon else
        {
            return
        }
        ApplyArtwork(Icon)
    }
    
    private func AppIconImage() -> UIImage?
    {
        guard
            let Icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
            let PrimaryIcon = Icons["CFBundlePrimaryIcon"] as? [String: Any],
            let IconFiles = PrimaryIcon["CFBundleIconFiles"] as? [String],
            let LastIcon = IconFiles.last
        else
        {
            return nil
        }
        return UIImage(named: LastIcon)
    }
    
    public func PlayerObservers()
    {
        PlayerCancellables.removeAll()
        
        PlayStream.publisher(for: \.timeControlStatus)
            .receive(on: DispatchQueue.main)
            .sink
        {
            [weak self] StreamStatus in
            if StreamStatus == .paused
            {
                self?.Playing = false
            }
            else if StreamStatus == .playing
            {
                self?.Playing = true
            }
        }
        .store(in: &PlayerCancellables)
        
        PlayStream.publisher(for: \.currentItem?.status)
            .receive(on: DispatchQueue.main)
            .sink
        {
            [weak self] StreamStatus in
            if StreamStatus == .failed
            {
                self?.Playing = false
            }
        }
        .store(in: &PlayerCancellables)
        
        NotificationCenter.default.publisher(for: .AVPlayerItemFailedToPlayToEndTime)
            .receive(on: DispatchQueue.main)
            .sink
        {
            [weak self] _ in self?.Playing = false
        }
        .store(in: &PlayerCancellables)
        
        NotificationCenter.default.publisher(for: .AVPlayerItemPlaybackStalled)
            .receive(on: DispatchQueue.main)
            .sink
        {
            [weak self] _ in self?.Playing = false
        }
        .store(in: &PlayerCancellables)
    }
    
    public func SessionObservers()
    {
        SessionCancellables.removeAll()
        
        NotificationCenter.default.publisher(for: AVAudioSession.interruptionNotification)
            .receive(on: DispatchQueue.main)
            .sink
        {
            [weak self] StreamNotification in
            guard let StreamUserInfo = StreamNotification.userInfo,
                  let StreamTypeValue = StreamUserInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
                  let StreamType = AVAudioSession.InterruptionType(rawValue: StreamTypeValue) else
            {
                return
            }
            if StreamType == .began
            {
                self?.Playing = false
                self?.PlayStream.pause()
            }
        }
        .store(in: &SessionCancellables)
        
        NotificationCenter.default.publisher(for: AVAudioSession.silenceSecondaryAudioHintNotification)
            .receive(on: DispatchQueue.main)
            .sink
        {
            [weak self] StreamNotification in
            guard let StreamUserInfo = StreamNotification.userInfo,
                  let StreamTypeValue = StreamUserInfo[AVAudioSessionSilenceSecondaryAudioHintTypeKey] as? UInt,
                  let StreamType = AVAudioSession.SilenceSecondaryAudioHintType(rawValue: StreamTypeValue) else
            {
                return
            }
            if StreamType == .begin
            {
                self?.Playing = false
                self?.PlayStream.pause()
            }
        }
        .store(in: &SessionCancellables)
        
        NotificationCenter.default.publisher(for: AVAudioSession.routeChangeNotification)
            .receive(on: DispatchQueue.main)
            .sink
        {
            [weak self] StreamNotification in
            guard let StreamUserInfo = StreamNotification.userInfo,
                  let StreamTypeValue = StreamUserInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
                  let StreamType = AVAudioSession.RouteChangeReason(rawValue: StreamTypeValue) else
            {
                return
            }
            if StreamType == .categoryChange
            {
                if AVAudioSession.sharedInstance().secondaryAudioShouldBeSilencedHint
                {
                    self?.Playing = false
                    self?.PlayStream.pause()
                }
            }
        }
        .store(in: &SessionCancellables)
        
        NotificationCenter.default.publisher(for: AVAudioSession.mediaServicesWereLostNotification)
            .sink
        {
            [weak self] _ in
            self?.Playing = false
            self?.PlayStream.pause()
        }
        .store(in: &SessionCancellables)
        
        NotificationCenter.default.publisher(for: AVAudioSession.mediaServicesWereResetNotification)
            .sink
        {
            [weak self] _ in
            self?.Playing = false
            self?.PlayStream.pause()
        }
        .store(in: &SessionCancellables)
    }
    
    public func StartPlaybackHeartbeat()
    {
        PlaybackHeartbeat = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink
        {
            [weak self] _ in
            guard let self = self else
            {
                return
            }
            let actuallyPlaying = self.PlayStream.timeControlStatus == .playing
            if !actuallyPlaying && self.Playing
            {
                self.Playing = false
            }
        }
    }
    
    public func StopPlaybackHeartbeat()
    {
        PlaybackHeartbeat = nil
    }
}

extension PlayStreamData: AVPlayerItemMetadataOutputPushDelegate
{
    public func metadataOutput(
        _ output: AVPlayerItemMetadataOutput,
        didOutputTimedMetadataGroups groups: [AVTimedMetadataGroup],
        from track: AVPlayerItemTrack?)
    {
        let MetadataItems = groups.flatMap
        {
            $0.items
        }
        ParseMetadata(MetadataItems)
    }
}

public class PlayStreamButton
{
    static let PlayStreamButtonShared = PlayStreamButton()
    
    private func StartStream(_ StreamURL: URL, StreamNumber: Int)
    {
        let NewStreamItem = AVPlayerItem(url: StreamURL)
        let Data = PlayStreamData.SharedResource
        
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        try? AVAudioSession.sharedInstance().setActive(true)
        
        Data.PlayStream.replaceCurrentItem(with: NewStreamItem)
        Data.PlayStream.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
        Data.CurrentStream = StreamNumber
        Data.FallbackArtworkSet = false
        Data.UpdateNowPlayingInfo(title: "Stream \(StreamNumber)")
        Data.SetFallbackArtwork()
        Data.FallbackArtworkSet = true
        Data.ObserveStreamMetadata()
        Data.PlayStream.play()
        Data.StartPlaybackHeartbeat()
    }
    
    private func PlayButtonAction(StreamURL: URL, StreamNumber: Int)
    {
        let Data = PlayStreamData.SharedResource
        if Data.Playing && Data.CurrentStream == StreamNumber
        {
            Data.PlayStream.pause()
            Data.StopPlaybackHeartbeat()
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        }
        else
        {
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            StartStream(StreamURL, StreamNumber: StreamNumber)
        }
    }
    
    public func PlayButton1_Click()
    {
        guard let URL = URL(string: PlayStreamData.SharedResource.Stream1) else { return }
        PlayButtonAction(StreamURL: URL, StreamNumber: 1)
    }
    
    public func PlayButton2_Click()
    {
        guard let URL = URL(string: PlayStreamData.SharedResource.Stream2) else { return }
        PlayButtonAction(StreamURL: URL, StreamNumber: 2)
    }
    
    public func PlayButton3_Click()
    {
        guard let URL = URL(string: PlayStreamData.SharedResource.Stream3) else { return }
        PlayButtonAction(StreamURL: URL, StreamNumber: 3)
    }
    
    public func PlayButton4_Click()
    {
        guard let URL = URL(string: PlayStreamData.SharedResource.Stream4) else { return }
        PlayButtonAction(StreamURL: URL, StreamNumber: 4)
    }
    
    public func PlayButton5_Click()
    {
        guard let URL = URL(string: PlayStreamData.SharedResource.Stream5) else { return }
        PlayButtonAction(StreamURL: URL, StreamNumber: 5)
    }
    
    public func PlayButton6_Click()
    {
        guard let URL = URL(string: PlayStreamData.SharedResource.Stream6) else { return }
        PlayButtonAction(StreamURL: URL, StreamNumber: 6)
    }
    
    public func PlayButton7_Click()
    {
        guard let URL = URL(string: PlayStreamData.SharedResource.Stream7) else { return }
        PlayButtonAction(StreamURL: URL, StreamNumber: 7)
    }
    
    public func PlayButton8_Click()
    {
        guard let URL = URL(string: PlayStreamData.SharedResource.Stream8) else { return }
        PlayButtonAction(StreamURL: URL, StreamNumber: 8)
    }
    
    public func PlayButton9_Click()
    {
        guard let URL = URL(string: PlayStreamData.SharedResource.Stream9) else { return }
        PlayButtonAction(StreamURL: URL, StreamNumber: 9)
    }
    
    public func PlayButton10_Click()
    {
        guard let URL = URL(string: PlayStreamData.SharedResource.Stream10) else { return }
        PlayButtonAction(StreamURL: URL, StreamNumber: 10)
    }
    
    public func PlayButton11_Click()
    {
        guard let URL = URL(string: PlayStreamData.SharedResource.Stream11) else { return }
        PlayButtonAction(StreamURL: URL, StreamNumber: 11)
    }
    
    public func PlayButton12_Click()
    {
        guard let URL = URL(string: PlayStreamData.SharedResource.Stream12) else { return }
        PlayButtonAction(StreamURL: URL, StreamNumber: 12)
    }
    
    public func PlayButton13_Click()
    {
        guard let URL = URL(string: PlayStreamData.SharedResource.Stream13) else { return }
        PlayButtonAction(StreamURL: URL, StreamNumber: 13)
    }
    
    public func PlayButton14_Click()
    {
        guard let URL = URL(string: PlayStreamData.SharedResource.Stream14) else { return }
        PlayButtonAction(StreamURL: URL, StreamNumber: 14)
    }
    
    public func PlayButton15_Click()
    {
        guard let URL = URL(string: PlayStreamData.SharedResource.Stream15) else { return }
        PlayButtonAction(StreamURL: URL, StreamNumber: 15)
    }
    
    public func PlayButton16_Click()
    {
        guard let URL = URL(string: PlayStreamData.SharedResource.Stream16) else { return }
        PlayButtonAction(StreamURL: URL, StreamNumber: 16)
    }
    
    public func PlayButton17_Click()
    {
        guard let URL = URL(string: PlayStreamData.SharedResource.Stream17) else { return }
        PlayButtonAction(StreamURL: URL, StreamNumber: 17)
    }
    
    public func PlayButton18_Click()
    {
        guard let URL = URL(string: PlayStreamData.SharedResource.Stream18) else { return }
        PlayButtonAction(StreamURL: URL, StreamNumber: 18)
    }
    
    public func PlayButton19_Click()
    {
        guard let URL = URL(string: PlayStreamData.SharedResource.Stream19) else { return }
        PlayButtonAction(StreamURL: URL, StreamNumber: 19)
    }
    
    public func PlayButton20_Click()
    {
        guard let URL = URL(string: PlayStreamData.SharedResource.Stream20) else { return }
        PlayButtonAction(StreamURL: URL, StreamNumber: 20)
    }
    
    public func PlayButton21_Click()
    {
        guard let URL = URL(string: PlayStreamData.SharedResource.Stream21) else { return }
        PlayButtonAction(StreamURL: URL, StreamNumber: 21)
    }
    
    public func PlayButton22_Click()
    {
        guard let URL = URL(string: PlayStreamData.SharedResource.Stream22) else { return }
        PlayButtonAction(StreamURL: URL, StreamNumber: 22)
    }
    
    public func PlayButton23_Click()
    {
        guard let URL = URL(string: PlayStreamData.SharedResource.Stream23) else { return }
        PlayButtonAction(StreamURL: URL, StreamNumber: 23)
    }
    
    public func PlayButton24_Click()
    {
        guard let URL = URL(string: PlayStreamData.SharedResource.Stream24) else { return }
        PlayButtonAction(StreamURL: URL, StreamNumber: 24)
    }
}

struct TaigaStreamWidgetControl1: ControlWidget
{
    var body: some ControlWidgetConfiguration
    {
        StaticControlConfiguration(kind: "xyz.andrewmichaelpowell.taigastream.stream1")
        {
            let StreamState = UserDefaults(suiteName: "group.xyz.andrewmichaelpowell.taigastream")!
            let ButtonState = StreamState.bool(forKey: "PlayingKey") && StreamState.integer(forKey: "CurrentStreamKey") == 1
            return ControlWidgetToggle(isOn: ButtonState, action: PlayStream1ToggleIntent())
            {
                Label("Stream 1", systemImage: "1.circle")
            }
        }
        .displayName("Stream 1")
    }
}

struct PlayStream1ToggleIntent: SetValueIntent, AudioPlaybackIntent
{
    static let title: LocalizedStringResource = "Stream 1"
    @Parameter(title: "Is On") var value: Bool
    @MainActor func perform() async throws -> some IntentResult
    {
        PlayStreamButton.PlayStreamButtonShared.PlayButton1_Click()
        return .result()
    }
}

struct TaigaStreamWidgetControl2: ControlWidget
{
    var body: some ControlWidgetConfiguration
    {
        StaticControlConfiguration(kind: "xyz.andrewmichaelpowell.taigastream.stream2")
        {
            let StreamState = UserDefaults(suiteName: "group.xyz.andrewmichaelpowell.taigastream")!
            let ButtonState = StreamState.bool(forKey: "PlayingKey") && StreamState.integer(forKey: "CurrentStreamKey") == 2
            return ControlWidgetToggle(isOn: ButtonState, action: PlayStream2ToggleIntent())
            {
                Label("Stream 2", systemImage: "2.circle")
            }
        }
        .displayName("Stream 2")
    }
}

struct PlayStream2ToggleIntent: SetValueIntent, AudioPlaybackIntent
{
    static let title: LocalizedStringResource = "Stream 2"
    @Parameter(title: "Is On") var value: Bool
    @MainActor func perform() async throws -> some IntentResult
    {
        PlayStreamButton.PlayStreamButtonShared.PlayButton2_Click()
        return .result()
    }
}

struct TaigaStreamWidgetControl3: ControlWidget
{
    var body: some ControlWidgetConfiguration
    {
        StaticControlConfiguration(kind: "xyz.andrewmichaelpowell.taigastream.stream3")
        {
            let StreamState = UserDefaults(suiteName: "group.xyz.andrewmichaelpowell.taigastream")!
            let ButtonState = StreamState.bool(forKey: "PlayingKey") && StreamState.integer(forKey: "CurrentStreamKey") == 3
            return ControlWidgetToggle(isOn: ButtonState, action: PlayStream3ToggleIntent())
            {
                Label("Stream 3", systemImage: "3.circle")
            }
        }
        .displayName("Stream 3")
    }
}

struct PlayStream3ToggleIntent: SetValueIntent, AudioPlaybackIntent
{
    static let title: LocalizedStringResource = "Stream 3"
    @Parameter(title: "Is On") var value: Bool
    @MainActor func perform() async throws -> some IntentResult
    {
        PlayStreamButton.PlayStreamButtonShared.PlayButton3_Click()
        return .result()
    }
}

struct TaigaStreamWidgetControl4: ControlWidget
{
    var body: some ControlWidgetConfiguration
    {
        StaticControlConfiguration(kind: "xyz.andrewmichaelpowell.taigastream.stream4")
        {
            let StreamState = UserDefaults(suiteName: "group.xyz.andrewmichaelpowell.taigastream")!
            let ButtonState = StreamState.bool(forKey: "PlayingKey") && StreamState.integer(forKey: "CurrentStreamKey") == 4
            return ControlWidgetToggle(isOn: ButtonState, action: PlayStream4ToggleIntent())
            {
                Label("Stream 4", systemImage: "4.circle")
            }
        }
        .displayName("Stream 4")
    }
}

struct PlayStream4ToggleIntent: SetValueIntent, AudioPlaybackIntent
{
    static let title: LocalizedStringResource = "Stream 4"
    @Parameter(title: "Is On") var value: Bool
    @MainActor func perform() async throws -> some IntentResult
    {
        PlayStreamButton.PlayStreamButtonShared.PlayButton4_Click()
        return .result()
    }
}

struct TaigaStreamWidgetControl5: ControlWidget
{
    var body: some ControlWidgetConfiguration
    {
        StaticControlConfiguration(kind: "xyz.andrewmichaelpowell.taigastream.stream5")
        {
            let StreamState = UserDefaults(suiteName: "group.xyz.andrewmichaelpowell.taigastream")!
            let ButtonState = StreamState.bool(forKey: "PlayingKey") && StreamState.integer(forKey: "CurrentStreamKey") == 5
            return ControlWidgetToggle(isOn: ButtonState, action: PlayStream5ToggleIntent())
            {
                Label("Stream 5", systemImage: "5.circle")
            }
        }
        .displayName("Stream 5")
    }
}

struct PlayStream5ToggleIntent: SetValueIntent, AudioPlaybackIntent
{
    static let title: LocalizedStringResource = "Stream 5"
    @Parameter(title: "Is On") var value: Bool
    @MainActor func perform() async throws -> some IntentResult
    {
        PlayStreamButton.PlayStreamButtonShared.PlayButton5_Click()
        return .result()
    }
}

struct TaigaStreamWidgetControl6: ControlWidget
{
    var body: some ControlWidgetConfiguration
    {
        StaticControlConfiguration(kind: "xyz.andrewmichaelpowell.taigastream.stream6")
        {
            let StreamState = UserDefaults(suiteName: "group.xyz.andrewmichaelpowell.taigastream")!
            let ButtonState = StreamState.bool(forKey: "PlayingKey") && StreamState.integer(forKey: "CurrentStreamKey") == 6
            return ControlWidgetToggle(isOn: ButtonState, action: PlayStream6ToggleIntent())
            {
                Label("Stream 6", systemImage: "6.circle")
            }
        }
        .displayName("Stream 6")
    }
}

struct PlayStream6ToggleIntent: SetValueIntent, AudioPlaybackIntent
{
    static let title: LocalizedStringResource = "Stream 6"
    @Parameter(title: "Is On") var value: Bool
    @MainActor func perform() async throws -> some IntentResult
    {
        PlayStreamButton.PlayStreamButtonShared.PlayButton6_Click()
        return .result()
    }
}

struct TaigaStreamWidgetControl7: ControlWidget
{
    var body: some ControlWidgetConfiguration
    {
        StaticControlConfiguration(kind: "xyz.andrewmichaelpowell.taigastream.stream7")
        {
            let StreamState = UserDefaults(suiteName: "group.xyz.andrewmichaelpowell.taigastream")!
            let ButtonState = StreamState.bool(forKey: "PlayingKey") && StreamState.integer(forKey: "CurrentStreamKey") == 7
            return ControlWidgetToggle(isOn: ButtonState, action: PlayStream7ToggleIntent())
            {
                Label("Stream 7", systemImage: "7.circle")
            }
        }
        .displayName("Stream 7")
    }
}

struct PlayStream7ToggleIntent: SetValueIntent, AudioPlaybackIntent
{
    static let title: LocalizedStringResource = "Stream 7"
    @Parameter(title: "Is On") var value: Bool
    @MainActor func perform() async throws -> some IntentResult
    {
        PlayStreamButton.PlayStreamButtonShared.PlayButton7_Click()
        return .result()
    }
}

struct TaigaStreamWidgetControl8: ControlWidget
{
    var body: some ControlWidgetConfiguration
    {
        StaticControlConfiguration(kind: "xyz.andrewmichaelpowell.taigastream.stream8")
        {
            let StreamState = UserDefaults(suiteName: "group.xyz.andrewmichaelpowell.taigastream")!
            let ButtonState = StreamState.bool(forKey: "PlayingKey") && StreamState.integer(forKey: "CurrentStreamKey") == 8
            return ControlWidgetToggle(isOn: ButtonState, action: PlayStream8ToggleIntent())
            {
                Label("Stream 8", systemImage: "8.circle")
            }
        }
        .displayName("Stream 8")
    }
}

struct PlayStream8ToggleIntent: SetValueIntent, AudioPlaybackIntent
{
    static let title: LocalizedStringResource = "Stream 8"
    @Parameter(title: "Is On") var value: Bool
    @MainActor func perform() async throws -> some IntentResult
    {
        PlayStreamButton.PlayStreamButtonShared.PlayButton8_Click()
        return .result()
    }
}

struct TaigaStreamWidgetControl9: ControlWidget
{
    var body: some ControlWidgetConfiguration
    {
        StaticControlConfiguration(kind: "xyz.andrewmichaelpowell.taigastream.stream9")
        {
            let StreamState = UserDefaults(suiteName: "group.xyz.andrewmichaelpowell.taigastream")!
            let ButtonState = StreamState.bool(forKey: "PlayingKey") && StreamState.integer(forKey: "CurrentStreamKey") == 9
            return ControlWidgetToggle(isOn: ButtonState, action: PlayStream9ToggleIntent())
            {
                Label("Stream 9", systemImage: "9.circle")
            }
        }
        .displayName("Stream 9")
    }
}

struct PlayStream9ToggleIntent: SetValueIntent, AudioPlaybackIntent
{
    static let title: LocalizedStringResource = "Stream 9"
    @Parameter(title: "Is On") var value: Bool
    @MainActor func perform() async throws -> some IntentResult
    {
        PlayStreamButton.PlayStreamButtonShared.PlayButton9_Click()
        return .result()
    }
}

struct TaigaStreamWidgetControl10: ControlWidget
{
    var body: some ControlWidgetConfiguration
    {
        StaticControlConfiguration(kind: "xyz.andrewmichaelpowell.taigastream.stream10")
        {
            let StreamState = UserDefaults(suiteName: "group.xyz.andrewmichaelpowell.taigastream")!
            let ButtonState = StreamState.bool(forKey: "PlayingKey") && StreamState.integer(forKey: "CurrentStreamKey") == 10
            return ControlWidgetToggle(isOn: ButtonState, action: PlayStream10ToggleIntent())
            {
                Label("Stream 10", systemImage: "10.circle")
            }
        }
        .displayName("Stream 10")
    }
}

struct PlayStream10ToggleIntent: SetValueIntent, AudioPlaybackIntent
{
    static let title: LocalizedStringResource = "Stream 10"
    @Parameter(title: "Is On") var value: Bool
    @MainActor func perform() async throws -> some IntentResult
    {
        PlayStreamButton.PlayStreamButtonShared.PlayButton10_Click()
        return .result()
    }
}

struct TaigaStreamWidgetControl11: ControlWidget
{
    var body: some ControlWidgetConfiguration
    {
        StaticControlConfiguration(kind: "xyz.andrewmichaelpowell.taigastream.stream11")
        {
            let StreamState = UserDefaults(suiteName: "group.xyz.andrewmichaelpowell.taigastream")!
            let ButtonState = StreamState.bool(forKey: "PlayingKey") && StreamState.integer(forKey: "CurrentStreamKey") == 11
            return ControlWidgetToggle(isOn: ButtonState, action: PlayStream11ToggleIntent())
            {
                Label("Stream 11", systemImage: "11.circle")
            }
        }
        .displayName("Stream 11")
    }
}

struct PlayStream11ToggleIntent: SetValueIntent, AudioPlaybackIntent
{
    static let title: LocalizedStringResource = "Stream 11"
    @Parameter(title: "Is On") var value: Bool
    @MainActor func perform() async throws -> some IntentResult
    {
        PlayStreamButton.PlayStreamButtonShared.PlayButton11_Click()
        return .result()
    }
}

struct TaigaStreamWidgetControl12: ControlWidget
{
    var body: some ControlWidgetConfiguration
    {
        StaticControlConfiguration(kind: "xyz.andrewmichaelpowell.taigastream.stream12")
        {
            let StreamState = UserDefaults(suiteName: "group.xyz.andrewmichaelpowell.taigastream")!
            let ButtonState = StreamState.bool(forKey: "PlayingKey") && StreamState.integer(forKey: "CurrentStreamKey") == 12
            return ControlWidgetToggle(isOn: ButtonState, action: PlayStream12ToggleIntent())
            {
                Label("Stream 12", systemImage: "12.circle")
            }
        }
        .displayName("Stream 12")
    }
}

struct PlayStream12ToggleIntent: SetValueIntent, AudioPlaybackIntent
{
    static let title: LocalizedStringResource = "Stream 12"
    @Parameter(title: "Is On") var value: Bool
    @MainActor func perform() async throws -> some IntentResult
    {
        PlayStreamButton.PlayStreamButtonShared.PlayButton12_Click()
        return .result()
    }
}

struct TaigaStreamWidgetControl13: ControlWidget
{
    var body: some ControlWidgetConfiguration
    {
        StaticControlConfiguration(kind: "xyz.andrewmichaelpowell.taigastream.stream13")
        {
            let StreamState = UserDefaults(suiteName: "group.xyz.andrewmichaelpowell.taigastream")!
            let ButtonState = StreamState.bool(forKey: "PlayingKey") && StreamState.integer(forKey: "CurrentStreamKey") == 13
            return ControlWidgetToggle(isOn: ButtonState, action: PlayStream13ToggleIntent())
            {
                Label("Stream 13", systemImage: "13.circle")
            }
        }
        .displayName("Stream 13")
    }
}

struct PlayStream13ToggleIntent: SetValueIntent, AudioPlaybackIntent
{
    static let title: LocalizedStringResource = "Stream 13"
    @Parameter(title: "Is On") var value: Bool
    @MainActor func perform() async throws -> some IntentResult
    {
        PlayStreamButton.PlayStreamButtonShared.PlayButton13_Click()
        return .result()
    }
}

struct TaigaStreamWidgetControl14: ControlWidget
{
    var body: some ControlWidgetConfiguration
    {
        StaticControlConfiguration(kind: "xyz.andrewmichaelpowell.taigastream.stream14")
        {
            let StreamState = UserDefaults(suiteName: "group.xyz.andrewmichaelpowell.taigastream")!
            let ButtonState = StreamState.bool(forKey: "PlayingKey") && StreamState.integer(forKey: "CurrentStreamKey") == 14
            return ControlWidgetToggle(isOn: ButtonState, action: PlayStream14ToggleIntent())
            {
                Label("Stream 14", systemImage: "14.circle")
            }
        }
        .displayName("Stream 14")
    }
}

struct PlayStream14ToggleIntent: SetValueIntent, AudioPlaybackIntent
{
    static let title: LocalizedStringResource = "Stream 14"
    @Parameter(title: "Is On") var value: Bool
    @MainActor func perform() async throws -> some IntentResult
    {
        PlayStreamButton.PlayStreamButtonShared.PlayButton14_Click()
        return .result()
    }
}

struct TaigaStreamWidgetControl15: ControlWidget
{
    var body: some ControlWidgetConfiguration
    {
        StaticControlConfiguration(kind: "xyz.andrewmichaelpowell.taigastream.stream15")
        {
            let StreamState = UserDefaults(suiteName: "group.xyz.andrewmichaelpowell.taigastream")!
            let ButtonState = StreamState.bool(forKey: "PlayingKey") && StreamState.integer(forKey: "CurrentStreamKey") == 15
            return ControlWidgetToggle(isOn: ButtonState, action: PlayStream15ToggleIntent())
            {
                Label("Stream 15", systemImage: "15.circle")
            }
        }
        .displayName("Stream 15")
    }
}

struct PlayStream15ToggleIntent: SetValueIntent, AudioPlaybackIntent
{
    static let title: LocalizedStringResource = "Stream 15"
    @Parameter(title: "Is On") var value: Bool
    @MainActor func perform() async throws -> some IntentResult
    {
        PlayStreamButton.PlayStreamButtonShared.PlayButton15_Click()
        return .result()
    }
}

struct TaigaStreamWidgetControl16: ControlWidget
{
    var body: some ControlWidgetConfiguration
    {
        StaticControlConfiguration(kind: "xyz.andrewmichaelpowell.taigastream.stream16")
        {
            let StreamState = UserDefaults(suiteName: "group.xyz.andrewmichaelpowell.taigastream")!
            let ButtonState = StreamState.bool(forKey: "PlayingKey") && StreamState.integer(forKey: "CurrentStreamKey") == 16
            return ControlWidgetToggle(isOn: ButtonState, action: PlayStream16ToggleIntent())
            {
                Label("Stream 16", systemImage: "16.circle")
            }
        }
        .displayName("Stream 16")
    }
}

struct PlayStream16ToggleIntent: SetValueIntent, AudioPlaybackIntent
{
    static let title: LocalizedStringResource = "Stream 16"
    @Parameter(title: "Is On") var value: Bool
    @MainActor func perform() async throws -> some IntentResult
    {
        PlayStreamButton.PlayStreamButtonShared.PlayButton16_Click()
        return .result()
    }
}

struct TaigaStreamWidgetControl17: ControlWidget
{
    var body: some ControlWidgetConfiguration
    {
        StaticControlConfiguration(kind: "xyz.andrewmichaelpowell.taigastream.stream17")
        {
            let StreamState = UserDefaults(suiteName: "group.xyz.andrewmichaelpowell.taigastream")!
            let ButtonState = StreamState.bool(forKey: "PlayingKey") && StreamState.integer(forKey: "CurrentStreamKey") == 17
            return ControlWidgetToggle(isOn: ButtonState, action: PlayStream17ToggleIntent())
            {
                Label("Stream 17", systemImage: "17.circle")
            }
        }
        .displayName("Stream 17")
    }
}

struct PlayStream17ToggleIntent: SetValueIntent, AudioPlaybackIntent
{
    static let title: LocalizedStringResource = "Stream 17"
    @Parameter(title: "Is On") var value: Bool
    @MainActor func perform() async throws -> some IntentResult
    {
        PlayStreamButton.PlayStreamButtonShared.PlayButton17_Click()
        return .result()
    }
}

struct TaigaStreamWidgetControl18: ControlWidget
{
    var body: some ControlWidgetConfiguration
    {
        StaticControlConfiguration(kind: "xyz.andrewmichaelpowell.taigastream.stream18")
        {
            let StreamState = UserDefaults(suiteName: "group.xyz.andrewmichaelpowell.taigastream")!
            let ButtonState = StreamState.bool(forKey: "PlayingKey") && StreamState.integer(forKey: "CurrentStreamKey") == 18
            return ControlWidgetToggle(isOn: ButtonState, action: PlayStream18ToggleIntent())
            {
                Label("Stream 18", systemImage: "18.circle")
            }
        }
        .displayName("Stream 18")
    }
}

struct PlayStream18ToggleIntent: SetValueIntent, AudioPlaybackIntent
{
    static let title: LocalizedStringResource = "Stream 18"
    @Parameter(title: "Is On") var value: Bool
    @MainActor func perform() async throws -> some IntentResult
    {
        PlayStreamButton.PlayStreamButtonShared.PlayButton18_Click()
        return .result()
    }
}

struct TaigaStreamWidgetControl19: ControlWidget
{
    var body: some ControlWidgetConfiguration
    {
        StaticControlConfiguration(kind: "xyz.andrewmichaelpowell.taigastream.stream19")
        {
            let StreamState = UserDefaults(suiteName: "group.xyz.andrewmichaelpowell.taigastream")!
            let ButtonState = StreamState.bool(forKey: "PlayingKey") && StreamState.integer(forKey: "CurrentStreamKey") == 19
            return ControlWidgetToggle(isOn: ButtonState, action: PlayStream19ToggleIntent())
            {
                Label("Stream 19", systemImage: "19.circle")
            }
        }
        .displayName("Stream 19")
    }
}

struct PlayStream19ToggleIntent: SetValueIntent, AudioPlaybackIntent
{
    static let title: LocalizedStringResource = "Stream 19"
    @Parameter(title: "Is On") var value: Bool
    @MainActor func perform() async throws -> some IntentResult
    {
        PlayStreamButton.PlayStreamButtonShared.PlayButton19_Click()
        return .result()
    }
}

struct TaigaStreamWidgetControl20: ControlWidget
{
    var body: some ControlWidgetConfiguration
    {
        StaticControlConfiguration(kind: "xyz.andrewmichaelpowell.taigastream.stream20")
        {
            let StreamState = UserDefaults(suiteName: "group.xyz.andrewmichaelpowell.taigastream")!
            let ButtonState = StreamState.bool(forKey: "PlayingKey") && StreamState.integer(forKey: "CurrentStreamKey") == 20
            return ControlWidgetToggle(isOn: ButtonState, action: PlayStream20ToggleIntent())
            {
                Label("Stream 20", systemImage: "20.circle")
            }
        }
        .displayName("Stream 20")
    }
}

struct PlayStream20ToggleIntent: SetValueIntent, AudioPlaybackIntent
{
    static let title: LocalizedStringResource = "Stream 20"
    @Parameter(title: "Is On") var value: Bool
    @MainActor func perform() async throws -> some IntentResult
    {
        PlayStreamButton.PlayStreamButtonShared.PlayButton20_Click()
        return .result()
    }
}

struct TaigaStreamWidgetControl21: ControlWidget
{
    var body: some ControlWidgetConfiguration
    {
        StaticControlConfiguration(kind: "xyz.andrewmichaelpowell.taigastream.stream21")
        {
            let StreamState = UserDefaults(suiteName: "group.xyz.andrewmichaelpowell.taigastream")!
            let ButtonState = StreamState.bool(forKey: "PlayingKey") && StreamState.integer(forKey: "CurrentStreamKey") == 21
            return ControlWidgetToggle(isOn: ButtonState, action: PlayStream21ToggleIntent())
            {
                Label("Stream 21", systemImage: "21.circle")
            }
        }
        .displayName("Stream 21")
    }
}

struct PlayStream21ToggleIntent: SetValueIntent, AudioPlaybackIntent
{
    static let title: LocalizedStringResource = "Stream 21"
    @Parameter(title: "Is On") var value: Bool
    @MainActor func perform() async throws -> some IntentResult
    {
        PlayStreamButton.PlayStreamButtonShared.PlayButton21_Click()
        return .result()
    }
}

struct TaigaStreamWidgetControl22: ControlWidget
{
    var body: some ControlWidgetConfiguration
    {
        StaticControlConfiguration(kind: "xyz.andrewmichaelpowell.taigastream.stream22")
        {
            let StreamState = UserDefaults(suiteName: "group.xyz.andrewmichaelpowell.taigastream")!
            let ButtonState = StreamState.bool(forKey: "PlayingKey") && StreamState.integer(forKey: "CurrentStreamKey") == 22
            return ControlWidgetToggle(isOn: ButtonState, action: PlayStream22ToggleIntent())
            {
                Label("Stream 22", systemImage: "22.circle")
            }
        }
        .displayName("Stream 22")
    }
}

struct PlayStream22ToggleIntent: SetValueIntent, AudioPlaybackIntent
{
    static let title: LocalizedStringResource = "Stream 22"
    @Parameter(title: "Is On") var value: Bool
    @MainActor func perform() async throws -> some IntentResult
    {
        PlayStreamButton.PlayStreamButtonShared.PlayButton22_Click()
        return .result()
    }
}

struct TaigaStreamWidgetControl23: ControlWidget
{
    var body: some ControlWidgetConfiguration
    {
        StaticControlConfiguration(kind: "xyz.andrewmichaelpowell.taigastream.stream23")
        {
            let StreamState = UserDefaults(suiteName: "group.xyz.andrewmichaelpowell.taigastream")!
            let ButtonState = StreamState.bool(forKey: "PlayingKey") && StreamState.integer(forKey: "CurrentStreamKey") == 23
            return ControlWidgetToggle(isOn: ButtonState, action: PlayStream23ToggleIntent())
            {
                Label("Stream 23", systemImage: "23.circle")
            }
        }
        .displayName("Stream 23")
    }
}

struct PlayStream23ToggleIntent: SetValueIntent, AudioPlaybackIntent
{
    static let title: LocalizedStringResource = "Stream 23"
    @Parameter(title: "Is On") var value: Bool
    @MainActor func perform() async throws -> some IntentResult
    {
        PlayStreamButton.PlayStreamButtonShared.PlayButton23_Click()
        return .result()
    }
}

struct TaigaStreamWidgetControl24: ControlWidget
{
    var body: some ControlWidgetConfiguration
    {
        StaticControlConfiguration(kind: "xyz.andrewmichaelpowell.taigastream.stream24")
        {
            let StreamState = UserDefaults(suiteName: "group.xyz.andrewmichaelpowell.taigastream")!
            let ButtonState = StreamState.bool(forKey: "PlayingKey") && StreamState.integer(forKey: "CurrentStreamKey") == 24
            return ControlWidgetToggle(isOn: ButtonState, action: PlayStream24ToggleIntent())
            {
                Label("Stream 24", systemImage: "24.circle")
            }
        }
        .displayName("Stream 24")
    }
}

struct PlayStream24ToggleIntent: SetValueIntent, AudioPlaybackIntent
{
    static let title: LocalizedStringResource = "Stream 24"
    @Parameter(title: "Is On") var value: Bool
    @MainActor func perform() async throws -> some IntentResult
    {
        PlayStreamButton.PlayStreamButtonShared.PlayButton24_Click()
        return .result()
    }
}
