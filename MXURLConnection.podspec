Pod::Spec.new do |s|
  s.name         = "MXURLConnection"
  s.version      = "0.1.3"
  s.summary      = "easy http request"
  s.description  = "easy http request"
  s.homepage     = "https://github.com/longminxiang/MXURLConnection"
  s.license      = "MIT"
  s.author       = "Eric Lung"
  s.source       = { :git => "https://github.com/longminxiang/MXURLConnection.git", :tag => "v" + s.version.to_s }
  s.requires_arc = true
  s.source_files = "MXURLConnection/*.{h,m}"
end
