////
////  SnippetScrollView.swift
////  1
////
////  Created by Afrah Saleh on 23/07/1446 AH.

import SwiftUI
import AVKit

// MARK: - SnippetScrollView
struct SnippetScrollView: UIViewRepresentable {
    @Binding var savedSnippets: [(startTime: TimeInterval, endTime: TimeInterval)]
    var videoName: String
    var size: CGSize // Pass the size dynamically.

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        let hostingController = UIHostingController(
            rootView: SnippetListView(savedSnippets: $savedSnippets, videoName: videoName, size: size)
        )

        hostingController.view.frame = CGRect(
            x: 0,
            y: 0,
            width: size.width,
            height: size.height * CGFloat(savedSnippets.count)
        )

        scrollView.contentSize = hostingController.view.frame.size
        scrollView.addSubview(hostingController.view)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.delegate = context.coordinator
        scrollView.contentInsetAdjustmentBehavior = .never

        // Notify that the first snippet should play
        DispatchQueue.main.async {
            context.coordinator.notifySnippetChanged(index: 0)
        }

        return scrollView
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {
        // Update the content size if needed.
        uiView.contentSize = CGSize(
            width: size.width,
            height: size.height * CGFloat(savedSnippets.count)
        )
    }

    class Coordinator: NSObject, UIScrollViewDelegate {
        var parent: SnippetScrollView
        var currentIndex: Int = 0

        init(parent: SnippetScrollView) {
            self.parent = parent
        }

        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            let newIndex = Int(scrollView.contentOffset.y / parent.size.height)
            if currentIndex != newIndex {
                currentIndex = newIndex
                notifySnippetChanged(index: currentIndex)
            }
        }

        func notifySnippetChanged(index: Int) {
            NotificationCenter.default.post(name: .snippetChanged, object: nil, userInfo: ["index": index])
        }
    }
}

// MARK: - Notification Extension
extension Notification.Name {
    static let snippetChanged = Notification.Name("snippetChanged")
}
