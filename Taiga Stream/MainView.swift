//  Taiga Stream
//  github.com/andrewmichaelpowell

import SwiftUI

struct MainView: View
{
	@ObservedObject var streamInfo = StreamInfo.shared
	
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
						streamInfo.stream[streamNumber - 1],
						text: $streamInfo.stream[streamNumber - 1]
					)
					.font(.body)
					.padding()
					.foregroundColor(.white)
					.background(RoundedRectangle(cornerRadius: 10).fill(color1))
					.frame(maxWidth: .infinity, alignment: .leading)
					.autocapitalization(.none)
					.disableAutocorrection(true)
					.onChange(of: streamInfo.stream[streamNumber - 1])
					{
						NSUbiquitousKeyValueStore.default.set(
							streamInfo.stream[streamNumber - 1],
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
	@ObservedObject var streamInfo = StreamInfo.shared
	
	let color1 = Color(red: 36/255.0, green: 36/255.0, blue: 40/255.0, opacity: 1.0)
	let color2 = Color(red: 2/255.0, green: 218/255.0, blue: 195/255.0, opacity: 1.0)
	let color3 = Color(red: 72/255.0, green: 72/255.0, blue: 80/255.0, opacity: 1.0)
	
	private var isPlaying: Bool
	{
		streamInfo.isPlaying && streamInfo.currentStream == streamNumber && streamInfo.stream[streamNumber - 1] != ""
	}
	
	private var isConfigured: Bool
	{
		streamInfo.stream[streamNumber - 1] == ""
	}
	
	var body: some View
	{
		Button(action: { PlayStream.shared.play(streamNumber: streamNumber) })
		{
			if isPlaying
			{
				Text(Image(systemName: "stop.fill"))
					.font(.title3)
					.frame(maxWidth: .infinity, maxHeight: 50)
			}
			else
			{
				Text("\(streamNumber)")
					.font(.title3)
					.foregroundColor(isConfigured ? color3 : .white)
					.frame(maxWidth: .infinity, maxHeight: 50)
			}
		}
		.frame(width: 50, height: 50)
		.buttonStyle(.borderedProminent)
		.buttonBorderShape(.circle)
		.tint(isPlaying ? color2 : color1)
	}
}
