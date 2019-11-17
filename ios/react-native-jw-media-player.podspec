require 'json'

package = JSON.parse(File.read('../package.json'))

Pod::Spec.new do |s|
  s.name         = package['name']
  s.version      = package['version']
  s.summary      = package['description']
  s.license      = package['license']

  s.authors      = package['author']
  s.homepage     = package['homepage']
  s.platform     = :ios, "9.0"

  s.source       = { :git => "https://github.com/chaimPaneth/react-native-jw-media-player.git", :tag => "v#{s.version}" }
  s.source_files = 'RNJWPlayer*.{h,m}'
  s.dependency   'JWPlayer-SDK'
  s.dependency   'React'
end