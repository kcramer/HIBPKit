Pod::Spec.new do |s|
  s.name             = 'HIBPKit'
  s.version          = '0.1.0'
  s.summary          = 'A Swift framework to query the Have I Been Pwned? database.'
  s.description      = <<-DESC
HIBPKit is a Swift framework to query the Have I Been Pwned? database.
                       DESC

  s.homepage         = 'https://github.com/kcramer/HIBPKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Kevin Cramer' => 'kevinx@sent.com' }
  s.source           = { :git => 'https://github.com/kcramer/HIBPKit', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.osx.deployment_target = '10.13'
  s.tvos.deployment_target = '11.0'
  s.watchos.deployment_target = '3.0'

  s.source_files = 'HIBPKit/**/*.swift'
  s.xcconfig = { 'SWIFT_INCLUDE_PATHS' => '$(PODS_ROOT)/HIBPKit/HIBPKit/CommonCrypto' }
  s.preserve_paths = 'HIBPKit/CommonCrypto/module.modulemap'
end
