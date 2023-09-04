platform :osx, '10.14'
use_frameworks!
inhibit_all_warnings!

target 'Thor' do
  pod 'SwiftLint'
  pod 'MASShortcut'
  pod 'Sparkle'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete 'MACOSX_DEPLOYMENT_TARGET'
    end
  end
end
