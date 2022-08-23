//
//  ContentView.swift
//  HS Migrator
//
//  Created by Jaydeep Joshi on 18/08/22.
//

import SwiftUI
import Helpshift

struct ContentView: View {
    private let keychain: Keychain

    init(keychain: Keychain) {
        self.keychain = keychain
    }

    var body: some View {
        VStack {
            Button("Show Conversation") {
                if let vc = UIApplication.shared.rootViewController() {
                    HelpshiftSupport.showConversation(vc, with: nil)
                }
            }
            .padding()
            .border(Color.blue)
            Spacer().frame(height: 48)
            Button("Purge Keychain") {
                Task {
                    await keychain.purge()
                }
            }
            .padding()
            .border(Color.red)
            .foregroundColor(.red)
        }.padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(keychain: Keychain(account: "dummy"))
    }
}
