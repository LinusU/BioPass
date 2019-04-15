Pod::Spec.new do |s|
  s.name         = "BioPass"
  s.version      = %x(git describe --tags --abbrev=0).chomp
  s.summary      = "Store a password behind biometric authentication"
  s.description  = "This is a microlibrary for storing a password in the keychain, instructing the keychain to only give it back if the user first authenticates with TouchID or FaceID"
  s.homepage     = "https://github.com/LinusU/BioPass"
  s.license      = "MIT"
  s.author       = { "Linus Unnebäck" => "linus@folkdatorn.se" }

  s.swift_version = "4.2"
  s.ios.deployment_target = "9.0"
  s.osx.deployment_target = "10.12.1"

  s.source       = { :git => "https://github.com/LinusU/BioPass.git", :tag => "#{s.version}" }
  s.source_files = "Sources/BioPass"

  s.dependency "PromiseKit", "~> 6.0"
  s.dependency "Valet", "~> 3.0"
end
