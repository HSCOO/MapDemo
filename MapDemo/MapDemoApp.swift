//
//  MapDemoApp.swift
//  MapDemo
//
//  Created by dooahu on 2023/12/5.
//

import SwiftUI
import UIKit
import GoogleMaps

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        GMSServices.provideAPIKey(SDKConstants.apiKey)
        return true
    }
}

@main
struct MapDemoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var navigationModel = NavigationModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(navigationModel)
        }
    }
}
