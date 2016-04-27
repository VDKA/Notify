Pod::Spec.new do |s|
  s.name             = "Notify"
  s.summary          = "Notify makes presenting notification to users simple!"
  s.version          = "1.0.0"
  s.homepage         = "https://github.com/vdka/Notify"
  s.license          = 'MIT'
  s.author           = { "Ethan Jackwitz" => "ethanjackwitz@gmail.com" }
  s.source           = { :git => "https://github.com/vdka/Notify.git", :tag => s.version.to_s }
  s.platform     = :ios, '8.0'
  s.requires_arc = true
  s.source_files = 'Source/*'

  s.frameworks = 'UIKit', 'Foundation'
end
