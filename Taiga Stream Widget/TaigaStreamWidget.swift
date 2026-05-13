//  Taiga Stream
//  github.com/andrewmichaelpowell

import SwiftUI
import AppIntents
import AVKit
import AVFoundation
import Combine
import WidgetKit

public class PlayStreamData: ObservableObject
{
    static let SharedResource = PlayStreamData()
    let StreamState = UserDefaults(suiteName: "group.xyz.andrewmichaelpowell.taigastream")!
    var PlayerCancellables = Set<AnyCancellable>()
    var SessionCancellables = Set<AnyCancellable>()
    
    var CurrentStream: Int
    {
        get
        {
            StreamState.integer(forKey: "CurrentStreamKey")
        }
        set
        {
            StreamState.set(newValue, forKey: "CurrentStreamKey")
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
            objectWillChange.send()
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
    
    init()
    {
        PlayerObservers()
        SessionObservers()
    }
    
    public func PlayerObservers()
    {
        PlayerCancellables.removeAll()
        PlayStream.publisher(for: \.timeControlStatus)
        .receive(on: DispatchQueue.main)
        .sink
        {
            [weak self] status in
            if status == .paused
            {
                self?.Playing = false
            }
            else if status == .playing
            {
                self?.Playing = true
            }
            ControlCenter.shared.reloadAllControls()
        }
        .store(in: &PlayerCancellables)
        
        PlayStream.publisher(for: \.currentItem?.status)
        .receive(on: DispatchQueue.main)
        .sink
        {
            [weak self] status in
            if status == .failed
            {
                self?.Playing = false
            }
            ControlCenter.shared.reloadAllControls()
        }
        .store(in: &PlayerCancellables)
        
        
        NotificationCenter.default.publisher(for: .AVPlayerItemFailedToPlayToEndTime)
        .receive(on: DispatchQueue.main)
        .sink
        {
            [weak self] _ in
            self?.Playing = false
            ControlCenter.shared.reloadAllControls()
        }
        .store(in: &PlayerCancellables)
        
        NotificationCenter.default.publisher(for: .AVPlayerItemPlaybackStalled)
        .receive(on: DispatchQueue.main)
        .sink
        {
            [weak self] _ in
            self?.Playing = false
            ControlCenter.shared.reloadAllControls()
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
            [weak self] notification in
            guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else
            {
                return
            }
            if type == .began
            {
                self?.Playing = false
                self?.PlayStream.pause()
            }
            ControlCenter.shared.reloadAllControls()
        }
        .store(in: &SessionCancellables)
        
        NotificationCenter.default.publisher(for: AVAudioSession.silenceSecondaryAudioHintNotification)
        .receive(on: DispatchQueue.main)
        .sink
        {
            [weak self] notification in
            guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionSilenceSecondaryAudioHintTypeKey] as? UInt,
            let type = AVAudioSession.SilenceSecondaryAudioHintType(rawValue: typeValue) else
            {
                return
            }
            if type == .begin
            {
                self?.Playing = false
                self?.PlayStream.pause()
            }
            ControlCenter.shared.reloadAllControls()
        }
        .store(in: &SessionCancellables)
        
        NotificationCenter.default.publisher(for: AVAudioSession.routeChangeNotification)
        .receive(on: DispatchQueue.main)
        .sink
        {
            [weak self] notification in
            guard let userInfo = notification.userInfo,
            let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
            let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else
            {
                return
            }
            if reason == .categoryChange
            {
                if AVAudioSession.sharedInstance().secondaryAudioShouldBeSilencedHint
                {
                    self?.Playing = false
                    self?.PlayStream.pause()
                }
            }
            ControlCenter.shared.reloadAllControls()
        }
        .store(in: &SessionCancellables)
    }
}


struct TaigaStreamWidgetControl1: ControlWidget
{
    var body: some ControlWidgetConfiguration
    {
        StaticControlConfiguration(kind: "xyz.andrewmichaelpowell.taigastream.stream1")
        {
            let isOn = PlayStreamData.SharedResource.Playing && PlayStreamData.SharedResource.CurrentStream == 1
            return ControlWidgetToggle(
                isOn: isOn,
                action: PlayStream1ToggleIntent(),
                label:
                {
                    Label("Stream 1", systemImage: "1.circle")
                }
            )
        }
        .displayName("Stream 1")
    }
}

struct PlayStream1ToggleIntent: SetValueIntent, AudioPlaybackIntent
{
    static let title: LocalizedStringResource = "Stream 1"
    @Parameter(title: "Is On")
    var value: Bool

    @MainActor
    func perform() async throws -> some IntentResult
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
            let isOn = PlayStreamData.SharedResource.Playing && PlayStreamData.SharedResource.CurrentStream == 2
            return ControlWidgetToggle(
                isOn: isOn,
                action: PlayStream2ToggleIntent(),
                label:
                {
                    Label("Stream 2", systemImage: "2.circle")
                }
            )
        }
        .displayName("Stream 2")
    }
}

struct PlayStream2ToggleIntent: SetValueIntent, AudioPlaybackIntent
{
    static let title: LocalizedStringResource = "Stream 2"
    @Parameter(title: "Is On")
    var value: Bool

    @MainActor
    func perform() async throws -> some IntentResult
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
            let isOn = PlayStreamData.SharedResource.Playing && PlayStreamData.SharedResource.CurrentStream == 3
            return ControlWidgetToggle(
                isOn: isOn,
                action: PlayStream3ToggleIntent(),
                label:
                {
                    Label("Stream 3", systemImage: "3.circle")
                }
            )
        }
        .displayName("Stream 3")
    }
}

struct PlayStream3ToggleIntent: SetValueIntent, AudioPlaybackIntent
{
    static let title: LocalizedStringResource = "Stream 3"
    @Parameter(title: "Is On")
    var value: Bool

    @MainActor
    func perform() async throws -> some IntentResult
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
            let isOn = PlayStreamData.SharedResource.Playing && PlayStreamData.SharedResource.CurrentStream == 4
            return ControlWidgetToggle(
                isOn: isOn,
                action: PlayStream4ToggleIntent(),
                label:
                {
                    Label("Stream 4", systemImage: "4.circle")
                }
            )
        }
        .displayName("Stream 4")
    }
}

struct PlayStream4ToggleIntent: SetValueIntent, AudioPlaybackIntent
{
    static let title: LocalizedStringResource = "Stream 4"
    @Parameter(title: "Is On")
    var value: Bool

    @MainActor
    func perform() async throws -> some IntentResult
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
            let isOn = PlayStreamData.SharedResource.Playing && PlayStreamData.SharedResource.CurrentStream == 5
            return ControlWidgetToggle(
                isOn: isOn,
                action: PlayStream5ToggleIntent(),
                label:
                {
                    Label("Stream 5", systemImage: "5.circle")
                }
            )
        }
        .displayName("Stream 5")
    }
}

struct PlayStream5ToggleIntent: SetValueIntent, AudioPlaybackIntent
{
    static let title: LocalizedStringResource = "Stream 5"
    @Parameter(title: "Is On")
    var value: Bool

    @MainActor
    func perform() async throws -> some IntentResult
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
            let isOn = PlayStreamData.SharedResource.Playing && PlayStreamData.SharedResource.CurrentStream == 6
            return ControlWidgetToggle(
                isOn: isOn,
                action: PlayStream6ToggleIntent(),
                label:
                {
                    Label("Stream 6", systemImage: "6.circle")
                }
            )
        }
        .displayName("Stream 6")
    }
}

struct PlayStream6ToggleIntent: SetValueIntent, AudioPlaybackIntent
{
    static let title: LocalizedStringResource = "Stream 6"
    @Parameter(title: "Is On")
    var value: Bool

    @MainActor
    func perform() async throws -> some IntentResult
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
            let isOn = PlayStreamData.SharedResource.Playing && PlayStreamData.SharedResource.CurrentStream == 7
            return ControlWidgetToggle(
                isOn: isOn,
                action: PlayStream7ToggleIntent(),
                label:
                {
                    Label("Stream 7", systemImage: "7.circle")
                }
            )
        }
        .displayName("Stream 7")
    }
}

struct PlayStream7ToggleIntent: SetValueIntent, AudioPlaybackIntent
{
    static let title: LocalizedStringResource = "Stream 7"
    @Parameter(title: "Is On")
    var value: Bool

    @MainActor
    func perform() async throws -> some IntentResult
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
            let isOn = PlayStreamData.SharedResource.Playing && PlayStreamData.SharedResource.CurrentStream == 8
            return ControlWidgetToggle(
                isOn: isOn,
                action: PlayStream8ToggleIntent(),
                label:
                {
                    Label("Stream 8", systemImage: "8.circle")
                }
            )
        }
        .displayName("Stream 8")
    }
}

struct PlayStream8ToggleIntent: SetValueIntent, AudioPlaybackIntent
{
    static let title: LocalizedStringResource = "Stream 8"
    @Parameter(title: "Is On")
    var value: Bool

    @MainActor
    func perform() async throws -> some IntentResult
    {
        PlayStreamButton.PlayStreamButtonShared.PlayButton8_Click()
        return .result()
    }
}
