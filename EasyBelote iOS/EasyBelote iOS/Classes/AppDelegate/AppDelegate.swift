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
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: Properties

    var window: UIWindow?

    // MARK: Life Cycle

    func application(_ application: UIApplication,
                     // swiftlint:disable:next discouraged_optional_collection
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configureAppSpecs()
        return true
    }

}

// MARK: - Configure

extension AppDelegate {

    func configureAppSpecs() {
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
