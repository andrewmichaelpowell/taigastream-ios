import SwiftUI
import AppIntents
import WidgetKit

struct TaigaStreamWidgetControl1: ControlWidget
{
    var body: some ControlWidgetConfiguration
    {
        StaticControlConfiguration(kind: "xyz.andrewmichaelpowell.taigastream.stream1")
        {
            ControlWidgetButton(action: PlayStream1())
            {
                Image(systemName: "1.circle")
            }
        }
        .displayName("Play Stream 1")
    }
    
}

struct TaigaStreamWidgetControl2: ControlWidget
{
    var body: some ControlWidgetConfiguration
    {
        StaticControlConfiguration(kind: "xyz.andrewmichaelpowell.taigastream.stream2")
        {
            ControlWidgetButton(action: PlayStream2())
            {
                Image(systemName: "2.circle")
            }
        }
        .displayName("Play Stream 2")
    }
}

struct TaigaStreamWidgetControl3: ControlWidget
{
    var body: some ControlWidgetConfiguration
    {
        StaticControlConfiguration(kind: "xyz.andrewmichaelpowell.taigastream.stream3")
        {
            ControlWidgetButton(action: PlayStream3())
            {
                Image(systemName: "3.circle")
            }
        }
        .displayName("Play Stream 3")
    }
}

struct TaigaStreamWidgetControl4: ControlWidget
{
    var body: some ControlWidgetConfiguration
    {
        StaticControlConfiguration(kind: "xyz.andrewmichaelpowell.taigastream.stream4")
        {
            ControlWidgetButton(action: PlayStream4())
            {
                Image(systemName: "4.circle")
            }
        }
        .displayName("Play Stream 4")
    }
}

struct TaigaStreamWidgetControl5: ControlWidget
{
    var body: some ControlWidgetConfiguration
    {
        StaticControlConfiguration(kind: "xyz.andrewmichaelpowell.taigastream.stream5")
        {
            ControlWidgetButton(action: PlayStream5())
            {
                Image(systemName: "5.circle")
            }
        }
        .displayName("Play Stream 5")
    }
}

struct TaigaStreamWidgetControl6: ControlWidget
{
    var body: some ControlWidgetConfiguration
    {
        StaticControlConfiguration(kind: "xyz.andrewmichaelpowell.taigastream.stream6")
        {
            ControlWidgetButton(action: PlayStream6())
            {
                Image(systemName: "6.circle")
            }
        }
        .displayName("Play Stream 6")
    }
}

struct TaigaStreamWidgetControl7: ControlWidget
{
    var body: some ControlWidgetConfiguration
    {
        StaticControlConfiguration(kind: "xyz.andrewmichaelpowell.taigastream.stream7")
        {
            ControlWidgetButton(action: PlayStream7())
            {
                Image(systemName: "7.circle")
            }
        }
        .displayName("Play Stream 7")
    }
}

struct TaigaStreamWidgetControl8: ControlWidget
{
    var body: some ControlWidgetConfiguration
    {
        StaticControlConfiguration(kind: "xyz.andrewmichaelpowell.taigastream.stream8")
        {
            ControlWidgetButton(action: PlayStream8())
            {
                Image(systemName: "8.circle")
            }
        }
        .displayName("Play Stream 8")
    }
}

struct PlayStream1: AppIntent
{
    static let title: LocalizedStringResource = "Play Stream 1"
    
    func perform() async throws -> some IntentResult
    {
        // Code that performs the action...
        return .result()
    }
}

struct PlayStream2: AppIntent
{
    static let title: LocalizedStringResource = "Play Stream 2"

    func perform() async throws -> some IntentResult
    {
        // Code that performs the action...
        return .result()
    }
}

struct PlayStream3: AppIntent
{
    static let title: LocalizedStringResource = "Play Stream 3"

    func perform() async throws -> some IntentResult
    {
        // Code that performs the action...
        return .result()
    }
}

struct PlayStream4: AppIntent
{
    static let title: LocalizedStringResource = "Play Stream 4"
    
    func perform() async throws -> some IntentResult
    {
        // Code that performs the action...
        return .result()
    }
}

struct PlayStream5: AppIntent
{
    static let title: LocalizedStringResource = "Play Stream 5"
    
    func perform() async throws -> some IntentResult
    {
        // Code that performs the action...
        return .result()
    }
}

struct PlayStream6: AppIntent
{
    static let title: LocalizedStringResource = "Play Stream 6"
    
    func perform() async throws -> some IntentResult
    {
        // Code that performs the action...
        return .result()
    }
}

struct PlayStream7: AppIntent
{
    static let title: LocalizedStringResource = "Play Stream 7"
            
    func perform() async throws -> some IntentResult
    {
            // Code that performs the action...
        return .result()
    }
}
            
struct PlayStream8: AppIntent
{
    static let title: LocalizedStringResource = "Play Stream 8"
                    
    func perform() async throws -> some IntentResult
    {
        // Code that performs the action...
        return .result()
    }
}
