//
//  SnippetPopupView.swift
//  1
//
//  Created by Afrah Saleh on 27/07/1446 AH.
//
import SwiftUI
struct SnippetPopupView: View {
    var thumbnail: UIImage?
    var snippetDuration: Int
    var onHide: () -> Void

    @State private var phase: Int = 0
    @State private var progress: CGFloat = 0.0
    @State private var showStars: Bool = false // To control star animation

    var body: some View {
        ZStack {
            ZStack {
                if let uiImage = thumbnail {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit) // أو .scaledToFit()
                        .frame(width: 130, height: 70)
                        .clipped()
                        .cornerRadius(8)
                        .overlay(
                            // Orange border animation
                            RoundedRectangle(cornerRadius: 8)
                                .trim(from: 0, to: progress)
                                .stroke(Color("orange1"), style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                                .frame(width: 130, height: 70)
                        )
                        .overlay(
                            ZStack {
                                if phase == 0 {
                                    Text("\(snippetDuration) ثانية")
                                        .font(.system(size: 12)) // استخدم الحجم الذي تريده
                                        .foregroundColor(.white)
                                        .padding(6)
                                        .background(Color.black)
                                        .cornerRadius(6)
                                } else {
                                    HStack {
                                        Text("تم الحفظ")
                                        Image(systemName: "checkmark.circle.fill")
                                    }
                                    .font(.system(size: 12)) // استخدم الحجم الذي تريده
                                    .foregroundColor(.white)
                                    .padding(6)
                                    .background(Color("orange1"))
                                    .cornerRadius(6)
                                    .onAppear {
                                        showStars = true // Trigger star animation
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                            showStars = false // Hide stars after animation
                                        }
                                    }
                                }
                            },
                            alignment: .center
                        )
                } else {
                    Image(systemName: "video")
                        .resizable()
                        .frame(width: 50, height: 40)
                        .foregroundColor(.white)
                }
            }
            .frame(width: 130, height: 70)

            // Star animation overlay
            if showStars {
                StarAnimationView()
            }
        }
        .frame(width: 170, height: 110)
        .transition(.scale)
        .onAppear {
            withAnimation(.linear(duration: 2)) {
                progress = 1
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                phase = 1

                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    onHide()
                }
            }
        }
    }
}
