Pod::Spec.new do |s|
  s.name             = 'KinSDK'
  s.version          = '0.4.8'
  s.summary          = 'pod for the KIN SDK.'

  s.description      = <<-DESC
  Initial pod for the KIN SDK.
                       DESC

  s.homepage         = 'https://github.com/kinfoundation/kin-sdk-core-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author           = { 'Kin Foundation' => 'kin@kik.com' }
  s.source           = { :git => 'https://github.com/kinfoundation/kin-sdk-core-ios.git', :tag => "#{s.version}", :submodules => true }

  s.source_files = 'KinSDK/KinSDK/**/*.swift'

  s.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '$(inherited) $(PODS_ROOT)/KinSDK/KinSDK/**' }
  #s.frameworks = 'StellarKinKit', 'KinSDK'
  s.vendored_frameworks = 'StellarKinKit'
  s.preserve_path = 'KinSDK/StellarKinKit/**/*'
  s.ios.deployment_target = '8.0'
  s.platform = :ios, '8.0'
end
