Pod::Spec.new do |s|
  s.name         = "MXURLConnection"
  s.version      = "0.2.0"
  s.summary      = "easy http request"
  s.description  = "easy http request with block"
  s.homepage     = "https://github.com/longminxiang/MXURLConnection"
  s.license      = "MIT"
  s.author       = { "Eric Lung" => "longminxiang@gmail.com" }
  s.source       = { :git => "https://github.com/longminxiang/MXURLConnection.git", :tag => "v" + s.version.to_s }
  s.requires_arc = true
  s.platform     = :ios, '7.0'
  s.source_files = "MXURLConnection/*.{h,m}"
end
