//
//  PlayerWithSubtitlesView.swift
//  1
//
//  Created by Afrah Saleh on 19/07/1446 AH.
//

import SwiftUI
import AVKit

struct PlayerWithSubtitlesView: UIViewControllerRepresentable {
    var player: AVPlayer
    @Binding var currentSubtitle: String
    @Binding var subtitles: [(startTime: TimeInterval, endTime: TimeInterval, text: String)]
    @Binding var showingSaveAnimation: Bool
    
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.showsPlaybackControls = false

        // Add the subtitle overlay
        context.coordinator.addSubtitleOverlay(to: playerViewController)
        
        // Observe fullscreen changes
        context.coordinator.observeFullscreenChanges(playerViewController)
        
        // Start the subtitle observer
        context.coordinator.startSubtitleObserver()
        
        return playerViewController
    }
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        if let subtitleLabel = uiViewController.contentOverlayView?.viewWithTag(100) as? UILabel {
            subtitleLabel.text = currentSubtitle
            subtitleLabel.isHidden = currentSubtitle.isEmpty
        }

        context.coordinator.updateSaveAnimation(showingSaveAnimation, on: uiViewController)
    }

    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: PlayerWithSubtitlesView
        private weak var playerViewController: AVPlayerViewController?
        private var timeObserverToken: Any?
        private var fallbackTimer: Timer?
        private var wasPlayingBeforeFullscreen = false
        
        init(_ parent: PlayerWithSubtitlesView) {
            self.parent = parent
        }
        

        func addSubtitleOverlay(to playerViewController: AVPlayerViewController) {
            self.playerViewController = playerViewController

            guard let overlayView = playerViewController.contentOverlayView else { return }
            // Remove any existing subtitle overlay to avoid duplication
            if let existingLabel = overlayView.viewWithTag(100) {
                existingLabel.removeFromSuperview()
            }
            if overlayView.viewWithTag(100) != nil { return }

            // Container view for animations
            let containerView = UIView()
            containerView.translatesAutoresizingMaskIntoConstraints = false
            containerView.tag = 99
            overlayView.addSubview(containerView)

            let subtitleLabel = UILabel()
            subtitleLabel.textAlignment = .center
            subtitleLabel.font = UIFont.boldSystemFont(ofSize: 15)
            subtitleLabel.textColor = .black
            subtitleLabel.backgroundColor =  UIColor(Color("subtitles"))
            subtitleLabel.layer.cornerRadius = 2
            subtitleLabel.layer.masksToBounds = true
            subtitleLabel.numberOfLines = 0
            subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
            subtitleLabel.tag = 100

            containerView.addSubview(subtitleLabel)

            // Save message label
            let saveLabel = UILabel()
            saveLabel.text = "حفظنا إقتباسك"
            saveLabel.textAlignment = .center
            saveLabel.font = UIFont.boldSystemFont(ofSize: 15) // Increase font size
            saveLabel.textColor = .white
           // saveLabel.backgroundColor = UIColor(Color("orange1"))
            if let orangeColor = UIColor(named: "orange1") {
                print("orange1 color loaded successfully")
                saveLabel.backgroundColor = orangeColor
            } else {
                print("orange1 color not found, using fallback")
                saveLabel.backgroundColor = .orange // Fallback to default orange color
            }
            saveLabel.layer.cornerRadius = 10 // Adjust for larger appearance
            saveLabel.layer.masksToBounds = true
            saveLabel.alpha = 0
            saveLabel.translatesAutoresizingMaskIntoConstraints = false
            saveLabel.tag = 101

            containerView.addSubview(saveLabel)

            NSLayoutConstraint.activate([
                containerView.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
                containerView.bottomAnchor.constraint(equalTo: overlayView.bottomAnchor, constant: -70),
                containerView.leadingAnchor.constraint(greaterThanOrEqualTo: overlayView.leadingAnchor),
                containerView.trailingAnchor.constraint(lessThanOrEqualTo: overlayView.trailingAnchor),

                subtitleLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
                subtitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
                subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),

                saveLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                saveLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
                saveLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 150), // Increase minimum width
                saveLabel.heightAnchor.constraint(equalToConstant: 30) // Increase height
                
                
            ])
        }
        func startSubtitleObserver() {
            guard let player = playerViewController?.player else { return }
            
            // Stop the existing observer to avoid duplicates
            stopSubtitleObserver()
            
            // Add a periodic time observer
            timeObserverToken = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale: 600), queue: .main) { [weak self] time in
                self?.updateCurrentSubtitle(currentTime: time.seconds)
            }
            
            // Add a fallback timer for robustness
            fallbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                if let currentTime = player.currentItem?.currentTime().seconds {
                    self.updateCurrentSubtitle(currentTime: currentTime)
                }
            }
        }
        func updateSaveAnimation(_ showingSaveAnimation: Bool, on playerViewController: AVPlayerViewController) {
            guard let overlayView = playerViewController.contentOverlayView,
                  let subtitleLabel = overlayView.viewWithTag(100),
                  let saveLabel = overlayView.viewWithTag(101) as? UILabel,
                  let player = playerViewController.player else { return }

            if showingSaveAnimation {
                // Pause the video and keep the current subtitle displayed
                let originalRate = player.rate
                player.pause()

                // Create a gradient scanning overlay
                let scanningOverlay = UIView()
                scanningOverlay.translatesAutoresizingMaskIntoConstraints = false

                // Retrieve color from assets
                let orangeColor = UIColor(named: "orange1") ?? UIColor.orange

                // Add gradient layer to the scanning overlay
                let gradientLayer = CAGradientLayer()
                gradientLayer.colors = [
                    UIColor.clear.cgColor, // Transparent start
                    orangeColor.withAlphaComponent(0.7).cgColor, // Bright orange from assets
                    UIColor.clear.cgColor // Transparent end
                ]
                gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
                gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
                gradientLayer.frame = subtitleLabel.bounds
                scanningOverlay.layer.addSublayer(gradientLayer)

                subtitleLabel.addSubview(scanningOverlay)

                NSLayoutConstraint.activate([
                    scanningOverlay.leadingAnchor.constraint(equalTo: subtitleLabel.leadingAnchor, constant: -subtitleLabel.frame.width),
                    scanningOverlay.topAnchor.constraint(equalTo: subtitleLabel.topAnchor),
                    scanningOverlay.bottomAnchor.constraint(equalTo: subtitleLabel.bottomAnchor),
                    scanningOverlay.widthAnchor.constraint(equalTo: subtitleLabel.widthAnchor)
                ])
                subtitleLabel.layoutIfNeeded()

                // Animate the scanning effect
                UIView.animate(withDuration: 0.8, delay: 0, options: [.curveEaseInOut], animations: {
                    scanningOverlay.transform = CGAffineTransform(translationX: subtitleLabel.frame.width * 2, y: 0)
                }, completion: { _ in
                    scanningOverlay.removeFromSuperview()

                    // After the scanning effect, hide the subtitle and show the save message
                    subtitleLabel.isHidden = true

                    // Display the saveLabel
                    UIView.animate(withDuration: 0.2, animations: {
                        saveLabel.alpha = 1
                    }) { _ in
                        self.addStarsEffect(around: saveLabel)

                        // Keep the saveLabel visible for 3 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            // Hide the saveLabel and resume playback
                            UIView.animate(withDuration: 0.2, animations: {
                                saveLabel.alpha = 0
                            }) { _ in
                                // Show the subtitle again and resume video playback
                                subtitleLabel.isHidden = false
                                if originalRate > 0 {
                                    player.play()
                                }
                            }
                        }
                    }
                })
            }
        }
        private func addStarsEffect(around label: UILabel) {
            guard let superview = label.superview else { return }

            // Set up positions for the stars
            let leftStarPosition = CGPoint(x: label.frame.minX - 10, y: label.center.y - 15) // Left star closer to the label
            let rightStarPosition = CGPoint(x: label.frame.maxX + 10, y: label.center.y - 15) // Right star closer to the label

            // Add and fade the left star
            if let leftStarImage = UIImage(named: "star1") { // Replace "star1" with your asset name
                addSingleStar(image: leftStarImage, position: leftStarPosition, superview: superview)
            }

            // Add and fade the right star
            if let rightStarImage = UIImage(named: "star2") { // Replace "star2" with your asset name
                addSingleStar(image: rightStarImage, position: rightStarPosition, superview: superview)
            }
        }

        // Helper function to add and fade a single star
        private func addSingleStar(image: UIImage, position: CGPoint, superview: UIView) {
            let starView = UIImageView(image: image)
            starView.frame = CGRect(x: 0, y: 0, width: 24, height: 24) // Set the size of the star
            starView.center = position
            starView.alpha = 0 // Start fully transparent
            superview.addSubview(starView)

            // Animate the star to appear and fade out
            UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: {
                starView.alpha = 1.0 // Fade in
            }, completion: { _ in
                UIView.animate(withDuration: 0.5, delay: 0.5, options: [], animations: {
                    starView.alpha = 0 // Fade out
                }, completion: { _ in
                    starView.removeFromSuperview() // Remove the star after the animation completes
                })
            })
        }

        func stopSubtitleObserver() {
            if let player = playerViewController?.player, let token = timeObserverToken {
                player.removeTimeObserver(token)
                timeObserverToken = nil
            }
            fallbackTimer?.invalidate()
            fallbackTimer = nil
        }
        
        func updateCurrentSubtitle(currentTime: TimeInterval) {
            if let subtitle = parent.subtitles.first(where: { currentTime >= $0.startTime && currentTime <= $0.endTime }) {
                parent.currentSubtitle = subtitle.text
            } else {
                parent.currentSubtitle = ""
            }
        }
        
        func observeFullscreenChanges(_ playerViewController: AVPlayerViewController) {
            NotificationCenter.default.addObserver(
                forName: UIWindow.didBecomeVisibleNotification,
                object: playerViewController.view.window,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.handleFullscreenEnter()
            }
            
            NotificationCenter.default.addObserver(
                forName: UIWindow.didBecomeHiddenNotification,
                object: playerViewController.view.window,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.handleFullscreenExit()
            }
        }
        
        private func handleFullscreenEnter() {
            guard let player = playerViewController?.player else { return }
            
            // Save the current playback state
            wasPlayingBeforeFullscreen = player.timeControlStatus == .playing
            
            // Ensure the video plays if it was playing before
            if wasPlayingBeforeFullscreen {
                player.play()
            }
            
            // Check if subtitle overlay already exists
            if playerViewController?.contentOverlayView?.viewWithTag(100) == nil {
                addSubtitleOverlay(to: playerViewController!)
            }
            
            // Restart the subtitle observer
            startSubtitleObserver()
        }
        
        private func handleFullscreenExit() {
            guard let player = playerViewController?.player else { return }
            
            // Restore the playback state
            if wasPlayingBeforeFullscreen {
                player.play()
            }
            
            // Reinitialize subtitle observer if necessary
            startSubtitleObserver()
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self)
            stopSubtitleObserver()
        }
    }
}
