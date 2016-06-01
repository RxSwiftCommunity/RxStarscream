# RxStarscream with RxSwift

A lightweight extension to [Starscream](https://github.com/daltoniam/Starscream) to track subscribe to websocket events with RxSwift.

## Installation - 

###CocoaPods

RxStarscream is available through [CocoaPods](http://cocoapods.org/).

Check out [Get Started](http://cocoapods.org/) tab on [cocoapods.org](http://cocoapods.org/).

To use RxStarscream in your project add the following 'Podfile' to your project

	platform :ios, '8.0'
	use_frameworks!

	pod 'RxStarscream'

Then run:
	pod install

###Carthage

Add this to Cartfile

	github "GuyKahlon/RxStarscream" >= 0.4

Then run:
	carthage update

## Usage examples

After instal via CococPods, you should import the framework.

```swift
import RxStarscream
```

Once imported, you can open a connection to your WebSocket server.

```swift

socket = RxWebSocket(url: NSURL(string: "ws://localhost:8080/")!)
socket.connect()
```
Now you can subscribe to all websocket events:

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

Or just for a Message event:

```swift
socket.rx_text.subscribeNext { (message: String) in        
	print("Message : \(message)")
}.addDisposableTo(self.disposeBag)
```
      

## Author

Guy Kahlon, guykahlon@gmail.com.

Follow me on Twitter (@guykahlon)


## License

RxStarscream is available under the MIT license. See the LICENSE file for more info.


