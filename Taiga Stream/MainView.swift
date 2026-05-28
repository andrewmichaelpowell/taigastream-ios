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
        ScrollView
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
            .padding(.horizontal)
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
            .padding(.horizontal)
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
            .padding(.horizontal)
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
            .padding(.horizontal)
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
            .padding(.horizontal)
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
            .padding(.horizontal)
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
            .padding(.horizontal)
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
            .padding(.horizontal)
            HStack
            {
                TextField(PlayStreamDataShared.Stream9, text: $PlayStreamDataShared.Stream9)
                    .font(.body)
                    .padding()
                    .foregroundColor(.white)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color1))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onChange(of: PlayStreamDataShared.Stream9)
                {
                    NSUbiquitousKeyValueStore.default.set(PlayStreamDataShared.Stream9, forKey: "Stream9Key")
                }
                PlayButton9
            }
            .padding(.horizontal)
            HStack
            {
                TextField(PlayStreamDataShared.Stream10, text: $PlayStreamDataShared.Stream10)
                    .font(.body)
                    .padding()
                    .foregroundColor(.white)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color1))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onChange(of: PlayStreamDataShared.Stream10)
                {
                    NSUbiquitousKeyValueStore.default.set(PlayStreamDataShared.Stream10, forKey: "Stream10Key")
                }
                PlayButton10
            }
            .padding(.horizontal)
            HStack
            {
                TextField(PlayStreamDataShared.Stream11, text: $PlayStreamDataShared.Stream11)
                    .font(.body)
                    .padding()
                    .foregroundColor(.white)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color1))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onChange(of: PlayStreamDataShared.Stream11)
                {
                    NSUbiquitousKeyValueStore.default.set(PlayStreamDataShared.Stream11, forKey: "Stream11Key")
                }
                PlayButton11
            }
            .padding(.horizontal)
            HStack
            {
                TextField(PlayStreamDataShared.Stream12, text: $PlayStreamDataShared.Stream12)
                    .font(.body)
                    .padding()
                    .foregroundColor(.white)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color1))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onChange(of: PlayStreamDataShared.Stream12)
                {
                    NSUbiquitousKeyValueStore.default.set(PlayStreamDataShared.Stream12, forKey: "Stream12Key")
                }
                PlayButton12
            }
            .padding(.horizontal)
            HStack
            {
                TextField(PlayStreamDataShared.Stream13, text: $PlayStreamDataShared.Stream13)
                    .font(.body)
                    .padding()
                    .foregroundColor(.white)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color1))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onChange(of: PlayStreamDataShared.Stream13)
                {
                    NSUbiquitousKeyValueStore.default.set(PlayStreamDataShared.Stream13, forKey: "Stream13Key")
                }
                PlayButton13
            }
            .padding(.horizontal)
            HStack
            {
                TextField(PlayStreamDataShared.Stream14, text: $PlayStreamDataShared.Stream14)
                    .font(.body)
                    .padding()
                    .foregroundColor(.white)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color1))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onChange(of: PlayStreamDataShared.Stream14)
                {
                    NSUbiquitousKeyValueStore.default.set(PlayStreamDataShared.Stream14, forKey: "Stream14Key")
                }
                PlayButton14
            }
            .padding(.horizontal)
            HStack
            {
                TextField(PlayStreamDataShared.Stream15, text: $PlayStreamDataShared.Stream15)
                    .font(.body)
                    .padding()
                    .foregroundColor(.white)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color1))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onChange(of: PlayStreamDataShared.Stream15)
                {
                    NSUbiquitousKeyValueStore.default.set(PlayStreamDataShared.Stream15, forKey: "Stream15Key")
                }
                PlayButton15
            }
            .padding(.horizontal)
            HStack
            {
                TextField(PlayStreamDataShared.Stream16, text: $PlayStreamDataShared.Stream16)
                    .font(.body)
                    .padding()
                    .foregroundColor(.white)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color1))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onChange(of: PlayStreamDataShared.Stream16)
                {
                    NSUbiquitousKeyValueStore.default.set(PlayStreamDataShared.Stream16, forKey: "Stream16Key")
                }
                PlayButton16
            }
            .padding(.horizontal)
            HStack
            {
                TextField(PlayStreamDataShared.Stream17, text: $PlayStreamDataShared.Stream17)
                    .font(.body)
                    .padding()
                    .foregroundColor(.white)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color1))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onChange(of: PlayStreamDataShared.Stream17)
                {
                    NSUbiquitousKeyValueStore.default.set(PlayStreamDataShared.Stream17, forKey: "Stream17Key")
                }
                PlayButton17
            }
            .padding(.horizontal)
            HStack
            {
                TextField(PlayStreamDataShared.Stream18, text: $PlayStreamDataShared.Stream18)
                    .font(.body)
                    .padding()
                    .foregroundColor(.white)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color1))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onChange(of: PlayStreamDataShared.Stream18)
                {
                    NSUbiquitousKeyValueStore.default.set(PlayStreamDataShared.Stream18, forKey: "Stream18Key")
                }
                PlayButton18
            }
            .padding(.horizontal)
            HStack
            {
                TextField(PlayStreamDataShared.Stream19, text: $PlayStreamDataShared.Stream19)
                    .font(.body)
                    .padding()
                    .foregroundColor(.white)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color1))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onChange(of: PlayStreamDataShared.Stream19)
                {
                    NSUbiquitousKeyValueStore.default.set(PlayStreamDataShared.Stream19, forKey: "Stream19Key")
                }
                PlayButton19
            }
            .padding(.horizontal)
            HStack
            {
                TextField(PlayStreamDataShared.Stream20, text: $PlayStreamDataShared.Stream20)
                    .font(.body)
                    .padding()
                    .foregroundColor(.white)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color1))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onChange(of: PlayStreamDataShared.Stream20)
                {
                    NSUbiquitousKeyValueStore.default.set(PlayStreamDataShared.Stream20, forKey: "Stream20Key")
                }
                PlayButton20
            }
            .padding(.horizontal)
            HStack
            {
                TextField(PlayStreamDataShared.Stream21, text: $PlayStreamDataShared.Stream21)
                    .font(.body)
                    .padding()
                    .foregroundColor(.white)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color1))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onChange(of: PlayStreamDataShared.Stream21)
                {
                    NSUbiquitousKeyValueStore.default.set(PlayStreamDataShared.Stream21, forKey: "Stream21Key")
                }
                PlayButton21
            }
            .padding(.horizontal)
            HStack
            {
                TextField(PlayStreamDataShared.Stream22, text: $PlayStreamDataShared.Stream22)
                    .font(.body)
                    .padding()
                    .foregroundColor(.white)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color1))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onChange(of: PlayStreamDataShared.Stream22)
                {
                    NSUbiquitousKeyValueStore.default.set(PlayStreamDataShared.Stream22, forKey: "Stream22Key")
                }
                PlayButton22
            }
            .padding(.horizontal)
            HStack
            {
                TextField(PlayStreamDataShared.Stream23, text: $PlayStreamDataShared.Stream23)
                    .font(.body)
                    .padding()
                    .foregroundColor(.white)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color1))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onChange(of: PlayStreamDataShared.Stream23)
                {
                    NSUbiquitousKeyValueStore.default.set(PlayStreamDataShared.Stream23, forKey: "Stream23Key")
                }
                PlayButton23
            }
            .padding(.horizontal)
            HStack
            {
                TextField(PlayStreamDataShared.Stream24, text: $PlayStreamDataShared.Stream24)
                    .font(.body)
                    .padding()
                    .foregroundColor(.white)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color1))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onChange(of: PlayStreamDataShared.Stream24)
                {
                    NSUbiquitousKeyValueStore.default.set(PlayStreamDataShared.Stream24, forKey: "Stream24Key")
                }
                PlayButton24
            }
            .padding(.horizontal)
            HStack
            {
                TextField(PlayStreamDataShared.Stream25, text: $PlayStreamDataShared.Stream25)
                    .font(.body)
                    .padding()
                    .foregroundColor(.white)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color1))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onChange(of: PlayStreamDataShared.Stream25)
                {
                    NSUbiquitousKeyValueStore.default.set(PlayStreamDataShared.Stream25, forKey: "Stream25Key")
                }
                PlayButton25
            }
            .padding(.horizontal)
            HStack
            {
                TextField(PlayStreamDataShared.Stream26, text: $PlayStreamDataShared.Stream26)
                    .font(.body)
                    .padding()
                    .foregroundColor(.white)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color1))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onChange(of: PlayStreamDataShared.Stream26)
                {
                    NSUbiquitousKeyValueStore.default.set(PlayStreamDataShared.Stream26, forKey: "Stream26Key")
                }
                PlayButton26
            }
            .padding(.horizontal)
            HStack
            {
                TextField(PlayStreamDataShared.Stream27, text: $PlayStreamDataShared.Stream27)
                    .font(.body)
                    .padding()
                    .foregroundColor(.white)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color1))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onChange(of: PlayStreamDataShared.Stream27)
                {
                    NSUbiquitousKeyValueStore.default.set(PlayStreamDataShared.Stream27, forKey: "Stream27Key")
                }
                PlayButton27
            }
            .padding(.horizontal)
            HStack
            {
                TextField(PlayStreamDataShared.Stream28, text: $PlayStreamDataShared.Stream28)
                    .font(.body)
                    .padding()
                    .foregroundColor(.white)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color1))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onChange(of: PlayStreamDataShared.Stream28)
                {
                    NSUbiquitousKeyValueStore.default.set(PlayStreamDataShared.Stream28, forKey: "Stream28Key")
                }
                PlayButton28
            }
            .padding(.horizontal)
            HStack
            {
                TextField(PlayStreamDataShared.Stream29, text: $PlayStreamDataShared.Stream29)
                    .font(.body)
                    .padding()
                    .foregroundColor(.white)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color1))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onChange(of: PlayStreamDataShared.Stream29)
                {
                    NSUbiquitousKeyValueStore.default.set(PlayStreamDataShared.Stream29, forKey: "Stream29Key")
                }
                PlayButton29
            }
            .padding(.horizontal)
            HStack
            {
                TextField(PlayStreamDataShared.Stream30, text: $PlayStreamDataShared.Stream30)
                    .font(.body)
                    .padding()
                    .foregroundColor(.white)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color1))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onChange(of: PlayStreamDataShared.Stream30)
                {
                    NSUbiquitousKeyValueStore.default.set(PlayStreamDataShared.Stream30, forKey: "Stream30Key")
                }
                PlayButton30
            }
            .padding(.horizontal)
            HStack
            {
                TextField(PlayStreamDataShared.Stream31, text: $PlayStreamDataShared.Stream31)
                    .font(.body)
                    .padding()
                    .foregroundColor(.white)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color1))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onChange(of: PlayStreamDataShared.Stream31)
                {
                    NSUbiquitousKeyValueStore.default.set(PlayStreamDataShared.Stream31, forKey: "Stream31Key")
                }
                PlayButton31
            }
            .padding(.horizontal)
            HStack
            {
                TextField(PlayStreamDataShared.Stream32, text: $PlayStreamDataShared.Stream32)
                    .font(.body)
                    .padding()
                    .foregroundColor(.white)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color1))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onChange(of: PlayStreamDataShared.Stream32)
                {
                    NSUbiquitousKeyValueStore.default.set(PlayStreamDataShared.Stream32, forKey: "Stream32Key")
                }
                PlayButton32
            }
            .padding(.horizontal)
            Spacer()
        }
        .background(.black)
        .preferredColorScheme(.dark)
    }
    
    private var PlayButton1: some View
    {
        if (PlayStreamDataShared.Playing == true && PlayStreamDataShared.CurrentStream == 1 && PlayStreamDataShared.Stream1 != "")
        {
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton1_Click)
            {
                Text(Image(systemName: "stop.fill"))
                    .font(.title3)
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
                    .font(.title3)
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
                    .font(.title3)
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
                Text(Image(systemName: "stop.fill"))
                    .font(.title3)
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
                    .font(.title3)
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
                    .font(.title3)
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
                Text(Image(systemName: "stop.fill"))
                    .font(.title3)
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
                    .font(.title3)
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
                    .font(.title3)
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
                Text(Image(systemName: "stop.fill"))
                    .font(.title3)
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
                    .font(.title3)
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
                    .font(.title3)
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
                Text(Image(systemName: "stop.fill"))
                    .font(.title3)
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
                    .font(.title3)
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
                    .font(.title3)
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
                Text(Image(systemName: "stop.fill"))
                    .font(.title3)
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
                    .font(.title3)
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
                    .font(.title3)
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
                Text(Image(systemName: "stop.fill"))
                    .font(.title3)
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
                    .font(.title3)
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
                    .font(.title3)
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
                Text(Image(systemName: "stop.fill"))
                    .font(.title3)
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
                    .font(.title3)
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
                    .font(.title3)
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
    
    private var PlayButton9: some View
    {
        if (PlayStreamDataShared.Playing == true && PlayStreamDataShared.CurrentStream == 9 && PlayStreamDataShared.Stream9 != "")
        {
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton9_Click)
            {
                Text(Image(systemName: "stop.fill"))
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color2)
        }
        else if(PlayStreamDataShared.Stream9 == "")
        {
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton9_Click)
            {
                Text("9")
                    .font(.title3)
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
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton9_Click)
            {
                Text("9")
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color1)
        }
    }
    
    private var PlayButton10: some View
    {
        if (PlayStreamDataShared.Playing == true && PlayStreamDataShared.CurrentStream == 10 && PlayStreamDataShared.Stream10 != "")
        {
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton10_Click)
            {
                Text(Image(systemName: "stop.fill"))
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color2)
        }
        else if(PlayStreamDataShared.Stream10 == "")
        {
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton10_Click)
            {
                Text("10")
                    .font(.title3)
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
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton10_Click)
            {
                Text("10")
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color1)
        }
    }
    
    private var PlayButton11: some View
    {
        if (PlayStreamDataShared.Playing == true && PlayStreamDataShared.CurrentStream == 11 && PlayStreamDataShared.Stream11 != "")
        {
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton11_Click)
            {
                Text(Image(systemName: "stop.fill"))
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color2)
        }
        else if(PlayStreamDataShared.Stream11 == "")
        {
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton11_Click)
            {
                Text("11")
                    .font(.title3)
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
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton11_Click)
            {
                Text("11")
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color1)
        }
    }
    
    private var PlayButton12: some View
    {
        if (PlayStreamDataShared.Playing == true && PlayStreamDataShared.CurrentStream == 12 && PlayStreamDataShared.Stream12 != "")
        {
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton12_Click)
            {
                Text(Image(systemName: "stop.fill"))
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color2)
        }
        else if(PlayStreamDataShared.Stream12 == "")
        {
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton12_Click)
            {
                Text("12")
                    .font(.title3)
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
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton12_Click)
            {
                Text("12")
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color1)
        }
    }
    private var PlayButton13: some View
    {
        if (PlayStreamDataShared.Playing == true && PlayStreamDataShared.CurrentStream == 13 && PlayStreamDataShared.Stream13 != "")
        {
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton13_Click)
            {
                Text(Image(systemName: "stop.fill"))
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color2)
        }
        else if(PlayStreamDataShared.Stream13 == "")
        {
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton13_Click)
            {
                Text("13")
                    .font(.title3)
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
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton13_Click)
            {
                Text("13")
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color1)
        }
    }
    
    private var PlayButton14: some View
    {
        if (PlayStreamDataShared.Playing == true && PlayStreamDataShared.CurrentStream == 14 && PlayStreamDataShared.Stream14 != "")
        {
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton14_Click)
            {
                Text(Image(systemName: "stop.fill"))
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color2)
        }
        else if(PlayStreamDataShared.Stream14 == "")
        {
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton14_Click)
            {
                Text("14")
                    .font(.title3)
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
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton14_Click)
            {
                Text("14")
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color1)
        }
    }
    
    private var PlayButton15: some View
    {
        if (PlayStreamDataShared.Playing == true && PlayStreamDataShared.CurrentStream == 15 && PlayStreamDataShared.Stream15 != "")
        {
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton15_Click)
            {
                Text(Image(systemName: "stop.fill"))
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color2)
        }
        else if(PlayStreamDataShared.Stream15 == "")
        {
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton15_Click)
            {
                Text("15")
                    .font(.title3)
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
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton15_Click)
            {
                Text("15")
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color1)
        }
    }
    
    private var PlayButton16: some View
    {
        if (PlayStreamDataShared.Playing == true && PlayStreamDataShared.CurrentStream == 16 && PlayStreamDataShared.Stream16 != "")
        {
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton16_Click)
            {
                Text(Image(systemName: "stop.fill"))
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color2)
        }
        else if(PlayStreamDataShared.Stream16 == "")
        {
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton16_Click)
            {
                Text("16")
                    .font(.title3)
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
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton16_Click)
            {
                Text("16")
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color1)
        }
    }
    private var PlayButton17: some View
    {
        if (PlayStreamDataShared.Playing == true && PlayStreamDataShared.CurrentStream == 17 && PlayStreamDataShared.Stream17 != "")
        {
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton17_Click)
            {
                Text(Image(systemName: "stop.fill"))
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color2)
        }
        else if(PlayStreamDataShared.Stream17 == "")
        {
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton17_Click)
            {
                Text("17")
                    .font(.title3)
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
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton17_Click)
            {
                Text("17")
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color1)
        }
    }
    
    private var PlayButton18: some View
    {
        if (PlayStreamDataShared.Playing == true && PlayStreamDataShared.CurrentStream == 18 && PlayStreamDataShared.Stream18 != "")
        {
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton18_Click)
            {
                Text(Image(systemName: "stop.fill"))
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color2)
        }
        else if(PlayStreamDataShared.Stream18 == "")
        {
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton18_Click)
            {
                Text("18")
                    .font(.title3)
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
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton18_Click)
            {
                Text("18")
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color1)
        }
    }
    
    private var PlayButton19: some View
    {
        if (PlayStreamDataShared.Playing == true && PlayStreamDataShared.CurrentStream == 19 && PlayStreamDataShared.Stream19 != "")
        {
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton19_Click)
            {
                Text(Image(systemName: "stop.fill"))
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color2)
        }
        else if(PlayStreamDataShared.Stream19 == "")
        {
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton19_Click)
            {
                Text("19")
                    .font(.title3)
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
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton19_Click)
            {
                Text("19")
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color1)
        }
    }
    
    private var PlayButton20: some View
    {
        if (PlayStreamDataShared.Playing == true && PlayStreamDataShared.CurrentStream == 20 && PlayStreamDataShared.Stream20 != "")
        {
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton20_Click)
            {
                Text(Image(systemName: "stop.fill"))
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color2)
        }
        else if(PlayStreamDataShared.Stream20 == "")
        {
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton20_Click)
            {
                Text("20")
                    .font(.title3)
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
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton20_Click)
            {
                Text("20")
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color1)
        }
    }
    
    private var PlayButton21: some View
    {
        if (PlayStreamDataShared.Playing == true && PlayStreamDataShared.CurrentStream == 21 && PlayStreamDataShared.Stream21 != "")
        {
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton21_Click)
            {
                Text(Image(systemName: "stop.fill"))
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color2)
        }
        else if(PlayStreamDataShared.Stream21 == "")
        {
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton21_Click)
            {
                Text("21")
                    .font(.title3)
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
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton21_Click)
            {
                Text("21")
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color1)
        }
    }
    
    private var PlayButton22: some View
    {
        if (PlayStreamDataShared.Playing == true && PlayStreamDataShared.CurrentStream == 22 && PlayStreamDataShared.Stream22 != "")
        {
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton22_Click)
            {
                Text(Image(systemName: "stop.fill"))
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color2)
        }
        else if(PlayStreamDataShared.Stream22 == "")
        {
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton22_Click)
            {
                Text("22")
                    .font(.title3)
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
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton22_Click)
            {
                Text("22")
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color1)
        }
    }
    
    private var PlayButton23: some View
    {
        if (PlayStreamDataShared.Playing == true && PlayStreamDataShared.CurrentStream == 23 && PlayStreamDataShared.Stream23 != "")
        {
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton23_Click)
            {
                Text(Image(systemName: "stop.fill"))
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color2)
        }
        else if(PlayStreamDataShared.Stream23 == "")
        {
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton23_Click)
            {
                Text("23")
                    .font(.title3)
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
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton23_Click)
            {
                Text("23")
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color1)
        }
    }
    
    private var PlayButton24: some View
    {
        if (PlayStreamDataShared.Playing == true && PlayStreamDataShared.CurrentStream == 24 && PlayStreamDataShared.Stream24 != "")
        {
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton24_Click)
            {
                Text(Image(systemName: "stop.fill"))
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color2)
        }
        else if(PlayStreamDataShared.Stream24 == "")
        {
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton24_Click)
            {
                Text("24")
                    .font(.title3)
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
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton24_Click)
            {
                Text("24")
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color1)
        }
    }

    private var PlayButton25: some View
    {
        if (PlayStreamDataShared.Playing == true && PlayStreamDataShared.CurrentStream == 25 && PlayStreamDataShared.Stream25 != "")
        {
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton25_Click)
            {
                Text(Image(systemName: "stop.fill"))
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color2)
        }
        else if(PlayStreamDataShared.Stream25 == "")
        {
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton25_Click)
            {
                Text("25")
                    .font(.title3)
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
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton25_Click)
            {
                Text("25")
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color1)
        }
    }

    private var PlayButton26: some View
    {
        if (PlayStreamDataShared.Playing == true && PlayStreamDataShared.CurrentStream == 26 && PlayStreamDataShared.Stream26 != "")
        {
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton26_Click)
            {
                Text(Image(systemName: "stop.fill"))
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color2)
        }
        else if(PlayStreamDataShared.Stream26 == "")
        {
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton26_Click)
            {
                Text("26")
                    .font(.title3)
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
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton26_Click)
            {
                Text("26")
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color1)
        }
    }

    private var PlayButton27: some View
    {
        if (PlayStreamDataShared.Playing == true && PlayStreamDataShared.CurrentStream == 27 && PlayStreamDataShared.Stream27 != "")
        {
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton27_Click)
            {
                Text(Image(systemName: "stop.fill"))
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color2)
        }
        else if(PlayStreamDataShared.Stream27 == "")
        {
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton27_Click)
            {
                Text("27")
                    .font(.title3)
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
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton27_Click)
            {
                Text("27")
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color1)
        }
    }

    private var PlayButton28: some View
    {
        if (PlayStreamDataShared.Playing == true && PlayStreamDataShared.CurrentStream == 28 && PlayStreamDataShared.Stream28 != "")
        {
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton28_Click)
            {
                Text(Image(systemName: "stop.fill"))
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color2)
        }
        else if(PlayStreamDataShared.Stream28 == "")
        {
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton28_Click)
            {
                Text("28")
                    .font(.title3)
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
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton28_Click)
            {
                Text("28")
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color1)
        }
    }

    private var PlayButton29: some View
    {
        if (PlayStreamDataShared.Playing == true && PlayStreamDataShared.CurrentStream == 29 && PlayStreamDataShared.Stream29 != "")
        {
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton29_Click)
            {
                Text(Image(systemName: "stop.fill"))
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color2)
        }
        else if(PlayStreamDataShared.Stream29 == "")
        {
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton29_Click)
            {
                Text("29")
                    .font(.title3)
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
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton29_Click)
            {
                Text("29")
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color1)
        }
    }

    private var PlayButton30: some View
    {
        if (PlayStreamDataShared.Playing == true && PlayStreamDataShared.CurrentStream == 30 && PlayStreamDataShared.Stream30 != "")
        {
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton30_Click)
            {
                Text(Image(systemName: "stop.fill"))
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color2)
        }
        else if(PlayStreamDataShared.Stream30 == "")
        {
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton30_Click)
            {
                Text("30")
                    .font(.title3)
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
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton30_Click)
            {
                Text("30")
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color1)
        }
    }

    private var PlayButton31: some View
    {
        if (PlayStreamDataShared.Playing == true && PlayStreamDataShared.CurrentStream == 31 && PlayStreamDataShared.Stream31 != "")
        {
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton31_Click)
            {
                Text(Image(systemName: "stop.fill"))
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color2)
        }
        else if(PlayStreamDataShared.Stream31 == "")
        {
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton31_Click)
            {
                Text("31")
                    .font(.title3)
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
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton31_Click)
            {
                Text("31")
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color1)
        }
    }

    private var PlayButton32: some View
    {
        if (PlayStreamDataShared.Playing == true && PlayStreamDataShared.CurrentStream == 32 && PlayStreamDataShared.Stream32 != "")
        {
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton32_Click)
            {
                Text(Image(systemName: "stop.fill"))
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color2)
        }
        else if(PlayStreamDataShared.Stream32 == "")
        {
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton32_Click)
            {
                Text("32")
                    .font(.title3)
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
            Button(action: PlayStreamButton.PlayStreamButtonShared.PlayButton32_Click)
            {
                Text("32")
                    .font(.title3)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.circle)
            .tint(Color1)
        }
    }
}
