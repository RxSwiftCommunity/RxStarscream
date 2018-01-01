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

socket = WebSocket(url: NSURL(string: "ws://localhost:8080/")!)
socket.connect()
```
Now you can subscribe e.g to all of the websocket events:

```swift
socket.rx.response.subscribeNext { (response: WebSocketEvent) in
	switch response {
	case .Connected:
		print("Connected")
	case .Disconnected(let error):
		print("Disconnected with optional error : \(error)")
	case .Message(let msg):
		print("Message : \(msg)")
	case .Data(_):
		print("Data")
	case .Pong:
		print("Pong")
  	}
}.addDisposableTo(disposeBag)
```


Or just to a connect event:

```swift
socket.rx.connected.subscribeNext { (isConnected: Bool) in        
	print("Is connected : \(isConnected)")
}.addDisposableTo(self.disposeBag)
```

Or just to a message event:

```swift
socket.rx_text.subscribeNext { (message: String) in        
	print("Message : \(message)")
}.addDisposableTo(self.disposeBag)
```
      

## Sample Project

There's a sample project (you need to run `carthage update` for it to compile). 

Tne sample project use echo server - https://www.websocket.org/echo.html 

Have fun!

## Thanks

Everyone in the RxSwift Slack channel.

## Contributing

Bug reports and pull requests are welcome.

## License

RxStarscream is available under the MIT license. See the LICENSE file for more info.


