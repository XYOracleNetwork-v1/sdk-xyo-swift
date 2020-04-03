#
# Be sure to run `pod lib lint sdk-objectmodel-swift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'sdk-core-swift'
  s.version          = '3.1.2'
  s.summary          = 'Core Library for XYO Network in Swift.'
  s.swift_version    = '5.0'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A library to perform all core XYO Network functions. This includes creating an origin chain, maintaining an origin chain, negotiations for talking to other nodes, and other basic functionality. The library has heavily abstracted modules so that all operations will work with any crypto, storage, networking, etc.

The XYO protocol for creating origin-blocks is specified in the XYO Yellow Paper. In it, it describes the behavior of how a node on the XYO network should create Bound Witnesses. Note, the behavior is not coupled with any particular technology constraints around transport layers, cryptographic algorithms, or hashing algorithms.
DESC

  s.homepage         = 'https://github.com/XYOracleNetwork/sdk-core-swift'
  s.license          = { :type => 'LGPL3', :file => 'LICENSE' }
  s.author           = { 'Carter Harrison' => 'carter@xyo.network' }
  s.source           = { :git => 'https://github.com/XYOracleNetwork/sdk-core-swift.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'

  s.source_files = 'sdk-core-swift/**/*.{swift}'
  s.swift_version = '5.0'
  s.dependency 'secp256k1.swift'
  
end


