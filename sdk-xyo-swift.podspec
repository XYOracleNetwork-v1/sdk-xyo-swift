#
# Be sure to run `pod lib lint sdk-xyo-swift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'sdk-xyo-swift'
  s.version          = '1.0.0'
  s.summary          = 'An easy to use XYO Platform wrapper for swift developers.'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/XYOracleNetwork/sdk-xyo-swift'
  s.license          = { :type => 'LGPL3', :file => 'LICENSE' }
  s.authors = { 'XY - The Persistent Company' => 'developers@xyo.network' }
  s.source           = { :git => 'https://github.com/XYOracleNetwork/sdk-xyo-swift.git', :tag => s.version.to_s }
  s.authors = { 'XY - The Persistent Company' => 'developers@xyo.network' }
  s.social_media_url = 'https://twitter.com/xyodevs'
  s.documentation_url = 'https://github.com/XYOracleNetwork/sdk-xyo-swift'

  s.ios.deployment_target = '11.0'

  s.source_files = 'Source/**/*.swift'
  
  # s.resource_bundles = {
  #   'sdk-xyo-swift' => ['sdk-xyo-swift/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
   s.dependency 'sdk-xyobleinterface-swift'
end
