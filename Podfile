target 'dashwallet' do
  platform :ios, '10.0'
  
  pod 'DashSync', :path => '../DashSync/'
  
  pod 'KVO-MVVM', '0.5.6'
  pod 'Dash-PLCrashReporter', :git => 'https://github.com/podkovyrin/plcrashreporter.git', :branch => 'dash_1.5.1', :commit => 'b472e89', :inhibit_warnings => true
  pod 'UIViewController-KeyboardAdditions', '1.2.1'
  pod 'MBProgressHUD', '1.1.0'

  # Pods for dashwallet
  
  target 'DashWalletTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'DashWalletScreenshotsUITests' do
    inherit! :search_paths
    
    pod 'SimulatorStatusMagic', '2.4.1'
  end

end

target 'TodayExtension' do

end

target 'WatchApp' do
  platform :watchos, '2.0'

end

target 'WatchApp Extension' do
  platform :watchos, '2.0'

end

# fixes warnings about unsupported Deployment Target in Xcode 10
post_install do |installer|
    # update info about current DashSync version
    system("bash ./scripts/dashsync_version.sh")
end
