
<p align="center">
  <img src="https://github.com/GuyKahlon/RxStarscream/blob/master/SampleApp/Assets.xcassets/RxStarscreamIcon.imageset/RxStarscreamIcon.png" width="90" height="90"> 
</p>


RxStarscream with RxSwift 
=========================================================================================================================
A lightweight extension to [Starscream](https://github.com/daltoniam/Starscream) to track websocket events using RxSwift observables.

## Installation

###CocoaPods

RxStarscream is available through [CocoaPods](http://cocoapods.org/).

Check out the [Get Started](http://cocoapods.org/) tab on [cocoapods.org](http://cocoapods.org/) if this is the first time you're using CocoaPods.

To use RxStarscream in your project add the following 'Podfile' to your project

	platform :ios, '8.0'
	use_frameworks!

	pod 'RxStarscream'

Then run:
	pod install

###Carthage

Add this to Cartfile

	github "RxSwiftCommunity/RxStarscream" >= 0.4

Then run:
	carthage update

## Usage examples

After instal via CococPods or Carthage, you should import the framework.

```swift
import RxStarscream
```

Once imported, you can open a connection to your WebSocket server.

```swift

socket = RxWebSocket(url: NSURL(string: "ws://localhost:8080/")!)
socket.connect()
```
Now you can subscribe e.g to all of the websocket events:

```swift
socket.rx_response.subscribeNext { (response: WebSocketEvent) in
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


