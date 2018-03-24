Pod::Spec.new do |spec|
  spec.name             = 'RxStarscream'
  spec.version          = '0.9'
  spec.license          = 'Apache License, Version 2.0'
  spec.homepage         = 'https://github.com/RxSwiftCommunity/RxStarscream'
  spec.authors          = { 'Guy Kahlon' => 'guykahlon@gmail.com' }
  spec.summary          = 'A lightweight extension to subscribe Starscream websocket events with RxSwift.'
  spec.source           = { :git => 'https://github.com/RxSwiftCommunity/RxStarscream.git', :tag => spec.version.to_s }
  spec.source_files     = 'Source/*.swift'
  spec.requires_arc     = true
  spec.ios.deployment_target = '8.0'
  spec.osx.deployment_target = '10.10'
  spec.dependency 'Starscream', '~> 3.0'
  spec.dependency 'RxSwift', '~> 4.0'
  spec.dependency 'RxCocoa', '~> 4.0'
  spec.license      = { :type => 'Apache License, Version 2.0', :text => <<-LICENSE
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
    LICENSE
  }
end
