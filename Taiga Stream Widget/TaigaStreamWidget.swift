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
