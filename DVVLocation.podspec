

Pod::Spec.new do |s|

s.name         = 'DVVLocation'
s.summary      = '对百度地图地理编码功能的封装。'
s.version      = '1.0.0'
s.license      = { :type => 'MIT', :file => 'LICENSE' }
s.authors      = { 'devdawei' => '2549129899@qq.com' }
s.homepage     = 'https://github.com/devdawei'

s.platform     = :ios
s.ios.deployment_target = '7.0'
s.requires_arc = true

s.source       = { :git => 'https://github.com/devdawei/DVVLocation.git', :tag => s.version.to_s }

s.source_files = 'DVVLocation/DVVLocation/*.{h,m}'

s.frameworks = 'Foundation', 'UIKit'

s.dependency 'BaiduMapKit'
s.dependency 'DVVAlertView', :git => 'https://github.com/devdawei/DVVAlertView.git', :tag => 'v1.0.2'

end
