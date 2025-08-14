platform :ios, '15.0'
use_frameworks!

target 'tomato-steward' do
  pod 'LaunchDarkly', '~> 6.0'
  pod 'MaterialComponents', '~> 124'
  pod 'lottie-ios', '~> 4.5'
  # If UIKit is used instead of SwiftUI, SnapKit is allowed:
  # pod 'SnapKit', '~> 5.7'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end

