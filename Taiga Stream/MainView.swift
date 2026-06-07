//  Taiga Stream
//  github.com/andrewmichaelpowell

import SwiftUI

struct MainView: View
{
    @ObservedObject var playStreamDataShared = PlayStreamData.shared

    let color1 = Color(red: 36/255.0, green: 36/255.0, blue: 40/255.0, opacity: 1.0)
    let color2 = Color(red: 2/255.0, green: 218/255.0, blue: 195/255.0, opacity: 1.0)
    let color3 = Color(red: 72/255.0, green: 72/255.0, blue: 80/255.0, opacity: 1.0)

    var body: some View
    {
        ScrollView
        {
            ForEach(1...32, id: \.self)
            {
                streamNumber in
                HStack
                {
                    TextField(
                        playStreamDataShared.streams[streamNumber - 1],
                        text: $playStreamDataShared.streams[streamNumber - 1]
                    )
                    .font(.body)
                    .padding()
                    .foregroundColor(.white)
                    .background(RoundedRectangle(cornerRadius: 10).fill(color1))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onChange(of: playStreamDataShared.streams[streamNumber - 1])
                    {
                        NSUbiquitousKeyValueStore.default.set(
                            playStreamDataShared.streams[streamNumber - 1],
                            forKey: "Stream\(streamNumber)Key"
                        )
                    }

                    PlayButton(streamNumber: streamNumber)
                }
                .padding(.horizontal)
            }
            Spacer()
        }
        .background(.black)
        .preferredColorScheme(.dark)
    }
}

struct PlayButton: View
{
    let streamNumber: Int
    @ObservedObject var data = PlayStreamData.shared

    let Color1 = Color(red: 36/255.0, green: 36/255.0, blue: 40/255.0, opacity: 1.0)
    let Color2 = Color(red: 2/255.0, green: 218/255.0, blue: 195/255.0, opacity: 1.0)
    let Color3 = Color(red: 72/255.0, green: 72/255.0, blue: 80/255.0, opacity: 1.0)

    private var playingStatus: Bool
    {
        data.isPlaying && data.currentStream == streamNumber && data.streams[streamNumber - 1] != ""
    }

    private var dataStatus: Bool
    {
        data.streams[streamNumber - 1] == ""
    }

    var body: some View
    {
        Button(action: { PlayStreamButton.shared.playButtonClick(streamNumber: streamNumber) })
        {
            if playingStatus
            {
                Text(Image(systemName: "stop.fill"))
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            else
            {
                Text("\(streamNumber)")
                    .font(.title3)
                    .foregroundColor(dataStatus ? Color3 : .white)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
        }
        .frame(width: 50, height: 50)
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.circle)
        .tint(playingStatus ? Color2 : Color1)
    }
}
