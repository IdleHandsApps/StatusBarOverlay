Pod::Spec.new do |s|
  s.name             = "StatusBarOverlay"
  s.version          = "3.0"
  s.summary          = "A Status Bar Overlay which will automatically display a No Connection message and can display custom messages too"

  s.description      = <<-DESC
                       StatusBarOverlay will automatically show a "No Internet Connection" bar when your app loses connection, and hide it again. It supports apps which hide the status bar and The Notch
                       DESC

  s.homepage         = "https://github.com/IdleHandsApps/StatusBarOverlay/"
  s.license          = { :type => "MIT" }

  s.author           = { "Fraser Scott-Morrison" => "fraserscottmorrison@me.com" }

  s.ios.deployment_target = "8.0"

  s.swift_version = "5.0"

  s.source           = { :git => "https://github.com/IdleHandsApps/StatusBarOverlay.git", :tag => s.version.to_s }

  s.source_files = "Sources/*.swift"
  s.dependency  'ReachabilitySwift', '~> 5.0.0'
  s.resource_bundles = { 'StatusBarOverlay' => ["Sources/*.xib", "Sources/*.xcassets"] }

  s.framework       = "UIKit"
  s.requires_arc    = true
end
