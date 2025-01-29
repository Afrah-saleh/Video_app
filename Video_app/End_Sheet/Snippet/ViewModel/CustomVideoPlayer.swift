//
//  CustomVideoPlayer.swift
//  1
//
//  Created by Afrah Saleh on 27/07/1446 AH.
//
import SwiftUI
import AVKit
// MARK: - CustomVideoPlayer
struct CustomVideoPlayer: UIViewControllerRepresentable {
    let player: AVPlayer

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let viewController = AVPlayerViewController()
        viewController.player = player
        viewController.showsPlaybackControls = false
        viewController.videoGravity = .resizeAspectFill
        return viewController
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player = player
    }
}
