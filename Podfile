# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

target 'EasyFPU' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for EasyFPU
  pod 'Charts'
  pod 'ADCountryPicker'#, '~> 2.1.0'
  pod 'URLImage'
  
  # Post-install instructions
  post_install do |pi|
    pi.pods_project.targets.each do |t|
      t.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      end
    end
  end

end
