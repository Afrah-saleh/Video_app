//////
//////  EndSheetView.swift
//////  1
//////
//////  Created by Afrah Saleh on 22/07/1446 AH.

import SwiftUI

struct EndSheetView: View {
    @Binding var savedSubtitles: [(startTime: TimeInterval, endTime: TimeInterval, text: String)]
    @Binding var savedSnippets: [(startTime: TimeInterval, endTime: TimeInterval)]
    @State private var selectedTab: String = "Quotes"
    var videoLink: String
    var videoName: String
    var videoN: String
    @State private var isShareSheetPresented = false
    @State private var selectedQuote: String = ""

    var body: some View {
        VStack {
            // Tab Switcher
            HStack {
                Button(action: { selectedTab = "Quotes" }) {
                    Text("اقتباساتك") // "Your Quotes" in Arabic
                        .font(.headline)
                        .foregroundColor(selectedTab == "Quotes" ? Color("orange1") : .gray)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                }
                Text(" | ")
                Button(action: { selectedTab = "Snippets" }) {
                    Text("لقطاتي") // "Your Videos" in Arabic
                        .font(.headline)
                        .foregroundColor(selectedTab == "Snippets" ? Color("orange1") : .gray)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                }
            }
            .padding()
            Divider()

            // Content for Tabs
            if selectedTab == "Quotes" {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(savedSubtitles.indices, id: \.self) { index in
                            HStack(alignment: .center, spacing: 12) {
                                // Video Thumbnail Image
                                Image(videoName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 60, height: 60) // Fixed size for image
                                    .clipShape(RoundedRectangle(cornerRadius: 8))

                                    Text("“\(savedSubtitles[index].text)”")
                                        .font(.body)
                                        .foregroundColor(.primary)
                                        .multilineTextAlignment(.center)
                                        .padding(.vertical, 4)
                                        .background(
                                            Color("highlightColor") // Highlight background
                                                .cornerRadius(4)
                                        )

                                .frame(maxWidth: .infinity, alignment: .leading) // Flexible text area

                                // Share Button
                                Button(action: {
                                    selectedQuote = savedSubtitles[index].text
                                    isShareSheetPresented = true
                                }) {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.title3)
                                        .foregroundColor(.black)
                                }
                                .frame(width: 24, height: 24) // Fixed size for the button
                            }
                            .padding()
                            .background(Color("quests")) // Background color for the card
                            .cornerRadius(12) // Rounded corners
                            .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2) // Shadow
                        }
                    }
                    .padding()
                }
            } else if selectedTab == "Snippets" {
                GeometryReader { geometry in
                    SnippetScrollView(
                        savedSnippets: $savedSnippets,
                        videoName: videoName,
                        size: geometry.size // Pass the size dynamically.
                    )
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
        }
        .onAppear {
            requestPortraitOrientation() // Lock orientation to portrait when sheet appears
        }
        .sheet(isPresented: $isShareSheetPresented) {
            EndSheetViews(savedSubtitles: $savedSubtitles, videoLink: videoLink, videoName: videoName, videoN: videoN)

        }
        .onChange(of: isShareSheetPresented) { presented in
            if !presented { selectedQuote = "" }
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
