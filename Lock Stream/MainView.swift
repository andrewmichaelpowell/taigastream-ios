//  Lock Stream
//  github.com/andrewmichaelpowell

import SwiftUI
import AVKit
import AVFoundation

struct MainView: View
{
        
    @State private var Stream1:String = UserDefaults.standard.string(forKey: "Stream1Key") ?? ""
    @State private var Stream2:String = UserDefaults.standard.string(forKey: "Stream2Key") ?? ""
    @State private var Stream3:String = UserDefaults.standard.string(forKey: "Stream3Key") ?? ""
    @State private var Stream4:String = UserDefaults.standard.string(forKey: "Stream4Key") ?? ""

    @State private var Playing: Bool = false
    @State private var CurrentStream:Int = 1

    @State private var PlayStream = AVPlayer()
    
    let Color1 = Color(red: 36/255.0, green: 36/255.0, blue: 40/255.0, opacity: 1.0)
    let Color2 = Color(red: 109/255.0, green: 124/255.0, blue: 255/255.0, opacity: 1.0)
    let Color3 = Color(red: 2/255.0, green: 218/255.0, blue: 195/255.0, opacity: 1.0)
    
    var body: some View
    {
        NavigationStack
        {
            VStack
            {
                Spacer()
                VStack
                {
                    Text("Stream 1 URL")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    TextField(Stream1, text: $Stream1)
                        .font(.body)
                        .padding()
                        .foregroundColor(.white)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color1))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .onChange(of: Stream1)
                    {
                        UserDefaults.standard.set(Stream1, forKey: "Stream1Key")
                    }
                }
                VStack
                {
                    Text("Stream 2 URL")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    TextField(Stream2, text: $Stream2)
                        .font(.body)
                        .padding()
                        .foregroundColor(.white)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color1))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .onChange(of: Stream2)
                    {
                        UserDefaults.standard.set(Stream2, forKey: "Stream2Key")
                    }
                }
                VStack
                {
                    Text("Stream 3 URL")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    TextField(Stream3, text: $Stream3)
                        .font(.body)
                        .padding()
                        .foregroundColor(.white)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color1))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .onChange(of: Stream3)
                    {
                        UserDefaults.standard.set(Stream3, forKey: "Stream3Key")
                    }
                }
                VStack
                {
                    Text("Stream 4 URL")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    TextField(Stream4, text: $Stream4)
                        .font(.body)
                        .padding()
                        .foregroundColor(.white)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color1))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .onChange(of: Stream4)
                    {
                        UserDefaults.standard.set(Stream4, forKey: "Stream4Key")
                    }
                }
                VStack
                {
                }
                .padding(.vertical)
                VStack
                {
                    HStack
                    {
                        PlayButton1
                        PlayButton2
                        PlayButton3
                        PlayButton4
                    }
                }
                VStack
                {
                }
                .padding(.vertical)
            }
            .padding(.horizontal)
            .background(.black)
            .preferredColorScheme(.dark)
        }
    }
    
    private var PlayButton1: some View
    {
        if (Playing == true && CurrentStream == 1 && Stream1 != "")
        {
            Button(action: PlayButton1_Click)
            {
                Text("1")
                    .font(.title)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color3)
        }
        else if(Stream1 == "")
        {
            Button(action: PlayButton1_Click)
            {
                Text("1")
                    .font(.title)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color1)
        }
        else
        {
            Button(action: PlayButton1_Click)
            {
                Text("1")
                    .font(.title)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color2)
        }
    }
    
    private func PlayButton1_Click()
    {
        guard let StreamURL = URL(string: Stream1) else
        {
            return
        }
        PlayStream = AVPlayer(playerItem: AVPlayerItem(url: StreamURL))
        if (Playing == true && CurrentStream == 1)
        {
            PlayStream.pause()
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            Playing = false
        }
        else
        {
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try? AVAudioSession.sharedInstance().setActive(true)
            PlayStream.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
            PlayStream.play()
            Playing = true
            CurrentStream = 1
        }
    }
    
    private var PlayButton2: some View
    {
        if (Playing == true && CurrentStream == 2 && Stream2 != "")
        {
            Button(action: PlayButton2_Click)
            {
                Text("2")
                    .font(.title)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .lineLimit(1)
                    .minimumScaleFactor(1.0)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color3)
        }
        else if(Stream2 == "")
        {
            Button(action: PlayButton2_Click)
            {
                Text("2")
                    .font(.title)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .lineLimit(1)
                    .minimumScaleFactor(1.0)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color1)
        }
        else
        {
            Button(action: PlayButton2_Click)
            {
                Text("2")
                    .font(.title)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .lineLimit(1)
                    .minimumScaleFactor(1.0)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color2)
        }
    }

    private func PlayButton2_Click()
    {
        guard let StreamURL = URL(string: Stream2) else
        {
            return
        }
        PlayStream = AVPlayer(playerItem: AVPlayerItem(url: StreamURL))
        if (Playing == true && CurrentStream == 2)
        {
            PlayStream.pause()
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            Playing = false
        }
        else
        {
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try? AVAudioSession.sharedInstance().setActive(true)
            PlayStream.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
            PlayStream.play()
            Playing = true
            CurrentStream = 2
        }
    }

    private var PlayButton3: some View
    {
        if (Playing == true && CurrentStream == 3 && Stream3 != "")
        {
            Button(action: PlayButton3_Click)
            {
                Text("3")
                    .font(.title)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .lineLimit(1)
                    .minimumScaleFactor(1.0)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color3)
        }
        else if(Stream3 == "")
        {
            Button(action: PlayButton3_Click)
            {
                Text("3")
                    .font(.title)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .lineLimit(1)
                    .minimumScaleFactor(1.0)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color1)
        }
        else
        {
            Button(action: PlayButton3_Click)
            {
                Text("3")
                    .font(.title)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .lineLimit(1)
                    .minimumScaleFactor(1.0)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color2)
        }
    }

    private func PlayButton3_Click()
    {
        guard let StreamURL = URL(string: Stream3) else
        {
            return
        }
        PlayStream = AVPlayer(playerItem: AVPlayerItem(url: StreamURL))
        if (Playing == true && CurrentStream == 3)
        {
            PlayStream.pause()
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            Playing = false
        }
        else
        {
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try? AVAudioSession.sharedInstance().setActive(true)
            PlayStream.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
            PlayStream.play()
            Playing = true
            CurrentStream = 3
        }
    }

    private var PlayButton4: some View
    {
        if (Playing == true && CurrentStream == 4 && Stream4 != "")
        {
            Button(action: PlayButton4_Click)
            {
                Text("4")
                    .font(.title)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .lineLimit(1)
                    .minimumScaleFactor(1.0)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color3)
        }
        else if(Stream4 == "")
        {
            Button(action: PlayButton4_Click)
            {
                Text("4")
                    .font(.title)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .lineLimit(1)
                    .minimumScaleFactor(1.0)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color1)
        }
        else
        {
            Button(action: PlayButton4_Click)
            {
                Text("4")
                    .font(.title)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .lineLimit(1)
                    .minimumScaleFactor(1.0)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color2)
        }
    }

    private func PlayButton4_Click()
    {
        guard let StreamURL = URL(string: Stream4) else
        {
            return
        }
        PlayStream = AVPlayer(playerItem: AVPlayerItem(url: StreamURL))
        if (Playing == true && CurrentStream == 4)
        {
            PlayStream.pause()
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            Playing = false
        }
        else
        {
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try? AVAudioSession.sharedInstance().setActive(true)
            PlayStream.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
            PlayStream.play()
            Playing = true
            CurrentStream = 4
        }
    }
}
