//
//  LandscapeHostingController.swift
//  1
//
//  Created by Afrah Saleh on 28/07/1446 AH.
//

import SwiftUI
import UIKit

class LandscapeHostingController<Content>: UIHostingController<Content> where Content: View {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.landscapeLeft, .landscapeRight] // Support only landscape orientations
    }

    override var shouldAutorotate: Bool {
        return true // Allow rotation
    }
}


extension View {
    func presentInLandscape() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else { return }

        let hostingController = LandscapeHostingController(rootView: self)
        hostingController.modalPresentationStyle = .fullScreen
        rootViewController.present(hostingController, animated: true, completion: nil)
    }
}
//extension View {
//    func presentInLandscape(onDismiss: @escaping () -> Void = {}) {
//        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//              let rootViewController = windowScene.windows.first?.rootViewController else { return }
//
//        let hostingController = LandscapeHostingController(rootView: self)
//        hostingController.modalPresentationStyle = .fullScreen
//        rootViewController.present(hostingController, animated: true) {
//            onDismiss()
//        }
//    }
//}
class AppDelegate: UIResponder, UIApplicationDelegate {
    var orientationLock = UIInterfaceOrientationMask.portrait // Default orientation

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return orientationLock
    }
}
