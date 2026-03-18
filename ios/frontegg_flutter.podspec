#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint frontegg_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'frontegg_flutter'
  s.version      = '1.0.38'
  s.summary          = 'A new Flutter plugin project.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'https://frontegg.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Frontegg' => 'hello@frontegg.com' }
  s.source           = { :path => '.' }
  s.source_files = 'frontegg_flutter/Sources/frontegg_flutter/**/*.swift'
  s.dependency 'Flutter'
  # FronteggSwift is integrated via Swift Package Manager (SPM) through `Package.swift`.
  # CocoaPods dependency is intentionally omitted to avoid version mismatch issues.
  s.platform = :ios, '14.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.5'
end


