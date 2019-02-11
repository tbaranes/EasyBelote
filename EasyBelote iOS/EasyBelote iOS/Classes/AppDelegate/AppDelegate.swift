//
//  AppDelegate.swift
//  EasyBelote
//
//  Created by Tom Baranes on 09/01/2019.
//  Copyright © 2019 EasyBelote. All rights reserved.
//

import UIKit
import EasyBelote_Core_iOS
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AppConfiguration {

    var window: UIWindow?

    // MARK: Properties

    // MARK: - Life Cycle

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configureAppSpecs()
        return true
    }

}

// MARK: - Configure

extension AppDelegate {

    func configureAppSpecs() {
        configureApp()
        configureNavigationBar()

        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
    }

    private func configureNavigationBar() {
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
    }

}
