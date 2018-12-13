//
//  AppDelegate.swift
//  MapExample
//
//  Created by Dmitry Letko on 12.12.18.
//  Copyright © 2018 Dmitry Letko. All rights reserved.
//

import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configureWindow()
        
        return true
    }
}

// MARK: - private
private extension AppDelegate {
    func configureWindow() {
        guard let viewController = R.storyboard.map.mapViewController() else { fatalError() }
        
        let presenter = MapPresenter()
        presenter.view = viewController
        
        viewController.presenter = presenter
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        window?.rootViewController = viewController
        
        window?.makeKeyAndVisible()
    }
}
