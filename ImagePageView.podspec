#
# Be sure to run `pod lib lint ImagePageView.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "ImagePageView"
  s.version          = "0.1.3"
  s.summary          = "ImagePageViewController is manages a UIPageViewController with an async image data source, that also pans and zooms the images"
  s.description      = <<-DESC
                       ImagePageViewController is manages a UIPageViewController with an async image data source

                       * delegate for page navigation
                       * async data source
                       * allows zooming and panning the images
                       * sharing images

                       DESC
  s.homepage         = "https://github.com/krisselden/ImagePageView"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Kris Selden" => "kris.selden@gmail.com" }
  s.source           = { :git => "https://github.com/krisselden/ImagePageView.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/krisselden'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
end
