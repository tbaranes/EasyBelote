source 'https://github.com/CocoaPods/Specs.git'
workspace './EasyBelote.xcworkspace'

use_frameworks!
inhibit_all_warnings!

# ―――  iOS  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
target :'EasyBelote iOS' do
  project './EasyBelote iOS/EasyBelote iOS.xcodeproj'
  platform :ios, '10.0'

  # Designable libraries,
  pod 'IBAnimatable', :git => 'https://github.com/IBAnimatable/IBAnimatable.git'
  pod "SAConfettiView", :git => 'https://github.com/keisukeYamagishi/SAConfettiView', :branch => 'feature/swift4.2-fix-cocoapod'

  pod 'Reveal-SDK', :configurations => ['Debug']
end
