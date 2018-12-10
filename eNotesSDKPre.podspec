#
# Be sure to run `pod lib lint eNotesSDKPre.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'eNotesSDKPre'
  s.version          = '0.2.0'
  s.summary          = 'eNotes, a negotiable private key'
  s.description      = <<-DESC
  eNotesSDK, provide an esay way to use blockchain
  DESC
  
  s.homepage         = 'https://github.com/Smiacter/eNotesSDKPre'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Smiacter' => 'Smiacter@gmail.com' }
  s.source           = { :git => 'https://github.com/Smiacter/eNotesSDKPre.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  
  s.ios.deployment_target = '10.0'
  s.swift_version = '4.2'
  
  s.source_files = 'eNotesSDKPre/Classes/**/*.{swift}', 'eNotesSDKPre/Classes/Dependency/ACSBluetooth/*.{h,m}', 'eNotesSDKPre/Classes/Dependency/CoreBitcoin/**/*.{h,m}', 'eNotesSDKPre/Classes/Helper/BtcRawTx/*.{h,m}'
  s.vendored_libraries  = 'eNotesSDKPre/Classes/Dependency/**/*.a'
  s.vendored_frameworks = 'eNotesSDKPre/Classes/Dependency/**/*.framework'
  s.frameworks = 'AVFoundation'
  #s.public_header_files = 'eNotesSDK/Classes/Dependency/**/*.h'
  s.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-lObjC' }
  s.dependency 'SolarNetwork'
  s.dependency 'BigInt'
  s.dependency 'CryptoSwift'
  s.xcconfig = { 'ENABLE_BITCODE' => 'NO'}
end
