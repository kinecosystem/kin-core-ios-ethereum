Pod::Spec.new do |s|
  s.name             = 'KinSDK'
  s.version          = '0.3.5'
  s.summary          = 'pod for the KIN SDK.'

  s.description      = <<-DESC
  Initial pod for the KIN SDK.
                       DESC

  s.homepage         = 'https://github.com/kinfoundation/kin-sdk-core-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Kin Foundation' => 'kin@kik.com' }
  s.source           = { :git => 'git@github.com:kinfoundation/kin-sdk-core-ios.git' }

  s.prepare_command = <<-CMD
                      make get-geth
                      CMD

  s.source_files = 'KinSDK/KinSDK/**/*.swift'

  s.resource_bundles = {
    'KinSDK' => ['KinSDK/KinSDK/Resources/contractABI.json']
  }

  s.preserve_paths = 'KinSDK/Module/module.modulemap', 'KinSDK/Geth.framework/**/*', 'KinSDK/KinSDK/Resources/**/*'
  s.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '$(inherited) $(PODS_ROOT)/KinSDK/KinSDK',
                 'SWIFT_INCLUDE_PATHS' => '$(PODS_ROOT)/KinSDK/KinSDK/Module',
                 'OTHER_LDFLAGS' => '-framework Geth' }
  s.pod_target_xcconfig = { 'OTHER_LDFLAGS[arch=i386]' => '-read_only_relocs suppress' }

  s.vendored_frameworks = 'KinSDK.framework'
end
