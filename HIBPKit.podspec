Pod::Spec.new do |s|
  s.name             = 'HIBPKit'
  s.version          = '0.2.0'
  s.summary          = 'A Swift framework to query the Have I Been Pwned? database.'
  s.description      = <<-DESC
HIBPKit is a Swift framework to query the Have I Been Pwned? database.
                       DESC

  s.homepage         = 'https://github.com/kcramer/HIBPKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Kevin Cramer' => 'kevinx@sent.com' }
  s.source           = { :git => 'https://github.com/kcramer/HIBPKit.git', :tag => s.version.to_s }

  s.swift_version = '5.0'
  s.ios.deployment_target = '11.0'
  s.osx.deployment_target = '10.13'
  s.tvos.deployment_target = '11.0'
  s.watchos.deployment_target = '3.0'

  s.source_files = 'HIBPKit/**/*.swift'
end
