import XCTest
import PromiseKit
@testable import BioPass

class MockedBioPass: BioPass {
    private var storedPassword: Data? = nil

    override internal func secItemAdd(_ attributes: CFDictionary, _ result: UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus {
        let dict = attributes as! [String: Any?]
        self.storedPassword = dict[kSecValueData as String] as? Data // CFDictionaryGetValue(attributes, kSecValueData as! UnsafeRawPointer) as! Data
        return noErr
    }

    override internal func secItemCopyMatching(_ query: CFDictionary, _ result: UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus {
        if let password = self.storedPassword {
            result!.pointee = password as CFTypeRef
            return noErr
        } else {
            return errSecItemNotFound
        }
    }

    override internal func secItemDelete(_ query: CFDictionary) -> OSStatus {
        self.storedPassword = nil
        return noErr
    }
}

class BioPassTests: XCTestCase {
    func testShouldBeAvailable() {
        XCTAssertEqual(BioPass.isAvailable(), true)
    }

    func testStoreRetreiveDelete() {
        let secret = "Hello, World!"
        let bioPass = MockedBioPass("org.linusu.biopass.test")

        let done = self.expectation(description: "Operations completed")

        bioPass.store(secret).then {
            bioPass.retreive()
        }.then { result -> Promise<Void> in
            XCTAssertEqual(result, secret)

            return bioPass.delete()
        }.then {
            bioPass.retreive()
        }.done { result in
            XCTAssertEqual(result, nil)
            done.fulfill()
        }.catch { err in
            XCTFail("Failed with error: \(err)")
        }

        self.waitForExpectations(timeout: 2)
    }


    static var allTests = [
        ("testShouldBeAvailable", testShouldBeAvailable),
        ("testStoreRetreiveDelete", testStoreRetreiveDelete),
    ]
}
