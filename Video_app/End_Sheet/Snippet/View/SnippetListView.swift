//
//  SnippetListView.swift
//  1
//
//  Created by Afrah Saleh on 27/07/1446 AH.
//

import SwiftUI
// MARK: - SnippetListView
struct SnippetListView: View {
    @Binding var savedSnippets: [(startTime: TimeInterval, endTime: TimeInterval)]
    var videoName: String
    var size: CGSize // Dynamically adjust size.

    var body: some View {
        VStack(spacing: 0) {
            ForEach(savedSnippets.indices, id: \.self) { index in
                SnippetPlayerView(
                    snippet: savedSnippets[index],
                    videoName: videoName,
                    size: size,
                    index: index
                )
                .frame(width: size.width, height: size.height)
            }
        }
        
    }
}

