//
//  Keychain.swift
//  HS Migrator
//
//  Created by Jaydeep Joshi on 18/08/22.
//

import Foundation
import Security

enum KeychainError: Error {
    case OSStatus(code: Int)
    case incorrectData
    case incorrectType(expected: String, actual: String)
}

actor Keychain {
    private let account: String

    init(account: String) {
        self.account = account
    }

    func data<T>(forKey key: String) throws -> T {
        var query = self.query(forKey: key)
        query[kSecReturnData as String] = kCFBooleanTrue
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var dataObj: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataObj)
        guard status == errSecSuccess else {
            throw KeychainError.OSStatus(code: Int(status))
        }
        guard let data = dataObj as? Data else {
            throw KeychainError.incorrectData
        }
        guard let value = NSKeyedUnarchiver.unarchiveObject(with: data) as? T else {
            throw KeychainError.incorrectType(expected: String(describing: T.self),
                                              actual: String(describing: type(of: data)))
        }
        return value
    }

    func setData(_ data: Any, forKey key: String) throws {
        var query = self.query(forKey: key)
        query[kSecValueData as String] = NSKeyedArchiver.archivedData(withRootObject: data)
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.OSStatus(code: Int(status))
        }
    }

    func deleteData(forKey key: String) throws {
        let query = self.query(forKey: key)
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess else {
            throw KeychainError.OSStatus(code: Int(status))
        }
    }

    func query(forKey key: String) -> [String: Any] {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: key,
                                    kSecAttrService as String: self.account,
                                    kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock]
        return query
    }

    func purge() {
        let secItemClasses =  [kSecClassGenericPassword,
                               kSecClassInternetPassword,
                               kSecClassCertificate,
                               kSecClassKey,
                               kSecClassIdentity]
        for itemClass in secItemClasses {
            let query = [kSecClass as CFString: itemClass]
            let status = SecItemDelete(query as CFDictionary)
            print("\(itemClass) : \(status)")
        }
    }

    func dumpKeychain() {
        let secItemClasses =  [kSecClassGenericPassword,
                               kSecClassInternetPassword,
                               kSecClassCertificate,
                               kSecClassKey,
                               kSecClassIdentity]
        for itemClass in secItemClasses {
            let query: [String: Any] = [kSecClass as String: itemClass,
                                        kSecMatchLimit as String: kSecMatchLimitAll,
                                        kSecReturnAttributes as String: true,
                                        kSecReturnRef as String: true]
            var dataObj: AnyObject?
            let status = SecItemCopyMatching(query as CFDictionary, &dataObj)
            if status == errSecSuccess {
                if let data = dataObj as? Array<Dictionary<String, Any>> {
                    for item in data {
                        var logString = ""
                        logString.append("KEYCHAIN DUMP ITEM START class \(itemClass) ==========\n")
                        for key in item.keys.sorted() {
                            logString.append("\(key) -> \(item[key]!)\n")
                        }
                        logString.append("KEYCHAIN DUMP ITEM END ==========\n")
                        NSLog(logString)
                    }
                } else {
                    NSLog("KEYCHAIN DUMP - Invalid data type for item class \(itemClass) - \(type(of: dataObj))\n")
                }
            } else {
                NSLog("KEYCHAIN DUMP - Invalid status for item class \(itemClass) - \(status)\n")
            }
        }
    }
}
