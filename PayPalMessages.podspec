Pod::Spec.new do |s|
  s.name            = "PayPalMessages"
  s.version         = "0.1.0"
  s.summary         = "The PayPal iOS SDK Messages Module: Promote offers to your customers such as Pay Later and PayPal Credit."
  s.homepage        = "https://developer.paypal.com"
  s.license         = "MIT"
  s.author          = { "PayPal" => "sdks@paypal.com" }
  s.source          = { :git => "https://github.com/radeva/paypal-messages-ios.git", :tag => s.version }
  s.swift_version   = "5.7"

  s.platform        = :ios, "14.0"
  s.compiler_flags  = "-Wall -Werror -Wextra"

  s.source_files    = "Sources/PayPalMessages/**/*.swift"
  s.resource_bundle = {
    "PayPalMessages" => ['Sources/PayPalMessages/*.xcassets']
  }
end
