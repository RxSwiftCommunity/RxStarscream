//
//  Created by Guy Kahlon.
//

import Foundation
import RxSwift
import RxCocoa

public enum WebSocketEvent {
	case connected
	case disconnected(NSError?)
	case message(String)
	case data(Foundation.Data)
	case pong
}

public class RxWebSocketDelegateProxy: DelegateProxy<AnyObject, NSObjectProtocol>, WebSocketDelegate, WebSocketPongDelegate, DelegateProxyType {
	
	public static func registerKnownImplementations() {
		
	}
	
	public static func currentDelegate(for object: AnyObject) -> NSObjectProtocol? {
		let webSocket = object as? WebSocket
		return webSocket?.delegate as? NSObjectProtocol
	}
	
	public static func setCurrentDelegate(_ delegate: NSObjectProtocol?, to object: AnyObject) {
		let webSocket = object as? WebSocket
		webSocket?.delegate = delegate as? WebSocketDelegate
		webSocket?.pongDelegate = delegate as? WebSocketPongDelegate
	}
	
	private weak var forwardDelegate: WebSocketDelegate?
	private weak var forwardPongDelegate: WebSocketPongDelegate?
	
	fileprivate let subject = PublishSubject<WebSocketEvent>()
	
//	required public init(parentObject: AnyObject) {
//		let webSocket = parentObject as? WebSocket
//		self.forwardDelegate = webSocket?.delegate
//		self.forwardPongDelegate = webSocket?.pongDelegate
//		super.init(parentObject: parentObject)
//	}
	
	public func websocketDidConnect(socket: WebSocketClient) {
		subject.on(.next(WebSocketEvent.connected))
		forwardDelegate?.websocketDidConnect(socket: socket)
	}
	
	public func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
		subject.on(.next(WebSocketEvent.disconnected(error as NSError?)))
		forwardDelegate?.websocketDidDisconnect(socket: socket, error: error)
	}
	
	public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
		subject.on(.next(WebSocketEvent.message(text)))
		forwardDelegate?.websocketDidReceiveMessage(socket: socket, text: text)
	}
	
	public func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
		subject.on(.next(WebSocketEvent.data(data)))
		forwardDelegate?.websocketDidReceiveData(socket: socket, data: data)
	}
	
	public func websocketDidReceivePong(socket: WebSocketClient, data: Data?) {
		subject.on(.next(WebSocketEvent.pong))
		forwardPongDelegate?.websocketDidReceivePong(socket: socket, data: data)
	}
	
	deinit {
		subject.on(.completed)
	}
}

extension Reactive where Base: WebSocket {
	
	public var response: Observable<WebSocketEvent> {
		return RxWebSocketDelegateProxy.proxy(for: base).subject
	}
	
	public var text: Observable<String> {
		return self.response.filter { response in
			switch response {
			case .message(_):
				return true
			default:
				return false
			}
			}.map { response in
				switch response {
				case .message(let message):
					return message
				default:
					return String()
				}
		}
	}
	
	public var connected: Observable<Bool> {
		return response.filter { response in
			switch response {
			case .connected, .disconnected(_):
				return true
			default:
				return false
			}
			}.map { response in
				switch response {
				case .connected:
					return true
				default:
					return false
				}
		}
	}
	
	public func write(data: Data) -> Observable<Void> {
		return Observable.create { sub in
			self.base.write(data: data) {
				sub.onNext(())
				sub.onCompleted()
			}
			return Disposables.create()
		}
	}
	
	func write(ping: Data) -> Observable<Void> {
		return Observable.create { sub in
			self.base.write(ping: ping) {
				sub.onNext(())
				sub.onCompleted()
			}
			return Disposables.create()
		}
	}
	
	func write(string: String) -> Observable<Void> {
		return Observable.create { sub in
			self.base.write(string: string) {
				sub.onNext(())
				sub.onCompleted()
			}
			return Disposables.create()
		}
	}
}

