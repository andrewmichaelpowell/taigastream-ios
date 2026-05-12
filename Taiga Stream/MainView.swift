//  Taiga Stream
//  github.com/andrewmichaelpowell

import SwiftUI
import AVKit
import AVFoundation
import Combine
import WidgetKit

public class PlayStreamData: ObservableObject
{
    static let shared = PlayStreamData()
    private let defaults = UserDefaults(suiteName: "group.xyz.andrewmichaelpowell.taigastream")!
    private var cancellables = Set<AnyCancellable>()
    
    var CurrentStream: Int
    {
        get
        {
            defaults.integer(forKey: "CurrentStreamKey")
        }
        set{
            defaults.set(newValue, forKey: "CurrentStreamKey")
        }
    }

    var Playing: Bool
    {
        get
        {
            defaults.bool(forKey: "PlayingKey")
        }
        set
        {
            defaults.set(newValue, forKey: "PlayingKey")
            objectWillChange.send()
        }
    }

    @Published var PlayStream = AVPlayer()
    {
        didSet
        {
            PlayStreamObserver()
        }
    }
    
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
        PlayStreamObserver()
        InterruptionObserver()
    }

    private func PlayStreamObserver()
    {
        cancellables.removeAll()
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
        .store(in: &cancellables)

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
        .store(in: &cancellables)
    }

    private func InterruptionObserver()
    {
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
            }
            ControlCenter.shared.reloadAllControls()
        }
        .store(in: &cancellables)
        
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
        }
        .store(in: &cancellables)
        
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
            switch reason
            {
                case .categoryChange:
                let session = AVAudioSession.sharedInstance()
                if session.secondaryAudioShouldBeSilencedHint
                {
                    self?.Playing = false
                    self?.PlayStream.pause()
                }
                default: break
            }
            ControlCenter.shared.reloadAllControls()
        }
        .store(in: &cancellables)
    }
}

public class PlayStreamButton
{
    static let shared = PlayStreamButton()
        
    public func PlayButton1_Click()
    {
        guard let StreamURL = URL(string: PlayStreamData.shared.Stream1) else
        {
            return
        }
        PlayStreamData.shared.PlayStream = AVPlayer(playerItem: AVPlayerItem(url: StreamURL))
        if (PlayStreamData.shared.Playing == true && PlayStreamData.shared.CurrentStream == 1)
        {
            PlayStreamData.shared.PlayStream.pause()
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        }
        else
        {
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try? AVAudioSession.sharedInstance().setActive(true)
            PlayStreamData.shared.PlayStream.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
            PlayStreamData.shared.PlayStream.play()
            PlayStreamData.shared.CurrentStream = 1
        }
    }
    
    public func PlayButton2_Click()
    {
        guard let StreamURL = URL(string: PlayStreamData.shared.Stream2) else
        {
            return
        }
        PlayStreamData.shared.PlayStream = AVPlayer(playerItem: AVPlayerItem(url: StreamURL))
        if (PlayStreamData.shared.Playing == true && PlayStreamData.shared.CurrentStream == 2)
        {
            PlayStreamData.shared.PlayStream.pause()
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        }
        else
        {
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try? AVAudioSession.sharedInstance().setActive(true)
            PlayStreamData.shared.PlayStream.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
            PlayStreamData.shared.PlayStream.play()
            PlayStreamData.shared.CurrentStream = 2
        }
    }
    
    public func PlayButton3_Click()
    {
        guard let StreamURL = URL(string: PlayStreamData.shared.Stream3) else
        {
            return
        }
        PlayStreamData.shared.PlayStream = AVPlayer(playerItem: AVPlayerItem(url: StreamURL))
        if (PlayStreamData.shared.Playing == true && PlayStreamData.shared.CurrentStream == 3)
        {
            PlayStreamData.shared.PlayStream.pause()
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        }
        else
        {
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try? AVAudioSession.sharedInstance().setActive(true)
            PlayStreamData.shared.PlayStream.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
            PlayStreamData.shared.PlayStream.play()
            PlayStreamData.shared.CurrentStream = 3
        }
    }
    
    public func PlayButton4_Click()
    {
        guard let StreamURL = URL(string: PlayStreamData.shared.Stream4) else
        {
            return
        }
        PlayStreamData.shared.PlayStream = AVPlayer(playerItem: AVPlayerItem(url: StreamURL))
        if (PlayStreamData.shared.Playing == true && PlayStreamData.shared.CurrentStream == 4)
        {
            PlayStreamData.shared.PlayStream.pause()
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        }
        else
        {
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try? AVAudioSession.sharedInstance().setActive(true)
            PlayStreamData.shared.PlayStream.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
            PlayStreamData.shared.PlayStream.play()
            PlayStreamData.shared.CurrentStream = 4
        }
    }
    
    public func PlayButton5_Click()
    {
        guard let StreamURL = URL(string: PlayStreamData.shared.Stream5) else
        {
            return
        }
        PlayStreamData.shared.PlayStream = AVPlayer(playerItem: AVPlayerItem(url: StreamURL))
        if (PlayStreamData.shared.Playing == true && PlayStreamData.shared.CurrentStream == 5)
        {
            PlayStreamData.shared.PlayStream.pause()
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        }
        else
        {
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try? AVAudioSession.sharedInstance().setActive(true)
            PlayStreamData.shared.PlayStream.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
            PlayStreamData.shared.PlayStream.play()
            PlayStreamData.shared.CurrentStream = 5
        }
    }
    
    public func PlayButton6_Click()
    {
        guard let StreamURL = URL(string: PlayStreamData.shared.Stream6) else
        {
            return
        }
        PlayStreamData.shared.PlayStream = AVPlayer(playerItem: AVPlayerItem(url: StreamURL))
        if (PlayStreamData.shared.Playing == true && PlayStreamData.shared.CurrentStream == 6)
        {
            PlayStreamData.shared.PlayStream.pause()
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        }
        else
        {
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try? AVAudioSession.sharedInstance().setActive(true)
            PlayStreamData.shared.PlayStream.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
            PlayStreamData.shared.PlayStream.play()
            PlayStreamData.shared.CurrentStream = 6
        }
    }

    public func PlayButton7_Click()
    {
        guard let StreamURL = URL(string: PlayStreamData.shared.Stream7) else
        {
            return
        }
        PlayStreamData.shared.PlayStream = AVPlayer(playerItem: AVPlayerItem(url: StreamURL))
        if (PlayStreamData.shared.Playing == true && PlayStreamData.shared.CurrentStream == 7)
        {
            PlayStreamData.shared.PlayStream.pause()
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        }
        else
        {
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try? AVAudioSession.sharedInstance().setActive(true)
            PlayStreamData.shared.PlayStream.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
            PlayStreamData.shared.PlayStream.play()
            PlayStreamData.shared.CurrentStream = 7
        }
    }

    public func PlayButton8_Click()
    {
        guard let StreamURL = URL(string: PlayStreamData.shared.Stream8) else
        {
            return
        }
        PlayStreamData.shared.PlayStream = AVPlayer(playerItem: AVPlayerItem(url: StreamURL))
        if (PlayStreamData.shared.Playing == true && PlayStreamData.shared.CurrentStream == 8)
        {
            PlayStreamData.shared.PlayStream.pause()
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        }
        else
        {
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try? AVAudioSession.sharedInstance().setActive(true)
            PlayStreamData.shared.PlayStream.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
            PlayStreamData.shared.PlayStream.play()
            PlayStreamData.shared.CurrentStream = 8
        }
    }
}

struct MainView: View
{
    @ObservedObject var PlayStreamDataShared = PlayStreamData.shared
    
    let Color1 = Color(red: 36/255.0, green: 36/255.0, blue: 40/255.0, opacity: 1.0)
    let Color2 = Color(red: 2/255.0, green: 218/255.0, blue: 195/255.0, opacity: 1.0)
    let Color3 = Color(red: 72/255.0, green: 72/255.0, blue: 80/255.0, opacity: 1.0)
    
    var body: some View
    {
        NavigationStack
        {
            VStack
            {
                VStack
                {
                    HStack
                    {
                        TextField(PlayStreamDataShared.Stream1, text: $PlayStreamDataShared.Stream1)
                            .font(.body)
                            .padding()
                            .foregroundColor(.white)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color1))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .onChange(of: PlayStreamData.shared.Stream1)
                        {
                            NSUbiquitousKeyValueStore.default.set(PlayStreamDataShared.Stream1, forKey: "Stream1Key")
                        }
                        PlayButton1
                    }
                }
                VStack
                {
                    HStack
                    {
                        TextField(PlayStreamDataShared.Stream2, text: $PlayStreamDataShared.Stream2)
                            .font(.body)
                            .padding()
                            .foregroundColor(.white)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color1))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .onChange(of: PlayStreamDataShared.Stream2)
                        {
                            NSUbiquitousKeyValueStore.default.set(PlayStreamDataShared.Stream2, forKey: "Stream2Key")
                        }
                        PlayButton2
                    }
                }
                VStack
                {
                    HStack
                    {
                        TextField(PlayStreamDataShared.Stream3, text: $PlayStreamDataShared.Stream3)
                            .font(.body)
                            .padding()
                            .foregroundColor(.white)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color1))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .onChange(of: PlayStreamDataShared.Stream3)
                        {
                            NSUbiquitousKeyValueStore.default.set(PlayStreamDataShared.Stream3, forKey: "Stream3Key")
                        }
                        PlayButton3
                    }
                }
                VStack
                {
                    HStack
                    {
                        TextField(PlayStreamDataShared.Stream4, text: $PlayStreamDataShared.Stream4)
                            .font(.body)
                            .padding()
                            .foregroundColor(.white)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color1))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .onChange(of: PlayStreamDataShared.Stream4)
                        {
                            NSUbiquitousKeyValueStore.default.set(PlayStreamDataShared.Stream4, forKey: "Stream4Key")
                        }
                        PlayButton4
                    }
                }
                VStack
                {
                    HStack
                    {
                        TextField(PlayStreamDataShared.Stream5, text: $PlayStreamDataShared.Stream5)
                            .font(.body)
                            .padding()
                            .foregroundColor(.white)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color1))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .onChange(of: PlayStreamDataShared.Stream5)
                        {
                            NSUbiquitousKeyValueStore.default.set(PlayStreamDataShared.Stream5, forKey: "Stream5Key")
                        }
                        PlayButton5
                    }
                }
                VStack
                {
                    HStack
                    {
                        TextField(PlayStreamDataShared.Stream6, text: $PlayStreamDataShared.Stream6)
                            .font(.body)
                            .padding()
                            .foregroundColor(.white)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color1))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .onChange(of: PlayStreamDataShared.Stream6)
                        {
                            NSUbiquitousKeyValueStore.default.set(PlayStreamDataShared.Stream6, forKey: "Stream6Key")
                        }
                        PlayButton6
                    }
                }
                VStack
                {
                    HStack
                    {
                        TextField(PlayStreamDataShared.Stream7, text: $PlayStreamDataShared.Stream7)
                            .font(.body)
                            .padding()
                            .foregroundColor(.white)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color1))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .onChange(of: PlayStreamDataShared.Stream7)
                        {
                            NSUbiquitousKeyValueStore.default.set(PlayStreamDataShared.Stream7, forKey: "Stream7Key")
                        }
                        PlayButton7
                    }
                }
                VStack
                {
                    HStack
                    {
                        TextField(PlayStreamDataShared.Stream8, text: $PlayStreamDataShared.Stream8)
                            .font(.body)
                            .padding()
                            .foregroundColor(.white)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color1))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .onChange(of: PlayStreamDataShared.Stream8)
                        {
                            NSUbiquitousKeyValueStore.default.set(PlayStreamDataShared.Stream8, forKey: "Stream8Key")
                        }
                        PlayButton8
                    }
                }
                Spacer()
            }
        .padding(.horizontal)
        .background(.black)
        .preferredColorScheme(.dark)
        }
    }
    
    private var PlayButton1: some View
    {
        if (PlayStreamDataShared.Playing == true && PlayStreamDataShared.CurrentStream == 1 && PlayStreamDataShared.Stream1 != "")
        {
            Button(action: PlayStreamButton.shared.PlayButton1_Click)
            {
                Text(Image(systemName: "pause.fill"))
                    .font(.title)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color2)
        }
        else if(PlayStreamDataShared.Stream1 == "")
        {
            Button(action: PlayStreamButton.shared.PlayButton1_Click)
            {
                Text("1")
                    .font(.title)
                    .foregroundColor(Color3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color1)
        }
        else
        {
            Button(action: PlayStreamButton.shared.PlayButton1_Click)
            {
                Text("1")
                    .font(.title)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color1)
        }
    }
    
    
    private var PlayButton2: some View
    {
        if (PlayStreamDataShared.Playing == true && PlayStreamDataShared.CurrentStream == 2 && PlayStreamDataShared.Stream2 != "")
        {
            Button(action: PlayStreamButton.shared.PlayButton2_Click)
            {
                Text(Image(systemName: "pause.fill"))
                    .font(.title)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .lineLimit(1)
                    .minimumScaleFactor(1.0)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color2)
        }
        else if(PlayStreamDataShared.Stream2 == "")
        {
            Button(action: PlayStreamButton.shared.PlayButton2_Click)
            {
                Text("2")
                    .font(.title)
                    .foregroundColor(Color3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .lineLimit(1)
                    .minimumScaleFactor(1.0)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color1)
        }
        else
        {
            Button(action: PlayStreamButton.shared.PlayButton2_Click)
            {
                Text("2")
                    .font(.title)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .lineLimit(1)
                    .minimumScaleFactor(1.0)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color1)
        }
    }
    
    private var PlayButton3: some View
    {
        if (PlayStreamDataShared.Playing == true && PlayStreamDataShared.CurrentStream == 3 && PlayStreamDataShared.Stream3 != "")
        {
            Button(action: PlayStreamButton.shared.PlayButton3_Click)
            {
                Text(Image(systemName: "pause.fill"))
                    .font(.title)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .lineLimit(1)
                    .minimumScaleFactor(1.0)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color2)
        }
        else if(PlayStreamDataShared.Stream3 == "")
        {
            Button(action: PlayStreamButton.shared.PlayButton3_Click)
            {
                Text("3")
                    .font(.title)
                    .foregroundColor(Color3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .lineLimit(1)
                    .minimumScaleFactor(1.0)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color1)
        }
        else
        {
            Button(action: PlayStreamButton.shared.PlayButton3_Click)
            {
                Text("3")
                    .font(.title)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .lineLimit(1)
                    .minimumScaleFactor(1.0)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color1)
        }
    }
    
    private var PlayButton4: some View
    {
        if (PlayStreamDataShared.Playing == true && PlayStreamDataShared.CurrentStream == 4 && PlayStreamDataShared.Stream4 != "")
        {
            Button(action: PlayStreamButton.shared.PlayButton4_Click)
            {
                Text(Image(systemName: "pause.fill"))
                    .font(.title)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .lineLimit(1)
                    .minimumScaleFactor(1.0)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color2)
        }
        else if(PlayStreamDataShared.Stream4 == "")
        {
            Button(action: PlayStreamButton.shared.PlayButton4_Click)
            {
                Text("4")
                    .font(.title)
                    .foregroundColor(Color3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .lineLimit(1)
                    .minimumScaleFactor(1.0)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color1)
        }
        else
        {
            Button(action: PlayStreamButton.shared.PlayButton4_Click)
            {
                Text("4")
                    .font(.title)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .lineLimit(1)
                    .minimumScaleFactor(1.0)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color1)
        }
    }
    
    private var PlayButton5: some View
    {
        if (PlayStreamDataShared.Playing == true && PlayStreamDataShared.CurrentStream == 5 && PlayStreamDataShared.Stream5 != "")
        {
            Button(action: PlayStreamButton.shared.PlayButton5_Click)
            {
                Text(Image(systemName: "pause.fill"))
                    .font(.title)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .lineLimit(1)
                    .minimumScaleFactor(1.0)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color2)
        }
        else if(PlayStreamDataShared.Stream5 == "")
        {
            Button(action: PlayStreamButton.shared.PlayButton5_Click)
            {
                Text("5")
                    .font(.title)
                    .foregroundColor(Color3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .lineLimit(1)
                    .minimumScaleFactor(1.0)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color1)
        }
        else
        {
            Button(action: PlayStreamButton.shared.PlayButton5_Click)
            {
                Text("5")
                    .font(.title)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .lineLimit(1)
                    .minimumScaleFactor(1.0)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color1)
        }
    }
    
    private var PlayButton6: some View
    {
        if (PlayStreamDataShared.Playing == true && PlayStreamDataShared.CurrentStream == 6 && PlayStreamDataShared.Stream6 != "")
        {
            Button(action: PlayStreamButton.shared.PlayButton6_Click)
            {
                Text(Image(systemName: "pause.fill"))
                    .font(.title)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .lineLimit(1)
                    .minimumScaleFactor(1.0)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color2)
        }
        else if(PlayStreamDataShared.Stream6 == "")
        {
            Button(action: PlayStreamButton.shared.PlayButton6_Click)
            {
                Text("6")
                    .font(.title)
                    .foregroundColor(Color3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .lineLimit(1)
                    .minimumScaleFactor(1.0)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color1)
        }
        else
        {
            Button(action: PlayStreamButton.shared.PlayButton6_Click)
            {
                Text("6")
                    .font(.title)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .lineLimit(1)
                    .minimumScaleFactor(1.0)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color1)
        }
    }

    private var PlayButton7: some View
    {
        if (PlayStreamDataShared.Playing == true && PlayStreamDataShared.CurrentStream == 7 && PlayStreamDataShared.Stream7 != "")
        {
            Button(action: PlayStreamButton.shared.PlayButton7_Click)
            {
                Text(Image(systemName: "pause.fill"))
                    .font(.title)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .lineLimit(1)
                    .minimumScaleFactor(1.0)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color2)
        }
        else if(PlayStreamDataShared.Stream7 == "")
        {
            Button(action: PlayStreamButton.shared.PlayButton7_Click)
            {
                Text("7")
                    .font(.title)
                    .foregroundColor(Color3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .lineLimit(1)
                    .minimumScaleFactor(1.0)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color1)
        }
        else
        {
            Button(action: PlayStreamButton.shared.PlayButton7_Click)
            {
                Text("7")
                    .font(.title)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .lineLimit(1)
                    .minimumScaleFactor(1.0)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color1)
        }
    }

    private var PlayButton8: some View
    {
        if (PlayStreamDataShared.Playing == true && PlayStreamDataShared.CurrentStream == 8 && PlayStreamDataShared.Stream8 != "")
        {
            Button(action: PlayStreamButton.shared.PlayButton8_Click)
            {
                Text(Image(systemName: "pause.fill"))
                    .font(.title)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .lineLimit(1)
                    .minimumScaleFactor(1.0)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color2)
        }
        else if(PlayStreamDataShared.Stream8 == "")
        {
            Button(action: PlayStreamButton.shared.PlayButton8_Click)
            {
                Text("8")
                    .font(.title)
                    .foregroundColor(Color3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .lineLimit(1)
                    .minimumScaleFactor(1.0)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color1)
        }
        else
        {
            Button(action: PlayStreamButton.shared.PlayButton8_Click)
            {
                Text("8")
                    .font(.title)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .lineLimit(1)
                    .minimumScaleFactor(1.0)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color1)
        }
    }
}
