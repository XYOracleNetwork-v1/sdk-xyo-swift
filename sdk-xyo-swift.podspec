#
# Be sure to run `pod lib lint sdk-xyo-swift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'sdk-xyo-swift'
  s.version          = '1.0.2'
  s.summary          = 'An easy to use XYO Platform wrapper for swift developers.'

  s.description      = <<-DESC

  Add the pod to your Podfile:

  pod 'sdk-xyo-swift'
  
  Import the sdk in your controller to control the node:

  import sdk_xyo_swift
  
  You can make any iOS device a node with the XyoNodeBuilder:

  let builder = XyoNodeBuilder()
  do {
    xyoNode = try builder.build()
  }
  catch {
    print("Caught Error Building Xyo Node\(error)")
  }
  
  Make that node scan for devices to start bound witnessing and passing secure data over bluetooth or tcpip.

  let ble = xyoNode?.networks["ble"] as? XyoBleNetwork
  if isClient {
    ble?.client?.scan = on
  } else {
    ble?.server?.listen = on
  }
  
                       DESC
  s.swift_version = '4.0'
  s.homepage         = 'https://github.com/XYOracleNetwork/sdk-xyo-swift'
  s.license          = { :type => 'LGPL3', :file => 'LICENSE' }
  s.authors = { 'XY - The Persistent Company' => 'developers@xyo.network' }
  s.source           = { :git => 'https://github.com/XYOracleNetwork/sdk-xyo-swift.git', :tag => s.version.to_s }
  s.authors = { 'XY - The Persistent Company' => 'developers@xyo.network' }
  s.social_media_url = 'https://twitter.com/xyodevs'
  s.documentation_url = 'https://github.com/XYOracleNetwork/sdk-xyo-swift'

  s.ios.deployment_target = '11.0'
  s.osx.deployment_target = '10.12'

  s.source_files = 'Source/**/*.swift'
  
  # s.resource_bundles = {
  #   'sdk-xyo-swift' => ['sdk-xyo-swift/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
   s.dependency 'sdk-xyobleinterface-swift'
end
