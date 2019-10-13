Pod::Spec.new do |spec|
  spec.name         = "ReSwift-Persist"
  spec.version      = "0.1.0"
  spec.summary      = "Data persistence for ReSwift"
  spec.description  = <<-DESC
                      ReSwift-Persist automatically persist/rehydrate ReSwift app state as JSON file. Inspired by Redux-persist.
                      DESC

  spec.homepage     = "https://github.com/muzix/ReSwift-Persist"
  spec.license      = { :type => "MIT", :file => "LICENSE.md" }
  spec.author           = {
    "muzix" => "phamhuuhoang1210@gmail.com"
  }

  spec.module_name  = "ReSwift_Persist"
  spec.source = {
    :git => "https://github.com/muzix/ReSwift-Persist.git",
    :tag => spec.version.to_s }

  spec.ios.deployment_target = "8.0"
  spec.swift_versions = ["5.0", "4.2"]

  spec.requires_arc     = true
  spec.source_files     = 'ReSwift-Persist/**/*'

  spec.dependency "ReSwift", "~> 4.0.0"
end
