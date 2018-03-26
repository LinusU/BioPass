# BioPass

Store a password behind biometric authentication.

This is a microlibrary for storing a password in the keychain, instructing the keychain to only give it back if the user first authenticates with TouchID or FaceID.

BioPass uses [Valet](https://github.com/square/Valet) under the hood, but exposes a simpler api that uses [PromiseKit](https://github.com/mxcl/PromiseKit), so that you don't have to consider which thread to call from.

**note:** In order for your user not to receive a prompt that your app does not yet support Face ID, you must set a value for the Privacy - Face ID Usage Description ([NSFaceIDUsageDescription](https://developer.apple.com/library/content/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW75)) key in your app’s Info.plist.

**note:** BioPass supports iOS 9.0 and macOS 10.12.1.

## Installation

### SwiftPM

```swift
package.dependencies.append(
    .package(url: "https://github.com/LinusU/BioPass", from: "2.0.0")
)
```

### Carthage

```text
github "LinusU/BioPass" ~> 2.0.0
```

### Manually

If you have [Valet](https://github.com/square/Valet) and [PromiseKit](https://github.com/mxcl/PromiseKit) installed, you can simply drop the single source file [BioPass.swift](Sources/BioPass/BioPass.swift) into your project.

## Usage

```swift
import BioPass
import PromiseKit

let bioPass = BioPass()

// Store a password for future retreival
firstly {
    bioPass.store("secret")
}.done {
    print("Password stored!")
}.catch { err in
    print("Failed to store password: \(err)")
}

// Retreive a stored password (will trigger TouchID / FaceID prompt)
firstly {
    bioPass.retreive(withPrompt: "Give us the secret password!")
}.done { password in
  print("The password was: \(password)")
}.catch { err in
    print("Failed to retreive password: \(err)")
}

// Delete the stored password
firstly {
    bioPass.delete()
}.done {
    print("Password deleted!")
}.catch { err in
    print("Failed to delete password: \(err)")
}
```

## API

### `BioPass(_ serviceName: String = Bundle.main.bundleIdentifier!)`

Create a new BioPass object, optionally passing in a service name to store the password under. If no service name is provided, it will default to `Bundle.main.bundleIdentifier!`.

### `BioPass(withSharedAccessGroup sharedAccessGroupName: String)`

Create a new BioPass object that will store the data in a shared keychain access group. The `sharedAccessGroupName` should match one of the names under the apps `keychain-access-groups` entitlement (*without* the 10 char Bundle Seed ID, that part will be added automatically).

### `.store(_ password: String) -> Promise<Void>`

Store a password for later retreival. Returns a `Promise` that will settle when the password have been saved.

### `.retreive(withPrompt prompt: String) -> Promise<String?>`

Retreive a previously stored password. Returns a `Promise` that will settle with the password. If the user cancels the authentication or if no password was stored, the `Promise` will settle with `nil`.

### `.delete() -> Promise<Void>`

Delete the stored password. Returns a `Promise` that will settle when the password have been deleted.

## Hacking

The Xcode project is generated automatically from `project.yml` using [XcodeGen](https://github.com/yonaskolb/XcodeGen). It's only checked in because Carthage needs it, do not edit it manually.
