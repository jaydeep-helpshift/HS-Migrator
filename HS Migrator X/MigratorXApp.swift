//
//  MigratorXApp.swift
//  HS Migrator X
//
//  Created by Jaydeep Joshi on 19/08/22.
//

import SwiftUI
import HelpshiftX

@main
struct MigratorXApp: App {
    private let keychain = Keychain(account: "com.helpshift.demo.hs-migrator")
    let didMigrationSucceed: Bool?

    init() {
        // Redirect all NSLog to a log file
        MigratorXApp.redirectConsoleLogToFile()
        let config = ["enableLogging": true]
        Helpshift.install(withPlatformId: "gayatri_platform_20210517094841070-0ec9c3c3ce3dec6",
                          domain: "gayatri.helpshift.com",
                          config: config)
        if let migrationDefaults = UserDefaults(suiteName: "hs_sdkx_migration_defaults") {
            if let _ = migrationDefaults.dictionary(forKey: "hs_sdkx_migration_status_log") {
                didMigrationSucceed = false
            } else {
                didMigrationSucceed = true
            }
        } else {
            didMigrationSucceed = nil
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(keychain: keychain, didMigrationSucceed: didMigrationSucceed)
        }
    }

    private static func redirectConsoleLogToFile() {
        let file = "console_sdkx.log"
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
