import Foundation

import PromiseKit
import Valet

@available(iOS 9.0, macOS 10.12.1, *)
internal protocol Backend {
    func set(string: String, forKey: String) -> Bool
    func string(forKey: String, withPrompt: String) -> SecureEnclave.Result<String>
    func removeObject(forKey: String) -> Bool
}

@available(iOS 9.0, macOS 10.12.1, *)
extension SecureEnclaveValet: Backend {}

@available(iOS 9.0, macOS 10.12.1, *)
open class BioPass {
    enum Error: Swift.Error {
        case notAllowed
        case notAvailable
    }

    internal let backend: Backend

    public init(_ serviceName: String = Bundle.main.bundleIdentifier!) {
        self.backend = SecureEnclaveValet.valet(with: Identifier(nonEmpty: serviceName)!, accessControl: .biometricAny)
    }

    public init(withSharedAccessGroup sharedAccessGroupName: String) {
        self.backend = SecureEnclaveValet.sharedAccessGroupValet(with: Identifier(nonEmpty: sharedAccessGroupName)!, accessControl: .biometricAny)
    }

    internal init(withBackend backend: Backend) {
        self.backend = backend
    }

    public func store(_ password: String) -> Promise<Void> {
        return Promise { seal in
            DispatchQueue.global().async {
                if self.backend.set(string: password, forKey: "password") {
                    seal.fulfill(())
                } else {
                    seal.reject(Error.notAvailable)
                }
            }
        }
    }

    public func retreive(withPrompt prompt: String) -> Promise<String?> {
        return Promise { seal in
            DispatchQueue.global().async {
                switch self.backend.string(forKey: "password", withPrompt: prompt) {
                case let .success(result):
                    seal.fulfill(result)
                case .userCancelled, .itemNotFound:
                    seal.fulfill(nil)
                }
            }
        }
    }

    public func delete() -> Promise<Void> {
        return Promise { seal in
            DispatchQueue.global().async {
                if self.backend.removeObject(forKey: "password") {
                    seal.fulfill(())
                } else {
                    seal.reject(Error.notAllowed)
                }
            }
        }
    }
}
