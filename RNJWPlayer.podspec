require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name         = 'RNJWPlayer'
  s.version      = package['version']
  s.summary      = package['description']
  s.license      = package['license']
  s.authors      = package['author']
  s.homepage     = package['homepage']
  s.platform     = :ios, "12.0"
  s.source       = { :git => "https://github.com/chaimPaneth/react-native-jw-media-player.git", :tag => "v#{s.version}" }
  s.source_files  = "ios/RNJWPlayer/*.{h,m}"
  s.dependency   'JWPlayerKit', '~> 4.14.0'
  s.dependency   'google-cast-sdk', '~> 4.7.0'
  s.dependency   'React'
  # s.static_framework = true
  s.info_plist = {
    'NSBluetoothAlwaysUsageDescription' => 'We will use your Bluetooth for media casting.',
    'NSBluetoothPeripheralUsageDescription' => 'We will use your Bluetooth for media casting.',
    'NSLocalNetworkUsageDescription' => 'We will use the local network to discover Cast-enabled devices on your WiFi network.',
    'Privacy - Local Network Usage Description' => 'We will use the local network to discover Cast-enabled devices on your WiFi network.',
    'NSMicrophoneUsageDescription' => 'We will use your Microphone for media casting.'
  }
  
end
