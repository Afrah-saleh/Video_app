
import SwiftUI
import AVKit


struct FullscreenPlayerView: View {
    @Environment(\.presentationMode) var presentationMode
    var player: AVPlayer
    @Binding var currentSubtitle: String
    @Binding var subtitles: [(startTime: TimeInterval, endTime: TimeInterval, text: String)]
    @Binding var savedSubtitles: [(startTime: TimeInterval, endTime: TimeInterval, text: String)]
    @Binding var savedSnippets: [(startTime: TimeInterval, endTime: TimeInterval)]
    @State private var isPlaying = true
    @State private var progress: Double = 0.0

    @State private var snippetDuration: TimeInterval = 15
    @State private var showingSaveAnimation = false
    @State private var animationText = ""
    // --- حالات للتحكم بالـ Popup الخاص باللقطات ---
    @State var showSnippetPopup: Bool = false
    @State var showEndButton: Bool = false // New state for showing the button
    @State private var snippetThumbnail: UIImage? = nil
    @State private var snippetMessage: String = ""
    var videoName: String
    var videoLink: String
    var videoN: String
    @State var isSnippetSheetPresented = false
    @State private var showControls = true // Controls visibility state
    @State private var controlsTimer: Timer? // Timer to hide controls after 2 seconds

    var body: some View {
        ZStack {

            PlayerWithSubtitlesView(
                player: player,
                currentSubtitle: $currentSubtitle,
                subtitles: $subtitles,
                showingSaveAnimation: $showingSaveAnimation
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .edgesIgnoringSafeArea(.all)
            
            HStack(spacing: 50) {
                if showControls {
                    // Skip Backward
                    Button(action: {
                        let targetTime = max(player.currentTime().seconds - 15, 0)
                        player.seek(to: CMTime(seconds: targetTime, preferredTimescale: 600))
                    }) {
                        Image(systemName: "gobackward.15")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.white)
                    }
                    // Play/Pause Button
                    Button(action: togglePlayback) {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    // Skip Forward
                    Button(action: {
                        let targetTime = player.currentTime().seconds + 15
                        player.seek(to: CMTime(seconds: targetTime, preferredTimescale: 600))
                    }) {
                        Image(systemName: "goforward.15")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.white)
                    }
                }
            }

                // End Button Overlay
                Group {
                    if showEndButton {
                        Button(action: {
                            isSnippetSheetPresented = true // Show the sheet on button click
                        }) {
                            HStack {
                                Text("عرض محفوظاتي")
                                    .font(.caption)
                                    .foregroundColor(.black)
                                
                                Image("arrow")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20) // Adjust the size as needed
                            }
                            .padding(.horizontal, 10) // Smaller horizontal padding
                            .padding(.vertical, 5)    // Smaller vertical padding
                        }
                        .background(
                            Image("backgroundShape") // Use your background shape image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 20) // Adjust height of the background
                        )
                        .shadow(color: .gray.opacity(0.5), radius: 4, x: 0, y: 2)
                        .padding(.trailing, 16) // Adjust distance from the right edge
                              .padding(.bottom, 80)   // **Increased bottom padding to move it above**
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    }
                    
                }
          
            
            
            
            // Tap to show/hide controls
            if showControls {
                VStack {
                    // Top Section (Title and Close Button)
                    HStack {
                        Button(action: {
                           // presentationMode.wrappedValue.dismiss() // Close fullscreen
                            exitFullscreen() // Dismiss fullscreen
                        }) {
                            Image(systemName: "arrow.down.right.and.arrow.up.left") //  exit fullscreen icon

                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        Text("فنجان") // Video title
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.trailing, 16)
                        Spacer()
                        
                        // Chapter Selector
                        Menu {
                            Button("المقدمه", action: {})
                            Button("التعريف", action: {})
                        } label: {
                            HStack(spacing: 5) {
                                Text("فواصل الحلقه")
                                    .foregroundColor(.white)
                                    .font(.system(size: 14))
                                Image(systemName: "chevron.down")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 10, height: 10)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.top, 16)
                    .padding(.horizontal, 16)
                    Spacer()
                    
                    // Playback Controls
                    VStack(spacing: 10) {
                        // Progress Bar
                        if showSnippetPopup {
                            SnippetPopupView(
                                thumbnail: snippetThumbnail,
                                snippetDuration: Int(snippetMessage) ?? 0
                            ) {
                                showSnippetPopup = false
                            }
                        }
                        ZStack {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.gray.opacity(0.5))
                                .frame(height: 4)
                            
                            Slider(value: $progress, in: 0...1, onEditingChanged: { isEditing in
                                if !isEditing {
                                    seekVideo(to: progress)
                                }
                            })
                            .accentColor(.white)
                        }
                        .padding(.horizontal, 14)
                        
                        // Time Stamps
                        HStack {
                            Text(formatTime(player.currentTime().seconds)) // Current Time
                                .foregroundColor(.white)
                                .font(.caption)
                            
                            Spacer()
                            
                            Text("-\(formatTime((player.currentItem?.duration.seconds ?? 0) - player.currentTime().seconds))") // Remaining Time
                                .foregroundColor(.white)
                                .font(.caption)
                            
          
                        }
                        .padding(.horizontal, 16)
                        
                        
                        // Snippet and Subtitle Buttons
                        HStack(spacing: 100) {
                            
                            Button(action: {}) {
                                Image("f2")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.white)
                            }
                            // زر حفظ اللقطة
                            Button(action: {
                                let snippetStart = player.currentTime().seconds
                                let remainingDuration = (player.currentItem?.duration.seconds ?? 0) - snippetStart
                                let snippetEnd = snippetStart + min(snippetDuration, remainingDuration)
                                
                                // حفظ اللقطة
                                savedSnippets.append((startTime: snippetStart, endTime: snippetEnd))
                                
                                // توليد الصورة المصغرة
                                if let url = Bundle.main.url(forResource: videoName, withExtension: "mp4") {
                                    if let thumbnail = generateThumbnail(for: url, at: snippetStart) {
                                        snippetThumbnail = thumbnail
                                    }
                                }
                                
                                // احسب مدة اللقطة
                                let durationInSeconds = Int(snippetEnd - snippetStart)
                                
                                snippetMessage = "\(durationInSeconds)"
                                
                                showSnippetPopup = true
                                
                            }) {
                                Image("f4")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.white)
                            }
                            // Like Button
                            Button(action: {}) {
                                Image(systemName: "heart")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 22, height: 22)
                                    .foregroundColor(.white)
                            }
                            // Share Button
                            Button(action: {}) {
                                Image(systemName: "square.and.arrow.up")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 22, height: 22)
                                    .foregroundColor(.white)
                            }
                            
                            // Save Current Subtitle Button
                            Button(action: saveCurrentSubtitle) {
                                Image("f3") // Replace with your asset name
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.white)
                            }
                
         
                        }
                        .padding(.top, 10)
                    }
                    
                    .padding(.bottom, 20)
                    .background(Color.black.opacity(0.7))
                }
            }
        }
        .onTapGesture {
              toggleControls() // Show/hide controls on tap
          }

        .onAppear {
            setupProgressObserver()
            if !isPlaying {
                player.play()
            }
            isPlaying = true

            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: player.currentItem,
                queue: .main
            ) { _ in
                showEndButton = true // Show the end button when the video ends
            }
        }
        .onDisappear {
            removeProgressObserver()
            requestPortraitOrientation()

        }
        // EndSheet Presentation
        .sheet(isPresented: $isSnippetSheetPresented) {
           
            EndSheetView(
                savedSubtitles: $savedSubtitles,
                savedSnippets: $savedSnippets,
                videoLink: videoLink,
                videoName: videoName,
                videoN: videoN
            )
            .onAppear {
                requestPortraitOrientation() // Lock orientation to portrait when sheet appears
            }
            
        }
    }
    
    func saveCurrentSubtitle() {
        let currentTime = player.currentTime().seconds
        if let subtitle = subtitles.first(where: { currentTime >= $0.startTime && currentTime <= $0.endTime }) {
            savedSubtitles.append(subtitle) // Save the subtitle
            showingSaveAnimation = true

            // Reset the animation state after it completes
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showingSaveAnimation = false
            }
        }
    }


    // MARK: - Generate Thumbnail
    func generateThumbnail(for url: URL, at time: TimeInterval) -> UIImage? {
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        do {
            let cgImage = try generator.copyCGImage(at: cmTime, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            print("Error generating thumbnail: \(error)")
            return nil
        }
    }

    private func togglePlayback() {
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
    }

    private func seekVideo(to progress: Double) {
        let duration = player.currentItem?.duration.seconds ?? 0
        let targetTime = progress * duration
        player.seek(to: CMTime(seconds: targetTime, preferredTimescale: 600))
    }

    private func setupProgressObserver() {
        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: .main) { time in
            let currentTime = time.seconds
            let duration = player.currentItem?.duration.seconds ?? 1
            progress = currentTime / duration
        }
    }

    private func removeProgressObserver() {
        // Clean up periodic time observers
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let seconds = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - Control Logic
    private func toggleControls() {
        withAnimation {
            showControls.toggle() // Show or hide the controls
        }
        startControlsTimer() // Reset the timer whenever the user taps
    }

    private func startControlsTimer() {
        controlsTimer?.invalidate() // Invalidate any existing timer
        controlsTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
            withAnimation {
                showControls = false // Hide the controls after 2 seconds
            }
        }
    }
    private func exitFullscreen() {
        withAnimation {
            presentationMode.wrappedValue.dismiss()
        }
    }
    // MARK: - Orientation Handling
    private func requestLandscapeOrientation() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        let geometryPreferences = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: .landscapeRight)

        windowScene.requestGeometryUpdate(geometryPreferences) { error in
            if let error = error as? Error {
                print("Error requesting geometry update: \(error.localizedDescription)")
            }
        }
    }

    private func requestPortraitOrientation() {
        (UIApplication.shared.delegate as? AppDelegate)?.orientationLock = .portrait
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        let geometryPreferences = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: .portrait)

        windowScene.requestGeometryUpdate(geometryPreferences) { error in
            if let error = error as? Error {
                print("Error requesting geometry update: \(error.localizedDescription)")
            }
        }
    }
}
