import Foundation
import PromiseKit

open class BioPass {
    enum Error: Swift.Error {
        case notAvailable
        case failedEncodingPassword
        case failedCreatingSAC
        case unhandledKeychainError(OSStatus)
        case unexpectedPasswordData
    }

    let serviceName: String

    init(_ serviceName: String = Bundle.main.bundleIdentifier!) {
        self.serviceName = serviceName
    }

    static func isAvailable() -> Bool {
        if #available(iOS 8.0, macOS 10.12.1, *) {
            return true
        } else {
            return false
        }
    }

    internal func secItemAdd(_ attributes: CFDictionary, _ result: UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus {
        return SecItemAdd(attributes, result)
    }

    internal func secItemCopyMatching(_ query: CFDictionary, _ result: UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus {
        return SecItemCopyMatching(query, result)
    }

    internal func secItemDelete(_ query: CFDictionary) -> OSStatus {
        return SecItemDelete(query)
    }

    func store(_ password: String) -> Promise<Void> {
        guard #available(iOS 8.0, macOS 10.12.1, *) else {
            return Promise(error: Error.notAvailable)
        }

        return Promise { seal in
            DispatchQueue.global().async {
                guard let encodedPassword = password.data(using: .utf8) else {
                    return seal.reject(Error.failedEncodingPassword)
                }

                let optionalSacObject = SecAccessControlCreateWithFlags(kCFAllocatorDefault, kSecAttrAccessibleWhenUnlockedThisDeviceOnly, .touchIDAny, nil)

                guard let sacObject = optionalSacObject else {
                    return seal.reject(Error.failedCreatingSAC)
                }

                let query: NSDictionary = [
                    kSecClass: kSecClassGenericPassword,
                    kSecAttrAccessControl: sacObject,
                    kSecValueData: encodedPassword,
                    kSecUseAuthenticationUI: kSecUseAuthenticationUIAllow,
                    kSecAttrService: self.serviceName
                ]

                let status = self.secItemAdd(query, nil)

                guard status == noErr else {
                    return seal.reject(Error.unhandledKeychainError(status))
                }

                seal.fulfill(())
            }
        }
    }

    func retreive(withPrompt prompt: String? = nil) -> Promise<String?> {
        guard #available(iOS 8.0, macOS 10.12.1, *) else {
            return Promise(error: Error.notAvailable)
        }

        return Promise { seal in
            DispatchQueue.global().async {
                let query: NSMutableDictionary = [
                    kSecClass: kSecClassGenericPassword,
                    kSecAttrService: self.serviceName,
                    kSecReturnData: true
                ]

                if let promptString = prompt {
                    query.setObject(promptString, forKey: kSecUseOperationPrompt as! NSCopying)
                }

                var extractedData: CFTypeRef?
                let status = self.secItemCopyMatching(query, &extractedData)

                if status == errSecUserCanceled { return seal.fulfill(nil) }
                if status == errSecItemNotFound { return seal.fulfill(nil) }
                if status != errSecSuccess { return seal.reject(Error.unhandledKeychainError(status)) }

                if let retrievedData = extractedData as? Data,
                    let password = String(data: retrievedData, encoding: .utf8) {
                    seal.fulfill(password)
                } else {
                    seal.reject(Error.unexpectedPasswordData)
                }
            }
        }
    }

    func delete() -> Promise<Void> {
        guard #available(iOS 8.0, macOS 10.12.1, *) else {
            return Promise(error: Error.notAvailable)
        }

        return Promise { seal in
            DispatchQueue.global().async {
                let query: NSDictionary = [
                    kSecClass: kSecClassGenericPassword,
                    kSecAttrService: self.serviceName,
                    kSecReturnData: false
                ]

                let status = self.secItemDelete(query)

                if status == noErr { return seal.fulfill(()) }
                if status == errSecItemNotFound { return seal.fulfill(()) }

                seal.reject(Error.unhandledKeychainError(status))
            }
        }
    }
}
