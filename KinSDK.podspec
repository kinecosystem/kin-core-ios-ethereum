Pod::Spec.new do |s|
  s.name             = 'KinSDK'
  s.version          = '0.2.5'
  s.summary          = 'pod for the KIN SDK.'

  s.description      = <<-DESC
  Initial pod for the KIN SDK.
                       DESC

  s.homepage         = 'https://github.com/kinfoundation/kin-sdk-core-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Kin Foundation' => 'kin@kik.com' }
  s.source           = { :git => 'git@github.com:kinfoundation/kin-sdk-core-ios.git' }

  s.source_files = 'KinSDK/KinSDK/**/*.swift'

  s.resources = ['KinSDK/KinSDK/Resources/contractABI.json']

  s.preserve_paths = 'KinSDK/Module/module.modulemap', 'KinSDK/Geth.framework/**/*'
  s.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '$(inherited) $(PODS_ROOT)/KinSDK/KinSDK',
                 'SWIFT_INCLUDE_PATHS' => '$(PODS_ROOT)/KinSDK/KinSDK/Module',
                 'OTHER_LDFLAGS' => '-framework Geth' }
  s.pod_target_xcconfig = { 'ARCHS' => '$ARCHS_STANDARD_64_BIT' }

  s.vendored_frameworks = 'KinSDK.framework'

end
