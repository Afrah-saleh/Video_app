//
//  videoPlayer-utilties.swift
//  1
//
//  Created by Afrah Saleh on 27/07/1446 AH.
//
import SwiftUI
import AVKit
import UIKit
import TipKit // أضف المكتبة
// MARK: - الإضافات الخاصة بعرض الفيديو

 extension VideoPlayerView {
    
    var videoDisplaySection: some View {
        Group {
            if isAudioMode {
                Image("placeholder")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 300)
                    .clipped()
            } else {
                PlayerWithSubtitlesView(
                    player: player,
                    currentSubtitle: $currentSubtitle,
                    subtitles: $subtitles,
                    showingSaveAnimation: $showingSaveAnimation
                )
                .frame(height: 300)
            }
        }
    }

    var controlButtonsSection: some View {
        VStack {
            
            HStack(alignment: .center) {
                    Button(action: {
                    FullscreenPlayerView(
                        player: player,
                        currentSubtitle: $currentSubtitle,
                        subtitles: $subtitles,
                        savedSubtitles: $savedSubtitles,
                        savedSnippets: $savedSnippets,
                        videoName: videoName,
                        videoLink: videoLink,
                        videoN: videoN
                    )

                    .edgesIgnoringSafeArea(.all)
                    .presentInLandscape() // Present in landscape using custom hosting controller
//                    .presentInLandscape {
//                        // Reset to portrait after dismissing
//                        (UIApplication.shared.delegate as? AppDelegate)?.orientationLock = .portrait
//                    }
                }) {
                    Image("f6")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.leading, 20)
                }
                Spacer()
                
                if showSnippetPopup {
                    SnippetPopupView(
                        thumbnail: snippetThumbnail,
                        snippetDuration: Int(snippetMessage) ?? 0
                    ) {
                        showSnippetPopup = false
                    }
                }
                
                Spacer()
                
                Image("f7")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.trailing, 20)
            }
            
            .frame(height: 70)

            
            videoProgressBar
            
            HStack(spacing: 44) {
                Button(action: {
                }) {
                    Image(systemName: "moon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 23, height: 26)
                        .foregroundColor(Color("gry5"))
                }

                Button(action: {
                    let targetTime = max(player.currentTime().seconds - 15, 0)
                    player.seek(to: CMTime(seconds: targetTime, preferredTimescale: 600))
                }) {
                    Image(systemName: "gobackward.15")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 23, height: 26)
                        .foregroundColor(Color("gry5"))
                }

                Button(action: {
                    if isPlaying {
                        player.pause()
                    } else {
                        player.play()
                    }
                    isPlaying.toggle()
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 31)
                            .foregroundColor(.white)
                            .frame(width: 116, height: 65)
                        
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 37, height: 36)
                            .foregroundColor(.black)
                    }
                }

                Button(action: {
                    let targetTime = player.currentTime().seconds + 30
                    player.seek(to: CMTime(seconds: targetTime, preferredTimescale: 600))
                }) {
                    Image(systemName: "goforward.30")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 23, height: 26)
                        .foregroundColor(Color("gry5"))
                }

                Button(action: {
                }) {
                    Image("f1")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 26, height: 26)
                        .foregroundColor(Color("gry5"))
                }
            }
        }
        .padding(.top, 15)
    }

    var videoProgressBar: some View {
        VStack(spacing: 30) {

            VStack(spacing: 8) {
                Text("26 ديسمبر 2024")
                    .font(.system(size: 14))
                    .foregroundColor(Color("orange1"))

                Text(videoN)
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }

            HStack(spacing: 0) {
                Text("16")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.leading, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color("gry6"))

                Text("فصول الحلقة 0")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.trailing, 20)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .background(Color("blac3"))
            }
            .frame(width: 390, height: 30)
            .clipShape(
                RoundedRectangle(cornerRadius: 25, style: .continuous)
            )
            .padding(.horizontal, 20)

            VStack(spacing: 10) {
                HStack(spacing: 49) {
                    Button(action: {}) {
                        Image("f5")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 18)
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
                    }.popoverTip(addItemTip)

                    
                    Button(action: {}) {
                        Image(systemName: "heart")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                    }
                    Button(action: {}) {
                        Image("f2")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                    }
                    Button(action: {
                        saveCurrentSubtitle()
                    }) {
                        Image("f3")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                    }.popoverTip(photoTip)

                
                }



             
                .padding(.horizontal, 20)

                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.gray.opacity(0.5))
                        .frame(height: 7)
                        .padding(.horizontal, 20)

                    Slider(
                        value: Binding(
                            get: {
                                progress
                            },
                            set: { newValue in
                                progress = newValue
                                let newTime = newValue * (player.currentItem?.duration.seconds ?? 1)
                                player.seek(to: CMTime(seconds: newTime, preferredTimescale: 600))
                            }
                        ),
                        in: 0...1
                    )
                    .accentColor(.white)
                    .background(Color.clear)
                    .padding(.horizontal, 20)
                }

                HStack {
                    Text(formatTime(player.currentTime().seconds))
                        .foregroundColor(.white)
                        .font(.caption)

                    Spacer()

                    let remaining = (player.currentItem?.duration.seconds ?? 0) - player.currentTime().seconds
                    Text("-\(formatTime(remaining))")
                        .foregroundColor(.white)
                        .font(.caption)
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // أدوات الـToolbar
    var toolbarContent: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarLeading) {
                menuButton
            }
            ToolbarItem(placement: .principal) {
                audioVideoToggle
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                dismissButton
            }
        }
    }

    var menuButton: some View {
        Menu {
            Button(action: {}) { Label("على جنب", systemImage: "bookmark") }
            Button(action: {}) { Label("سمعتها", systemImage: "checkmark.circle") }
            Button(action: {}) {
                HStack {
                    Image("Component42")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    Text("الصالة")
                }
            }
            Menu {
                Button(action: {
                    snippetDuration = 30
                    print("Snippet duration set to 30 seconds")
                }) {
                    Text("٣٠ ثانية")
                }
                Button(action: {
                    snippetDuration = 60
                    print("Snippet duration set to 60 seconds")
                }) {
                    Text("٦٠ ثانية")
                }
            } label: {
                HStack {
                    Image("f42")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    Text("اللقطة")
                    Spacer()
                    Image(systemName: "chevron.down")
                }
            }
        } label: {
            Image(systemName: "ellipsis")
                .foregroundColor(Color("gry5"))
        }
    }


    var audioVideoToggle: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(Color("gry2"))
                .frame(width: 50, height: 25)

            HStack(spacing: 0) {
                Button(action: {
                    isAudioMode = false
                    player.play()
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 25)
                            .fill(isAudioMode ? Color.clear : Color("gry1"))
                            .frame(width: 30, height: 25)
                        
                        Image(systemName: "video")
                            .font(.system(size: 10))
                            .foregroundColor(isAudioMode ? Color("gry3") : Color("gry4"))
                    }
                }

                Button(action: {
                    isAudioMode = true
                    player.pause()
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 25)
                            .fill(isAudioMode ? Color("gry1") : Color.clear)
                            .frame(width: 30, height: 25)

                        Text("صوت")
                            .font(.system(size: 10))
                            .foregroundColor(isAudioMode ? Color("gry3") : Color("gry4"))
                            .padding(.leading, -23)
                    }
                }
            }
        }
    }

    var dismissButton: some View {
        Button(action: {
            player.pause()
            withAnimation(.easeInOut) {
                presentationMode.wrappedValue.dismiss()
            }
        }) {
            Image(systemName: "chevron.down")
                .foregroundColor(Color("gry5"))
        }
    }
    
    
    func startSubtitleObserver() {
        if let currentTime = player.currentItem?.currentTime().seconds {
            updateSubtitleAt(currentTime: currentTime)
        }
    }

    func loadSubtitles() {
        if let subtitleURL = Bundle.main.url(forResource: videoName, withExtension: "vtt") {
            do {
                let subtitleString = try String(contentsOf: subtitleURL)
                subtitles = parseVTT(subtitleString)
            } catch {
                print("Error loading subtitles: \(error)")
            }
        }
    }

    func parseVTT(_ vttString: String) -> [(startTime: TimeInterval, endTime: TimeInterval, text: String)] {
        var parsedSubtitles: [(startTime: TimeInterval, endTime: TimeInterval, text: String)] = []
        let lines = vttString.components(separatedBy: "\n")
        var currentStartTime: TimeInterval?
        var currentEndTime: TimeInterval?
        var currentText: String = ""

        for line in lines {
            if line.contains("-->") {
                let times = line.components(separatedBy: " --> ")
                if let start = parseTime(times[0]),
                   let end = parseTime(times[1]) {
                    currentStartTime = start
                    currentEndTime = end
                }
            } else if !line.isEmpty {
                currentText += line + " "
            } else if let start = currentStartTime, let end = currentEndTime {
                parsedSubtitles.append((
                    startTime: start,
                    endTime: end,
                    text: currentText.trimmingCharacters(in: .whitespaces)
                ))
                currentStartTime = nil
                currentEndTime = nil
                currentText = ""
            }
        }
        return parsedSubtitles
    }

    func parseTime(_ timeString: String) -> TimeInterval? {
        let parts = timeString.components(separatedBy: ":")
        guard parts.count == 3 else { return nil }
        let hours = Double(parts[0]) ?? 0
        let minutes = Double(parts[1]) ?? 0
        let seconds = Double(parts[2].replacingOccurrences(of: ",", with: ".")) ?? 0
        return hours * 3600 + minutes * 60 + seconds
    }

    func updateSubtitleAt(currentTime: TimeInterval) {
        if let subtitle = subtitles.first(where: { currentTime >= $0.startTime && currentTime <= $0.endTime }) {
            currentSubtitle = subtitle.text
        } else {
            currentSubtitle = ""
        }
    }

    func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, secs)
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
}
