import SwiftUI
import AVKit
import UIKit  // لإتاحة استخدام UIImage و AVAssetImageGenerator



struct VideoPlayerView: View {
    var videoName: String
    var videoLink: String
    var videoN: String
    @State var isShowingButterOptions = false

    @State var player: AVPlayer
    @State var subtitles: [(startTime: TimeInterval, endTime: TimeInterval, text: String)] = []
    @State var currentSubtitle: String = ""
    @State var isPlaying = false
    @State var isFullscreenPresented = false
    @State var savedSubtitles: [(startTime: TimeInterval, endTime: TimeInterval, text: String)] = []
    @State var isSnippetSheetPresented = false
    @State var savedSnippets: [(startTime: TimeInterval, endTime: TimeInterval)] = []
    @State var snippetStart: TimeInterval = 0
    @State var snippetEnd: TimeInterval = 0
    
    @State var isAudioMode = false
    @State var snippetDuration: TimeInterval = 30
    @State var isVideoEnded = false // Track if the video has ended
    @State var showingSaveAnimation = false
    @Environment(\.presentationMode) var presentationMode
    @State var timer: Timer?
    @State var progress: Double = 0.0
    let addItemTip = AddItemTip()
    let photoTip = PhotoTip()

    @State var comments: [String] = [
        "تعليق رقم 1",
        "تعليق رقم 2",
    ]
    
    // --- حالات للتحكم بالـ Popup الخاص باللقطات ---
    @State var showSnippetPopup: Bool = false
    @State var snippetThumbnail: UIImage? = nil
    @State var snippetMessage: String = ""
    @State var showEndButton: Bool = false // New state for showing the button

    init(videoName: String, videoLink: String, videoN: String) {
        self.videoName = videoName
        self.videoLink = videoLink
        self.videoN = videoN
        
        if let url = Bundle.main.url(forResource: videoName, withExtension: "mp4") {
            _player = State(initialValue: AVPlayer(url: url))
        } else {
            _player = State(initialValue: AVPlayer())
        }
    }

    var body: some View {
            ZStack {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        
                        ZStack {
                            RoundedCorner(radius: 60, corners: [.bottomLeft, .bottomRight])
                                .fill(Color.black)
                                .edgesIgnoringSafeArea(.top)
                                .frame(height: 810)
                            
                            VStack {
                                ZStack {
                                    // Video Display Section
                                    videoDisplaySection
                                        .overlay(
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
                                                            .frame(height: 30) // Adjust height of the background
                                                    )
                                                    .shadow(color: .gray.opacity(0.5), radius: 4, x: 0, y: 2)
                                                    .padding(10) // Adjust padding from edges
                                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                                                }
                                            }
                                        )
                                }
                                
                                controlButtonsSection
                            }
                            .offset(y: 40)
                        }
                        .padding(.top, -160)
                        
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Image(systemName: "chevron.backward")
                                    .font(.headline)
                                    .padding(.leading)
                                
                                Spacer()
                                
                                Text("التعليقات")
                                    .font(.headline)
                                    .padding(.trailing)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 19)
                            .padding(.top, 16)
                            .padding(.bottom, 20)
                            
                            ForEach(comments, id: \.self) { comment in
                                Text(comment)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(8)
                                    .padding(.horizontal, 25)
                            }
                        }
                        .background(Color.white)
                        .foregroundColor(.black)
                    }
                }
                .background(Color.clear)
//                .toolbar {
//                    toolbarContent
//                }
                .onAppear {
                    loadSubtitles()
                    player.play()
                    isPlaying = true
                    
                    player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: .main) { time in
                        DispatchQueue.main.async {
                            let currentTime = time.seconds
                            let duration = player.currentItem?.duration.seconds ?? 1
                            progress = currentTime / duration
                            updateSubtitleAt(currentTime: currentTime)
                        }
                    }
                    
                    NotificationCenter.default.addObserver(
                        forName: .AVPlayerItemDidPlayToEndTime,
                        object: player.currentItem,
                        queue: .main
                    ) { _ in
                        isVideoEnded = true
                        showEndButton = true // Show the button when the video ends
                    }
                }
                .onDisappear {
                  //  player.pause()
                   // isPlaying = false
                    timer?.invalidate()
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
                }
            }

            .navigationBarBackButtonHidden(true)
            .toolbar {
                // Combined toolbar content
                toolbarContent
            }
            .toolbar(.hidden, for: .tabBar) // Hide tab bar only for this view

    }
}
