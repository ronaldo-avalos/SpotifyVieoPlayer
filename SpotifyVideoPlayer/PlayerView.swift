//
//  PlayerView.swift
//  SpotifyVideoPlayer
//
//  Created by Ronaldo Avalos on 24/03/25.
//

import SwiftUI

struct PlayerView: View {
    
    var safeArea: EdgeInsets
    var size: CGSize
    let videos: [Video] = [
        .init(videoID: "video 1"),
        .init(videoID: "video 2"),
        .init(videoID: "video 3"),
    ]
   
    
    @State var value : Double = 0.0
    @State var tatalDuration: Double = 251.0
    @State var isPlaying: Bool = true
    @State var timer: Timer?
    @State var currentlyShownVideo: Video = .init(videoID: "video 1")
    @State var currentSong: Song = Song.songs.first!
    @State private var currentIndex: Int = 0

    var body: some View {
        VStack {
            ZStack {
                ScrollView {
                    VStack {
                        BackgroundVideoView()
                            .overlay(alignment:.bottom) {
                                VStack {
                                    NameSongView()
                                    SpotifySlider()
                                    ControlsPlayers()
                                }.frame(height: 300)
                                .padding(24)
                                .background {
                                        LinearGradient(colors: [
                                            .clear,
                                            .clear.opacity(0.5),
                                            .black.opacity(0.6),
                                            .black.opacity(0.8),
                                            .black.opacity(0.9),
                                            .black
                                        ], startPoint: .top, endPoint: .bottom)
                                    }
                            }
                        VStack(spacing:24) {
                            LyricsView()
                            AboutArtistView()
                            MerchView()
                        }.padding(12)
                    }
                    .overlay {
                        HeaderView()
                    }
                }
                .scrollIndicators(.hidden)
                .coordinateSpace(name: "SCROLL")
                .safeAreaPadding(EdgeInsets(top: 0, leading: 0, bottom: safeArea.bottom + 100, trailing: 0))
                
            }
            .ignoresSafeArea()
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
        .onChange(of: isPlaying) { _, playing in
            playing ? startTimer() : stopTimer()
        }
        .onChange(of: currentlyShownVideo) { oldValue, newValue in
            if let song = Song.songs.first(where: { $0.video.videoID == newValue.videoID }) {
                currentSong = song
                value = 0.0
            }
        }

    }
    
    @ViewBuilder
    func HeaderView() -> some View {
        let height = size.height * 0.25
        GeometryReader { proxy in
            let minY = proxy.frame(in: .named("SCROLL")).minY
            let progress = (minY / (height * 2.6) * -1)
            
            ZStack {
                VStack(alignment: .leading, spacing: 8) {
                    Spacer()
                    HStack {
                        ScrollView(.horizontal) {
                            HStack {
                                Text(currentSong.name + " •")
                                    .font(.title3.bold())
                                HStack {
                                    ForEach(currentSong.artist, id:\.self) { artis in
                                        Text(artis != currentSong.artist.last ? "\(artis),":artis)
                                            .font(.subheadline.bold())
                                            .foregroundStyle(.gray)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                           
                        HStack(spacing:24) {
                            Image(.songadded)
                                .resizable()
                                .frame(width: 24,height: 24)
                            Image(systemName: "pause.fill")
                                .foregroundStyle(.white)
                                .font(.title2)
                        }
                        .padding(.horizontal,14)
                    }
                    HStack(spacing:4) {
                        Image(systemName: "speaker.wave.2.circle")
                            .font(.subheadline)
                            .foregroundStyle(.green)
                        Text("Web Player(Safari)")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                    .padding(.horizontal)
                    Rectangle().fill(.white.opacity(0.5))
                        .frame(height: 2)
                        .overlay(alignment: .leading) {
                            Rectangle().fill(.white)
                                .frame(width: 200,height: 2)
                        }
                }
                .frame(height: 130)
                .background(.regularMaterial)
                .opacity(progress > 1 ? 1 : 0)
            }
            .frame(maxWidth: .infinity)
            .offset(y: -minY - 5)
        }
    }
    
    @ViewBuilder
    func BackgroundVideoView() -> some View {
        let height = size.height
        GeometryReader { g in
            let size = g.size
            TabView(selection: $currentlyShownVideo) {
                ForEach(videos, id: \.self) { video in
                    VideoPlayerView(
                        currentlyShowingVideo: $currentlyShownVideo,
                        video: video,
                        size: size)
                    .tag(video)
                    
                }
                
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
        }.frame(height: height + safeArea.top)
    }
    
    @ViewBuilder
    func NameSongView() -> some View {
        VStack(alignment:.leading) {
            Label("Switch to video", systemImage: "play.rectangle")
                .font(.caption.bold())
                .foregroundStyle(.white)
                .padding(10)
                .background(.black.opacity(0.6))
                .cornerRadius(18)
            
            HStack {
                Image(currentSong.albumImage)
                    .resizable()
                    .cornerRadius(10)
                    .frame(width: 50,height: 50)
                VStack(alignment:.leading) {
                    Text(currentSong.name)
                        .font(.title.bold())
                    HStack(spacing: 2) {
                        ForEach(currentSong.artist, id:\.self) { artis in
                            Text(artis != currentSong.artist.last ? "\(artis),":artis)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.gray)
                        }
                    }
                }
                Spacer()
                Image(.songadded)
            }
        }
    }
    
    @ViewBuilder
    func SpotifySlider() -> some View {
        VStack {
            Slider(value: $value, in: 0...tatalDuration)
                .tint(.white)
            HStack {
                Text(formatTime(value))
                    .font(.caption)
                    .foregroundStyle(.gray)
                Spacer()
                Text("-" + formatTime(tatalDuration - value))
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
        }
    }
    
    @ViewBuilder
    func ControlsPlayers() -> some View {
        VStack {
            HStack(spacing:54) {
                Image(.shuffle)
                HStack(spacing:24) {
                    Button {
                        previousSong()
                    } label: {
                        Image(.previous)
                    }
                    Button {
                        isPlaying.toggle()
                    } label: {
                        Circle()
                            .fill(.white)
                            .overlay {
                                Image(isPlaying ? .pause : .play)
                            }
                    }
                    Button {
                        nextSong()
                    } label: {
                        Image(.next)

                    }
                }
                Image(.repeat)
            }
            HStack {
                Image(.connectToADevice)
                Spacer()
                Image(.share)
                    .padding(.trailing)
                Image(.queue)
            }
        }
    }
    
    @ViewBuilder
    func LyricsView() -> some View {
        VStack {
            HStack {
                Text("Lyrics")
                    .font(.system(size: 16,weight: .black))
                Spacer()
                Circle().fill(.regularMaterial)
                    .frame(width: 32)
                    .overlay {
                        Image(.share)
                            .resizable()
                            .frame(width: 16,height: 16)
                    }
                Circle().fill(.regularMaterial)
                    .frame(width: 32)
                    .overlay {
                        Image(.fullScreen)
                            .resizable()
                            .frame(width: 16,height: 16)
                    }
            }.padding([.horizontal,.top])
            VStack(alignment:.leading) {
                Text(currentSong.lyric1)
                    .font(.system(size: 24,weight: .bold))
                ZStack(alignment:.leading) {
                    Text(currentSong.lyric2)
                        .lineLimit(1)
                        .font(.system(size: 24,weight: .bold))
                        .foregroundStyle(.black)
                    Rectangle().fill(
                        LinearGradient.init(colors: [
                            .clear,
                            .clear.opacity(0.4),
                            currentSong.color.opacity(0.5),
                            currentSong.color
                        ], startPoint: .top, endPoint: .bottom)
                    )
                    .frame(height: 26)
                }
            }.padding()
            
        }
        .background(currentSong.color)
        .cornerRadius(18)
        
    }
    
    @ViewBuilder
    func AboutArtistView() -> some View {
        VStack {
            VStack {
                ZStack(alignment:.topLeading) {
                    Image(currentSong.about)
                        .resizable()
                        .scaledToFill()
                    Text("About the artist")
                        .font(.system(size: 16,weight: .bold))
                        .padding()
                        .padding(.top,24)
                }.frame(height: 200)
                VStack {
                    HStack {
                        VStack(alignment:.leading) {
                            Text(currentSong.artist.first ?? "Artis")
                                .font(.title2.bold())
                            Text("\(currentSong.listenersMonthly)M monthly listeners")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text("Follow")
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                            .padding(.vertical,10)
                            .padding(.horizontal)
                            .overlay {
                                RoundedRectangle(cornerRadius:50)
                                    .strokeBorder(Color.white.opacity(0.3),lineWidth: 1)
                            }
                        
                    }
                    .padding()
                    Text("Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding([.horizontal,.bottom])
                }.padding(.top)
            }
            
        }.background(Color.gray.opacity(0.2))
            .cornerRadius(18)
    }
    
    @ViewBuilder
    func MerchView() -> some View {
        let items: [MerchItem] = [
            MerchItem(image: "Merch", title: "MAYHEM 188 Zoetrope Vinyl"),
            MerchItem(image: "Merch", title: "MAYHEM CD Box Set"),
            MerchItem(image: "Merch", title: "MAYHEM 162 Picture Disc")
        ]
        
        
        VStack {
            HStack {
                Text("Merch")
                    .font(.system(size: 16,weight: .bold))
                Spacer()
                Text("Go to store")
                    .font(.subheadline.bold())
                    .foregroundStyle(.green)
            }.padding()
            ForEach(items) { item in
                HStack {
                    Image(item.image)
                        .resizable()
                        .frame(width: 50,height: 50)
                        .background(.white)
                        .cornerRadius(10)
                        .padding(.trailing,6)
                    Text(item.title)
                        .foregroundStyle(.white)
                        .fontWeight(.bold)
                        .lineLimit(1)
                    Spacer()
                    Image(systemName: "chevron.right")
                    
                }.padding([.horizontal,.bottom])
            }
        }.background(.gray.opacity(0.2))
            .cornerRadius(18)
    }
    
    func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes,seconds)
    }
    
    func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            if isPlaying, value < tatalDuration {
                value += 1
            } else {
                stopTimer()
            }
        })
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func nextSong() {
        if currentIndex < Song.songs.count - 1 {
            currentIndex += 1
            updateCurrentSongAndVideo()
        }
    }

    func previousSong() {
        if currentIndex > 0 {
            currentIndex -= 1
            updateCurrentSongAndVideo()
        }
    }
    
    func updateCurrentSongAndVideo() {
        let newSong = Song.songs[currentIndex]
        currentSong = newSong
        currentlyShownVideo = newSong.video
    }


}

struct MerchItem: Identifiable {
    let id = UUID()
    let image: String
    let title: String
}

#Preview {
    ContentView()
}
