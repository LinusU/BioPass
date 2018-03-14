import XCTest

import PromiseKit
import Valet

@testable import BioPass

@available(iOS 9.0, macOS 10.12.1, *)
class MockBackend: Backend {
    private var storedPassword: String? = nil

    func set(string: String, forKey key: String) -> Bool {
        if key == "password" {
            self.storedPassword = string
            return true
        } else {
            return false
        }
    }

    func string(forKey key: String, withPrompt: String) -> SecureEnclave.Result<String> {
        if key == "password", let result = self.storedPassword {
            return SecureEnclave.Result<String>.success(result)
        } else {
            return .itemNotFound
        }
    }

    func removeObject(forKey: String) -> Bool {
        self.storedPassword = nil
        return true
    }
}

class BioPassTests: XCTestCase {
    func testStoreRetreiveDelete() {
        guard #available(iOS 9.0, macOS 10.12.1, *) else { return }

        let secret = "Hello, World!"
        let bioPass = BioPass(withBackend: MockBackend())

        let done = self.expectation(description: "Operations completed")

        firstly {
            bioPass.store(secret)
        }.then { _ in
            bioPass.retreive(withPrompt: "Test")
        }.then { result -> Promise<Void> in
            XCTAssertEqual(result, secret)

            return bioPass.delete()
        }.then { _ in
            bioPass.retreive(withPrompt: "Test")
        }.done { result in
            XCTAssertEqual(result, nil)
            done.fulfill()
        }.catch { err in
            XCTFail("Failed with error: \(err)")
        }

        self.waitForExpectations(timeout: 2)
    }


    static var allTests = [
        ("testStoreRetreiveDelete", testStoreRetreiveDelete),
    ]
}
