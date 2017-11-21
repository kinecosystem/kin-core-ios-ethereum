Pod::Spec.new do |s|
  s.name             = 'KinSDK'
  s.version          = '0.1.8'
  s.summary          = 'pod for the KIN SDK.'

  s.description      = <<-DESC
  Initial pod for the KIN SDK.
                       DESC

  s.homepage         = 'https://github.com/kinfoundation/kin-sdk-core-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Kin Foundation' => 'kin@kik.com' }
  s.source           = { :git => 'git@github.com:kinfoundation/kin-sdk-core-ios.git' }

  #s.ios.deployment_target = '8.1'

  s.source_files = 'KinSDK/KinSDK/**/*.swift'

  s.resource_bundles = {
    'KinSDK' => ['KinSDK/KinSDK/Resources/contractABI.json']
  }

  #s.public_header_files = 'KinSDK/KinSDK/KinSDK.h'
  #s.library = 'Geth'
  s.preserve_paths = 'KinSDK/Module/module.modulemap', 'KinSDK/Geth.framework/**/*'
  s.vendored_libraries = 'KinSDK/Geth.framework/Versions/A/Geth'
  #s.vendored_frameworks = 'KinSDK/Geth.framework/Versions/A/Geth'
  s.xcconfig = { 'LIBRARY_SEARCH_PATHS' => '$(inherited) $(PODS_ROOT)/KinSDK/KinSDK/Geth.framework/Versions/A/Geth',
                 'SWIFT_INCLUDE_PATHS' => '$(PODS_ROOT)/KinSDK/KinSDK/Module' }

  s.vendored_frameworks = 'KinSDK.framework'
  s.libraries = 'Geth'

end
