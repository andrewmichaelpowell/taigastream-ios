//  Taiga Stream
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
    @State private var Stream5:String = UserDefaults.standard.string(forKey: "Stream5Key") ?? ""
    @State private var Stream6:String = UserDefaults.standard.string(forKey: "Stream6Key") ?? ""
    @State private var Stream7:String = UserDefaults.standard.string(forKey: "Stream7Key") ?? ""
    @State private var Stream8:String = UserDefaults.standard.string(forKey: "Stream8Key") ?? ""
    
    @State private var Playing: Bool = false
    @State private var CurrentStream:Int = 1
    
    @State private var PlayStream = AVPlayer()
    
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
                        PlayButton1
                    }
                }
                VStack
                {
                    HStack
                    {
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
                        PlayButton2
                    }
                }
                VStack
                {
                    HStack
                    {
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
                        PlayButton3
                    }
                }
                VStack
                {
                    HStack
                    {
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
                        PlayButton4
                    }
                }
                VStack
                {
                    HStack
                    {
                        TextField(Stream5, text: $Stream5)
                            .font(.body)
                            .padding()
                            .foregroundColor(.white)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color1))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .onChange(of: Stream5)
                        {
                            UserDefaults.standard.set(Stream5, forKey: "Stream5Key")
                        }
                        PlayButton5
                    }
                }
                VStack
                {
                    HStack
                    {
                        TextField(Stream6, text: $Stream6)
                            .font(.body)
                            .padding()
                            .foregroundColor(.white)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color1))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .onChange(of: Stream6)
                        {
                            UserDefaults.standard.set(Stream6, forKey: "Stream6Key")
                        }
                        PlayButton6
                    }
                }
                VStack
                {
                    HStack
                    {
                        TextField(Stream7, text: $Stream7)
                            .font(.body)
                            .padding()
                            .foregroundColor(.white)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color1))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .onChange(of: Stream7)
                        {
                            UserDefaults.standard.set(Stream7, forKey: "Stream7Key")
                        }
                        PlayButton7
                    }
                }
                VStack
                {
                    HStack
                    {
                        TextField(Stream8, text: $Stream8)
                            .font(.body)
                            .padding()
                            .foregroundColor(.white)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color1))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .onChange(of: Stream8)
                        {
                            UserDefaults.standard.set(Stream8, forKey: "Stream8Key")
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
        if (Playing == true && CurrentStream == 1 && Stream1 != "")
        {
            Button(action: PlayButton1_Click)
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
        else if(Stream1 == "")
        {
            Button(action: PlayButton1_Click)
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
            Button(action: PlayButton1_Click)
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
        else if(Stream2 == "")
        {
            Button(action: PlayButton2_Click)
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
            Button(action: PlayButton2_Click)
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
        else if(Stream3 == "")
        {
            Button(action: PlayButton3_Click)
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
            Button(action: PlayButton3_Click)
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
        else if(Stream4 == "")
        {
            Button(action: PlayButton4_Click)
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
            Button(action: PlayButton4_Click)
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
    
    private var PlayButton5: some View
    {
        if (Playing == true && CurrentStream == 5 && Stream5 != "")
        {
            Button(action: PlayButton5_Click)
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
        else if(Stream5 == "")
        {
            Button(action: PlayButton5_Click)
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
            Button(action: PlayButton5_Click)
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
    
    private func PlayButton5_Click()
    {
        guard let StreamURL = URL(string: Stream5) else
        {
            return
        }
        PlayStream = AVPlayer(playerItem: AVPlayerItem(url: StreamURL))
        if (Playing == true && CurrentStream == 5)
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
            CurrentStream = 5
        }
    }
    
    private var PlayButton6: some View
    {
        if (Playing == true && CurrentStream == 6 && Stream6 != "")
        {
            Button(action: PlayButton6_Click)
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
        else if(Stream6 == "")
        {
            Button(action: PlayButton6_Click)
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
            Button(action: PlayButton6_Click)
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

    private func PlayButton6_Click()
    {
        guard let StreamURL = URL(string: Stream6) else
        {
            return
        }
        PlayStream = AVPlayer(playerItem: AVPlayerItem(url: StreamURL))
        if (Playing == true && CurrentStream == 6)
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
            CurrentStream = 6
        }
    }

    private var PlayButton7: some View
    {
        if (Playing == true && CurrentStream == 7 && Stream7 != "")
        {
            Button(action: PlayButton7_Click)
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
        else if(Stream7 == "")
        {
            Button(action: PlayButton7_Click)
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
            Button(action: PlayButton7_Click)
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

    private func PlayButton7_Click()
    {
        guard let StreamURL = URL(string: Stream7) else
        {
            return
        }
        PlayStream = AVPlayer(playerItem: AVPlayerItem(url: StreamURL))
        if (Playing == true && CurrentStream == 7)
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
            CurrentStream = 7
        }
    }

    private var PlayButton8: some View
    {
        if (Playing == true && CurrentStream == 8 && Stream8 != "")
        {
            Button(action: PlayButton8_Click)
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
        else if(Stream8 == "")
        {
            Button(action: PlayButton8_Click)
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
            Button(action: PlayButton8_Click)
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

    private func PlayButton8_Click()
    {
        guard let StreamURL = URL(string: Stream8) else
        {
            return
        }
        PlayStream = AVPlayer(playerItem: AVPlayerItem(url: StreamURL))
        if (Playing == true && CurrentStream == 8)
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
            CurrentStream = 8
        }
    }
}
