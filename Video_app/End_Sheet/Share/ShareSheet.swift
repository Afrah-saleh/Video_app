//
//  ShareSheet.swift
//  1
//
//  Created by Afrah Saleh on 22/07/1446 AH.
//

import SwiftUI
import UIKit


struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    var excludedActivityTypes: [UIActivity.ActivityType]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        controller.excludedActivityTypes = excludedActivityTypes
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No update needed
    }
}


struct EndSheetViews: View {
    @Binding var savedSubtitles: [(startTime: TimeInterval, endTime: TimeInterval, text: String)]
    @State private var selectedTab: String = "Quotes"
    var videoLink: String
    var videoName: String
    var videoN: String
    @State private var isShareSheetPresented = false
    @State private var selectedQuote: String = ""
    @Environment(\.presentationMode) var presentationMode // To dismiss the sheet

    var body: some View {
        VStack(spacing: 0) {
            // Top Header
            HStack {
                Spacer()

                // Title in the center
                ZStack {
                    Text("شارك اقتباسك") // "Share your quote"
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.black)
                }
                Spacer()
                // X Button on the right (does nothing)
                Button(action: {
                    presentationMode.wrappedValue.dismiss() // Dismiss the sheet

                }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.black)
                }
            }
            .padding([.top, .horizontal])
            
            Spacer().frame(height: 16) // Space between header and card
            Text(selectedQuote.isEmpty ? "“اختر اقتباسًا للمشاركة”" : "“\(selectedQuote)”") // Highlighted Quote
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.vertical, 4)
                .padding(.horizontal, 12)
                .background(Color("highlightColor")) // Yellow background
                .cornerRadius(8)
            // Quote Card
            VStack(spacing: 10) {
                Image(videoName) // Thumbnail image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300) // Adjust the image size
                    .cornerRadius(20)
                    .overlay(
                        VStack {
                            Spacer()

                        }
                    )
                
                Text(videoN) // Subtitle
                    .font(.system(size: 16, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                

            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color("quests")) // Dark background for the card
            )
            .padding(.horizontal, 16)

            Spacer().frame(height: 16) // Space between card and social media buttons

            // Social Media Buttons Row
            HStack(spacing: 24) {
                // WhatsApp
                SocialMediaButton(
                    platformName: "واتساب",
                    imageName: "whatsapp"
                ) {
                    shareViaWhatsApp()
                }
                
                // Twitter/X
                SocialMediaButton(
                    platformName: "اكس",
                    imageName: "x-icon" // Replace with your custom X logo
                ) {
                    shareToTwitter()
                }
                
                // Instagram Stories
                SocialMediaButton(
                    platformName: "القصص",
                    imageName: "instagram"
                ) {
                    shareToInstagram()
                }
                
                // Copy Link
                SocialMediaButton(
                    platformName: "نسخ الرابط",
                    imageName: "link"
                ) {
                    copyLink()
                }
                
                // Download
                SocialMediaButton(
                    platformName: "تحميل",
                    imageName: "download"
                ) {
                    downloadQuote()
                }
                
                // More (Default Share Sheet)
                SocialMediaButton(
                    platformName: "المزيد",
                    imageName: "more"
                ) {
                    shareViaDefaultSheet()
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .sheet(isPresented: $isShareSheetPresented) {
            ShareSheet(items: [
                "\(selectedQuote)\nشاهد البودكاست هنا: \(videoLink)"
            ])
        }
        .onAppear {
            // Pre-select the first quote if available
            if let firstQuote = savedSubtitles.first?.text {
                selectedQuote = firstQuote
            }
        }
    }

    // MARK: - Social Media Actions
    func shareViaWhatsApp() {
        let urlEncodedQuote = selectedQuote.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let whatsappURL = URL(string: "whatsapp://send?text=\(urlEncodedQuote)")!
        if UIApplication.shared.canOpenURL(whatsappURL) {
            UIApplication.shared.open(whatsappURL)
        }
    }

    func shareToTwitter() {
        let twitterURL = URL(string: "twitter://")! // Replace with Twitter logic
        if UIApplication.shared.canOpenURL(twitterURL) {
            UIApplication.shared.open(twitterURL)
        }
    }

    func shareToInstagram() {
        let instagramURL = URL(string: "instagram://story")! // Replace with Instagram logic
        if UIApplication.shared.canOpenURL(instagramURL) {
            UIApplication.shared.open(instagramURL)
        }
    }

    func copyLink() {
        UIPasteboard.general.string = videoLink
    }

    func downloadQuote() {
        print("Download functionality here")
    }

    func shareViaDefaultSheet() {
        isShareSheetPresented = true
    }
}

struct SocialMediaButton: View {
    var platformName: String
    var imageName: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40) // Icon size
                Text(platformName)
                    .font(.system(size: 12))
                    .foregroundColor(.black)
            }
        }
    }
}
