//
//  StarAnimationView.swift
//  1
//
//  Created by Afrah Saleh on 27/07/1446 AH.
//

import SwiftUI

struct StarAnimationView: View {
    @State private var isFadingOut = false

    var body: some View {
        ZStack {
            // Left star
            Image("star1")
                .resizable()
                .frame(width: 24, height: 24)
                .offset(x: -80, y: -30) // Position near the top-left of the SnippetPopupView
                .opacity(isFadingOut ? 0 : 1) // Fade out
                .animation(.easeInOut(duration: 1.0), value: isFadingOut)

            // Right star
            Image("star2")
                .resizable()
                .frame(width: 24, height: 24)
                .offset(x: 80, y: -30) // Position near the top-right of the SnippetPopupView
                .opacity(isFadingOut ? 0 : 1) // Fade out
                .animation(.easeInOut(duration: 1.0), value: isFadingOut)
        }
        .onAppear {
            isFadingOut = true // Trigger fade-out animation
        }
    }
}
