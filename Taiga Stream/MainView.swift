//  Taiga Stream
//  github.com/andrewmichaelpowell

import SwiftUI

struct MainView: View
{
    @ObservedObject var PlayStreamDataShared = PlayStreamData.SharedResource
    
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
                            .onChange(of: PlayStreamData.SharedResource.Stream1)
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
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton1_Click)
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
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton1_Click)
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
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton1_Click)
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
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton2_Click)
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
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton2_Click)
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
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton2_Click)
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
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton3_Click)
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
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton3_Click)
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
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton3_Click)
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
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton4_Click)
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
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton4_Click)
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
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton4_Click)
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
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton5_Click)
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
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton5_Click)
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
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton5_Click)
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
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton6_Click)
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
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton6_Click)
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
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton6_Click)
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
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton7_Click)
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
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton7_Click)
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
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton7_Click)
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
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton8_Click)
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
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton8_Click)
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
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton8_Click)
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
