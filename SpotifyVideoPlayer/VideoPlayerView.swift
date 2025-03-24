//
//  VideoPlayerView.swift
//  SpotifyVideoPlayer
//
//  Created by Ronaldo Avalos on 24/03/25.
//


import SwiftUI
import AVKit

struct VideoPlayerView: View {
    @State var player = AVPlayer()
    var video: String
    var size: CGSize

    var body: some View {
        VideoPlayerUIView(player: player,size: size )
            .onAppear {
                loadVideoFile()
                addLooping()
                player.play()
            }
            .ignoresSafeArea()
    }
    
    func loadVideoFile() {
        guard let bundleID = Bundle.main.path(forResource: video, ofType: "mov") else { return }
        let videoURL = URL(filePath: bundleID)
        let playerItem = AVPlayerItem(url: videoURL)
        player.replaceCurrentItem(with: playerItem)
    }
    
    func addLooping() {
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
            player.seek(to: .zero)
            player.play()
        }
    }
}

struct VideoPlayerUIView: UIViewControllerRepresentable {
    var player: AVPlayer
    var size: CGSize
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
        controller.view.layer.addSublayer(playerLayer)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
