//
//  SnippetPlayerView.swift
//  1
//
//  Created by Afrah Saleh on 27/07/1446 AH.
//
import SwiftUI
import AVKit

struct SnippetPlayerView: View {
    let snippet: (startTime: TimeInterval, endTime: TimeInterval)
    let videoName: String
    var size: CGSize // Respect the dynamic size.

    @State private var player: AVPlayer?
    @State private var isPlaying: Bool = false // Track if this snippet should play
    @State private var progress: Double = 0 // Track progress for the slider
    @State private var isSeeking: Bool = false // Track if the user is seeking
    @State private var isLiked: Bool = false // Track if the snippet is liked

    var index: Int // Pass the snippet's index

    var body: some View {
        ZStack {
            // Background Color
            Color.black.edgesIgnoringSafeArea(.all)

            if let player = player {
                // Video Player
                CustomVideoPlayer(player: player)
                    .frame(width: size.width, height: size.height)
                    .clipped()
                    .onAppear {
                        setupPlayer()
                        updatePlaybackState()
                        startProgressTracking()
                    }
                    .onDisappear {
                        player.pause()
                    }

                // Left-aligned VStack for buttons
                HStack {
                    VStack(spacing: 16) { // Align elements vertically with spacing
                        Spacer()

                        // Profile Button
                        VStack {
                            Image(videoName)
                                .resizable()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())

                        }

                        // Like Button
                        Button(action: {
                            isLiked.toggle() // Toggle the liked state
                        }) {
                            VStack {
                                Image(systemName: isLiked ? "heart.fill" : "heart")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(isLiked ? .white : .white) // Change color when liked
                                Text("Like")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                        }

                        // Share Button
                        Button(action: {
                            print("Shared")
                        }) {
                            VStack {
                                Image(systemName: "square.and.arrow.up")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(.white)

                            }
                        }

                        Spacer()
                    }
                    .padding(.leading, 16) // Align VStack to the left with padding

                    Spacer() // Push buttons to the left edge
                }

                // Bottom-aligned time progress bar
                VStack {
                    Spacer()

                    // Progress Bar with Timer
                    HStack {
                        Text(formatTime(progress * snippetDuration()))
                            .foregroundColor(.white)
                            .font(.caption)

                        Slider(
                            value: Binding(
                                get: { progress },
                                set: { newValue in
                                    progress = newValue
                                    if isSeeking {
                                        let seekTime = snippet.startTime + progress * snippetDuration()
                                        player.seek(to: CMTime(seconds: seekTime, preferredTimescale: 600))
                                    }
                                }
                            ),
                            in: 0...1,
                            onEditingChanged: { editing in
                                isSeeking = editing
                                if !editing {
                                    let seekTime = snippet.startTime + progress * snippetDuration()
                                    player.seek(to: CMTime(seconds: seekTime, preferredTimescale: 600)) { _ in
                                        player.play()
                                    }
                                }
                            }
                        )
                        .accentColor(.white)

                        Text(formatTime(snippetDuration()))
                            .foregroundColor(.white)
                            .font(.caption)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                }
            } else {
                // Placeholder for loading
                Rectangle()
                    .fill(Color.black)
                    .overlay(Text("Loading...").foregroundColor(.white))
            }
        }
        .onAppear {
            setupPlayer()
        }
        .onReceive(NotificationCenter.default.publisher(for: .snippetChanged)) { notification in
            if let userInfo = notification.userInfo as? [String: Int],
               let currentIndex = userInfo["index"] {
                isPlaying = (currentIndex == index)
                updatePlaybackState()
            }
        }
    }
    private func setupPlayer() {
        guard player == nil else { return }
        if let videoURL = Bundle.main.url(forResource: videoName, withExtension: "mp4") {
            let playerItem = AVPlayerItem(url: videoURL)
            let avPlayer = AVPlayer(playerItem: playerItem)

            // Ensure playback starts at 0 and respects the snippet duration
            player = avPlayer
            avPlayer.seek(to: CMTime(seconds: snippet.startTime, preferredTimescale: 600)) { _ in
                if isPlaying { // Only play if the snippet is active
                    avPlayer.play()
                }
            }

            // Observe player time to stop at the snippet's `endTime`
            player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale: 600), queue: .main) { [weak avPlayer] time in
                guard let avPlayer = avPlayer else { return }
                if time.seconds >= snippet.endTime {
                    avPlayer.pause()
                    avPlayer.seek(to: CMTime(seconds: snippet.startTime, preferredTimescale: 600))
                    progress = 0 // Reset progress bar
                    isPlaying = false
                }
            }
        }
    }

    private func updatePlaybackState() {
        guard let player = player else { return }
        if isPlaying {
            player.seek(to: CMTime(seconds: snippet.startTime, preferredTimescale: 600)) { _ in
                player.play()
            }
        } else {
            player.pause()
        }
    }

    private func snippetDuration() -> TimeInterval {
        return snippet.endTime - snippet.startTime // Dynamically calculate the snippet duration
    }

    private func startProgressTracking() {
        guard let player = player else { return }

        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            guard !isSeeking else { return }

            let currentTime = player.currentTime().seconds
            let duration = snippetDuration() // Use the correct snippet duration

            // Stop playback if the snippet's end time is reached
            if currentTime >= snippet.endTime {
                player.pause() // Stop playback
                player.seek(to: CMTime(seconds: snippet.startTime, preferredTimescale: 600)) // Reset to snippet start
                progress = 0 // Reset progress bar
                isPlaying = false // Mark as stopped
                timer.invalidate() // Stop the timer
            } else {
                // Update progress dynamically
                progress = max(0, min(1, (currentTime - snippet.startTime) / duration))
            }
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
