Pod::Spec.new do |spec|
  spec.name             = 'RxStarscream'
  spec.version          = '0.1'
  spec.license          = 'Apache License, Version 2.0'
  spec.homepage         = 'https://github.com/GuyKahlon/RxStarscream'
  spec.authors          = { 'Guy Kahlon' => 'guykahlon@gmail.com' }
  spec.summary          = 'A lightweight extension to Starscream to track subscribe to socket events with RxSwift.'
  spec.source           = { :git => 'https://github.com/GuyKahlon/RxStarscream', :tag => 0.1 }
  spec.source_files     = 'Source/*.swift'
  spec.framework        = 'Foundation'
  spec.requires_arc     = true
  spec.dependency 'Starscream', '~> 1.1.3'
  spec.dependency 'RxSwift', '~> 2.5.0'
end
