Pod::Spec.new do |s|
  s.name             = 'KinSDK'
  s.version          = '0.6.0'
  s.summary          = 'pod for the KIN SDK.'

  s.description      = <<-DESC
  Initial pod for the KIN SDK.
                       DESC

  s.homepage         = 'https://github.com/kinfoundation/kin-sdk-core-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author           = { 'Kin Foundation' => 'kin@kik.com' }
  s.source           = { :git => 'https://github.com/kinfoundation/kin-sdk-core-ios.git', :tag => "#{s.version}" ,:submodules => true}

  s.source_files = 'KinSDK/KinSDK/**/*.swift'

  s.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '$(inherited) $(PODS_ROOT)/KinSDK/KinSDK/**' }
  s.frameworks = 'StellarKinKit'
  s.ios.deployment_target = '8.0'
  s.platform = :ios, '8.0'

  s.subspec 'Stellar' do |stellar|

    stellar.source_files = "KinSDK/StellarKinKit/StellarKinKit/source/*.swift"
    stellar.ios.deployment_target = "8.0"

    stellar.subspec 'Sodium' do |sod|
      sod.ios.deployment_target = '8.0'
      sod.ios.vendored_library    = 'KinSDK/StellarKinKit/swift-sodium/Sodium/libsodium/libsodium-ios.a'
      sod.source_files = 'KinSDK/StellarKinKit/swift-sodium/Sodium/**/*.{swift,h}'
      sod.private_header_files = 'KinSDK/StellarKinKit/swift-sodium/Sodium/libsodium/*.h'
      sod.preserve_paths = 'KinSDK/StellarKinKit/swift-sodium/Sodium/libsodium/module.modulemap'
      sod.pod_target_xcconfig = {
      	'SWIFT_INCLUDE_PATHS' => '$(PODS_TARGET_SRCROOT)/swift-sodium/Sodium/libsodium',
      }
      sod.requires_arc = true
    end

    stellar.subspec 'KeychainSwift' do |chn|
      chn.source_files = "KinSDK/StellarKinKit/keychain-swift/KeychainSwift/*.swift"
      chn.ios.deployment_target = "8.0"
    end
  end





end
