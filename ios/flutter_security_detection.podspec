#
# Podspec for flutter_security_detection.
# Run `pod lib lint flutter_security_detection.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_security_detection'
  s.version          = '0.2.0'
  s.summary          = 'Frida, jailbreak, root, emulator, and hook detection for Flutter.'
  s.description      = <<-DESC
Enterprise-grade security detection for Flutter apps: Frida instrumentation,
jailbreak, root, emulator, and hook framework detection with go_router integration.
                       DESC
  s.homepage         = 'https://github.com/aliawami/flutter_security_detection'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Ali Alawami' => 'alis2012@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  s.resource_bundles = { 'flutter_security_detection_privacy' => ['Resources/PrivacyInfo.xcprivacy'] }
end
