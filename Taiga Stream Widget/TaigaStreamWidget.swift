//  Taiga Stream
//  github.com/andrewmichaelpowell

import SwiftUI
import AppIntents
import WidgetKit

struct TaigaStreamWidgetControl1: ControlWidget
{
    var body: some ControlWidgetConfiguration
    {
        StaticControlConfiguration(kind: "xyz.andrewmichaelpowell.taigastream.stream1")
        {
            let isOn = PlayStreamData.shared.Playing && PlayStreamData.shared.CurrentStream == 1
            return ControlWidgetToggle(
                isOn: isOn,
                action: PlayStream1ToggleIntent(),
                label:
                {
                    Label("Stream 1", systemImage: "1.circle")
                }
            )
        }
        .displayName("Play Stream 1")
    }
}

struct PlayStream1ToggleIntent: SetValueIntent, AudioPlaybackIntent {
    static let title: LocalizedStringResource = "Toggle Stream 1"
    @Parameter(title: "Is On")
    var value: Bool

    @MainActor
    func perform() async throws -> some IntentResult {
        PlayStreamButton.shared.PlayButton1_Click()
        ControlCenter.shared.reloadAllControls()        
        return .result()
    }
}
    
struct TaigaStreamWidgetControl2: ControlWidget
{
    var body: some ControlWidgetConfiguration
    {
        StaticControlConfiguration(kind: "xyz.andrewmichaelpowell.taigastream.stream2")
        {
            let isOn = PlayStreamData.shared.Playing && PlayStreamData.shared.CurrentStream == 2
            return ControlWidgetToggle(
                isOn: isOn,
                action: PlayStream2ToggleIntent(),
                label:
                {
                    Label("Stream 2", systemImage: "2.circle")
                }
            )
        }
        .displayName("Play Stream 2")
    }
}

struct PlayStream2ToggleIntent: SetValueIntent, AudioPlaybackIntent {
    static let title: LocalizedStringResource = "Toggle Stream 2"
    @Parameter(title: "Is On")
    var value: Bool

    @MainActor
    func perform() async throws -> some IntentResult {
        PlayStreamButton.shared.PlayButton2_Click()
        ControlCenter.shared.reloadAllControls()
        return .result()
    }
}
    
struct TaigaStreamWidgetControl3: ControlWidget
{
    var body: some ControlWidgetConfiguration
    {
        StaticControlConfiguration(kind: "xyz.andrewmichaelpowell.taigastream.stream3")
        {
            let isOn = PlayStreamData.shared.Playing && PlayStreamData.shared.CurrentStream == 3
            return ControlWidgetToggle(
                isOn: isOn,
                action: PlayStream3ToggleIntent(),
                label:
                {
                    Label("Stream 3", systemImage: "3.circle")
                }
            )
        }
        .displayName("Play Stream 3")
    }
}

struct PlayStream3ToggleIntent: SetValueIntent, AudioPlaybackIntent {
    static let title: LocalizedStringResource = "Toggle Stream 3"
    @Parameter(title: "Is On")
    var value: Bool

    @MainActor
    func perform() async throws -> some IntentResult {
        PlayStreamButton.shared.PlayButton3_Click()
        ControlCenter.shared.reloadAllControls()
        return .result()
    }
}
    
struct TaigaStreamWidgetControl4: ControlWidget
{
    var body: some ControlWidgetConfiguration
    {
        StaticControlConfiguration(kind: "xyz.andrewmichaelpowell.taigastream.stream4")
        {
            let isOn = PlayStreamData.shared.Playing && PlayStreamData.shared.CurrentStream == 4
            return ControlWidgetToggle(
                isOn: isOn,
                action: PlayStream4ToggleIntent(),
                label:
                {
                    Label("Stream 4", systemImage: "4.circle")
                }
            )
        }
        .displayName("Play Stream 4")
    }
}

struct PlayStream4ToggleIntent: SetValueIntent, AudioPlaybackIntent {
    static let title: LocalizedStringResource = "Toggle Stream 4"
    @Parameter(title: "Is On")
    var value: Bool

    @MainActor
    func perform() async throws -> some IntentResult {
        PlayStreamButton.shared.PlayButton4_Click()
        ControlCenter.shared.reloadAllControls()
        return .result()
    }
}
    
struct TaigaStreamWidgetControl5: ControlWidget
{
    var body: some ControlWidgetConfiguration
    {
        StaticControlConfiguration(kind: "xyz.andrewmichaelpowell.taigastream.stream5")
        {
            let isOn = PlayStreamData.shared.Playing && PlayStreamData.shared.CurrentStream == 5
            return ControlWidgetToggle(
                isOn: isOn,
                action: PlayStream5ToggleIntent(),
                label:
                {
                    Label("Stream 5", systemImage: "5.circle")
                }
            )
        }
        .displayName("Play Stream 5")
    }
}

struct PlayStream5ToggleIntent: SetValueIntent, AudioPlaybackIntent {
    static let title: LocalizedStringResource = "Toggle Stream 5"
    @Parameter(title: "Is On")
    var value: Bool

    @MainActor
    func perform() async throws -> some IntentResult {
        PlayStreamButton.shared.PlayButton5_Click()
        ControlCenter.shared.reloadAllControls()
        return .result()
    }
}
    
struct TaigaStreamWidgetControl6: ControlWidget
{
    var body: some ControlWidgetConfiguration
    {
        StaticControlConfiguration(kind: "xyz.andrewmichaelpowell.taigastream.stream6")
        {
            let isOn = PlayStreamData.shared.Playing && PlayStreamData.shared.CurrentStream == 6
            return ControlWidgetToggle(
                isOn: isOn,
                action: PlayStream6ToggleIntent(),
                label:
                {
                    Label("Stream 6", systemImage: "6.circle")
                }
            )
        }
        .displayName("Play Stream 6")
    }
}

struct PlayStream6ToggleIntent: SetValueIntent, AudioPlaybackIntent {
    static let title: LocalizedStringResource = "Toggle Stream 6"
    @Parameter(title: "Is On")
    var value: Bool

    @MainActor
    func perform() async throws -> some IntentResult {
        PlayStreamButton.shared.PlayButton6_Click()
        ControlCenter.shared.reloadAllControls()
        return .result()
    }
}
    
struct TaigaStreamWidgetControl7: ControlWidget
{
    var body: some ControlWidgetConfiguration
    {
        StaticControlConfiguration(kind: "xyz.andrewmichaelpowell.taigastream.stream7")
        {
            let isOn = PlayStreamData.shared.Playing && PlayStreamData.shared.CurrentStream == 7
            return ControlWidgetToggle(
                isOn: isOn,
                action: PlayStream7ToggleIntent(),
                label:
                {
                    Label("Stream 7", systemImage: "7.circle")
                }
            )
        }
        .displayName("Play Stream 7")
    }
}

struct PlayStream7ToggleIntent: SetValueIntent, AudioPlaybackIntent {
    static let title: LocalizedStringResource = "Toggle Stream 7"
    @Parameter(title: "Is On")
    var value: Bool

    @MainActor
    func perform() async throws -> some IntentResult {
        PlayStreamButton.shared.PlayButton7_Click()
        ControlCenter.shared.reloadAllControls()
        return .result()
    }
}
    
struct TaigaStreamWidgetControl8: ControlWidget
{
    var body: some ControlWidgetConfiguration
    {
        StaticControlConfiguration(kind: "xyz.andrewmichaelpowell.taigastream.stream8")
        {
            let isOn = PlayStreamData.shared.Playing && PlayStreamData.shared.CurrentStream == 8
            return ControlWidgetToggle(
                isOn: isOn,
                action: PlayStream8ToggleIntent(),
                label:
                {
                    Label("Stream 8", systemImage: "8.circle")
                }
            )
        }
        .displayName("Play Stream 8")
    }
}

struct PlayStream8ToggleIntent: SetValueIntent, AudioPlaybackIntent {
    static let title: LocalizedStringResource = "Toggle Stream 8"
    @Parameter(title: "Is On")
    var value: Bool

    @MainActor
    func perform() async throws -> some IntentResult {
        PlayStreamButton.shared.PlayButton8_Click()
        ControlCenter.shared.reloadAllControls()
        return .result()
    }
}
