//
//  MigratorApp.swift
//  HS Migrator
//
//  Created by Jaydeep Joshi on 18/08/22.
//

import SwiftUI
import Helpshift

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        HelpshiftCore.initialize(with: HelpshiftSupport.sharedInstance())
        let builder = HelpshiftInstallConfigBuilder()
        builder.enableLogging = true
        HelpshiftCore.install(forApiKey: "c41ca6389656704d98f7583c80ec3c27",
                              domainName: "gayatri.helpshift.com",
                              appID: "gayatri_platform_20210517094841070-0ec9c3c3ce3dec6",
                              with: builder.build())
        return true
    }
}

@main
struct MigratorApp: App {
    private let keychain = Keychain(account: "com.helpshift.demo.hs-migrator")
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        // Redirect all NSLog to a log file
        MigratorApp.redirectConsoleLogToFile()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(keychain: keychain)
        }
    }

    private static func redirectConsoleLogToFile() {
        let file = "console_legacy_sdk.log"
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let logFileUrl = dir.appendingPathComponent(file)
            print(logFileUrl)
            logFileUrl.withUnsafeFileSystemRepresentation {
                _ = freopen($0, "a+", stderr)
            }
        }
        NSLog("==========")
        NSLog("NEW APP LAUNCH")
        NSLog("==========")
    }
}
