<p align="center">
  <img src="https://github.com/GuyKahlon/RxStarscream/blob/master/SampleApp/Assets.xcassets/RxStarscreamIcon.imageset/RxStarscreamIcon.png" width="90" height="90">
</p>

RxStarscream
=========================================================================================================================
[![CircleCI](https://img.shields.io/circleci/project/github/RxSwiftCommunity/RxStarscream/master.svg)](https://circleci.com/gh/RxSwiftCommunity/RxStarscream/tree/master)
![pod](https://img.shields.io/cocoapods/v/RxStarscream.svg)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

A lightweight extension to [Starscream](https://github.com/daltoniam/Starscream) to track websocket events using RxSwift observables.

## Installation

### CocoaPods

RxStarscream is available through [CocoaPods](http://cocoapods.org/).
Add the following line to your `Podfile`:

	pod 'RxStarscream'

Then run:

	pod install

### RxStarscream version vs Swift version.

Below is a table that shows which version of RxStarscream you should use for
your Swift version.

| Swift | RxStarscream  | RxSwift       |
| ----- | ------------- |---------------|
| 4.X   |  \>= 0.8      |  \>= 4.0      |
| 3.X   | 0.7           | 3.0.0 - 3.6.1 |

### Carthage

Add this to your Cartfile

	github "RxSwiftCommunity/RxStarscream"

Then run:

	carthage update

## Usage examples

After installing via CococPods or Carthage, you should import the framework.

```swift
import RxStarscream
```

Once imported, you can open a connection to your WebSocket server.

```swift

socket = WebSocket(url: URL(string: "ws://localhost:8080/")!)
socket.connect()
```
Now you can subscribe e.g to all of the websocket events:

```swift
socket.rx.response.subscribe(onNext: { (response: WebSocketEvent) in
	switch response {
	case .connected:
		print("Connected")
	case .disconnected(let error):
		print("Disconnected with optional error : \(error)")
	case .message(let msg):
		print("Message : \(msg)")
	case .data(_):
		print("Data")
	case .pong:
		print("Pong")
  	}
}).disposed(by: disposeBag)
```


Or just to a connect event:

```swift
socket.rx.connected.subscribe(onNext: { (isConnected: Bool) in        
	print("Is connected : \(isConnected)")
}).disposed(by: disposeBag)
```

Or just to a message event:

```swift
socket.rx.text.subscribe(onNext: { (message: String) in        
	print("Message : \(message)")
}).disposed(by: disposeBag)
```


## Sample Project

There's a sample project (you need to run `carthage update` for it to compile).

The sample project uses echo server - https://www.websocket.org/echo.html

Have fun!

## Thanks

Everyone in the RxSwift Slack channel.

## Contributing

Bug reports and pull requests are welcome.

## License

RxStarscream is available under the MIT license. See the LICENSE file for more info.
