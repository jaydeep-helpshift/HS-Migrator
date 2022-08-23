//
//  Extensions.swift
//  HS Migrator
//
//  Created by Jaydeep Joshi on 19/08/22.
//

import Foundation
import SwiftUI

extension UIApplication {

    @MainActor
    func rootViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return nil
        }
        guard let rootViewController = windowScene.windows.first?.rootViewController else {
            return nil
        }
        return rootViewController
    }
}

