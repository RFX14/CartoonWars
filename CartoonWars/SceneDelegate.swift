//
//  SceneDelegate.swift
//  CartoonWars
//
//  Created by Josue Rosales on 6/13/26.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        // 1. Safely unwrap the window scene
        guard let windowScene = (scene as? UIWindowScene) else { return }

        // 2. Create the window attached to this scene
        let window = UIWindow(windowScene: windowScene)
        
        // 3. Initialize your new SwiftUI View
        let gameWrapperView = GameView()

        // 4. Wrap the SwiftUI view in a UIHostingController
        window.rootViewController = UIHostingController(rootView: gameWrapperView)
        
        // 5. Make it visible
        self.window = window
        window.makeKeyAndVisible()
    }
}

