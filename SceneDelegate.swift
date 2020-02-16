//
//  SceneDelegate.swift
//  SpaceXGraphQLExample
//
//  Created by Kauna Mohammed on 15/02/2020.
//  Copyright © 2020 Kauna Mohammed. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(frame: scene.coordinateSpace.bounds)
        self.window = window
        self.window?.windowScene = scene
        let vc = LaunchListViewController()
        vc.reactor = .init(networker: .shared)
        window.rootViewController = vc
        window.makeKeyAndVisible()
    }


}

