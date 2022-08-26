//
//  ContentView.swift
//  HS Migrator X
//
//  Created by Jaydeep Joshi on 19/08/22.
//

import SwiftUI
import HelpshiftX
import MessageUI

struct ContentView: View {
    private let keychain: Keychain
    private let didMigrationSucceed: Bool?
    private let mailDelegate: MailDelegate

    init(keychain: Keychain, didMigrationSucceed: Bool?) {
        self.keychain = keychain
        self.didMigrationSucceed = didMigrationSucceed
        self.mailDelegate = MailDelegate()
    }

    var body: some View {
        let ui = self.migrationStatusUI
        Text("Migration status : \(ui.0)").foregroundColor(ui.1)
        VStack {
            Button("Show Conversation") {
                NSLog("USER ACTION - Show Conversation clicked")
                if let vc = UIApplication.shared.rootViewController() {
                    Helpshift.showConversation(with: vc, config: nil)
                }
            }
            .padding()
            .border(Color.blue)
            Button {
                NSLog("USER ACTION - Share logs clicked")
                shareLogs()
            } label: {
                Label("Share logs", systemImage: "square.and.arrow.up")
                    .padding()
                    .border(Color.blue)
            }
            Spacer().frame(height: 48)
            Button("Purge Keychain") {
                NSLog("USER ACTION - Purge Keychain clicked")
                Task {
                    await keychain.purge()
                }
            }
            .padding()
            .border(Color.red)
            .foregroundColor(.red)
        }
        .padding()
        .onAppear {
            Task {
                await keychain.dumpKeychain()
            }
        }
    }

    private var migrationStatusUI: (String, Color) {
        guard let success = didMigrationSucceed else {
            return ("Unknown", .gray)
        }
        return success ? ("Success", .green) : ("Failure", .red)
    }

    @MainActor private func shareLogs() {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            NSLog("Failed to find documents dir for sharing log files")
            return
        }

        let logFiles = [dir.appendingPathComponent("console_legacy_sdk.log"),
                        dir.appendingPathComponent("console_sdkx.log")]

        var vc: UIViewController?
        if MFMailComposeViewController.canSendMail() {
            vc = mailVc(logFiles)
        } else {
            vc = UIActivityViewController(activityItems: logFiles,
                                          applicationActivities: nil)
            if UIDevice.current.userInterfaceIdiom == .pad {
                vc?.popoverPresentationController?.sourceView = HostingView(rootView: self)
            }
        }

        if let root = UIApplication.shared.rootViewController(), let vc = vc {
            root.present(vc, animated: true, completion: nil)
        } else {
            NSLog("Failed to find root view controller - or create share/mail view controller - for sharing logs")
        }
    }

    private func mailVc(_ logFiles: [URL]) -> UIViewController {
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = mailDelegate
        mail.setToRecipients(["jaydeep@helpshift.com"])
        if let success = didMigrationSucceed {
            mail.setSubject("Migration Status - \(success ? "Success" : "Failure")")
        } else {
            mail.setSubject("Migration Status - Unknown")
        }
        mail.setMessageBody("iOS Version - \(UIDevice.current.systemVersion)", isHTML: false)
        for file in logFiles {
            if let data = try? Data(contentsOf: file) {
                mail.addAttachmentData(data, mimeType: "text/txt", fileName: file.lastPathComponent)
            }
        }
        return mail
    }
}

private class MailDelegate: NSObject, MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

class HostingView<T: View>: UIView {
    private(set) var hostingController: UIHostingController<T>

    var rootView: T {
        get { hostingController.rootView }
        set { hostingController.rootView = newValue }
    }

    init(rootView: T, frame: CGRect = .zero) {
        hostingController = UIHostingController(rootView: rootView)

        super.init(frame: frame)

        backgroundColor = .clear
        hostingController.view.backgroundColor = backgroundColor
        hostingController.view.frame = self.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        addSubview(hostingController.view)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(keychain: Keychain(account: "dummy"), didMigrationSucceed: true)
    }
}

