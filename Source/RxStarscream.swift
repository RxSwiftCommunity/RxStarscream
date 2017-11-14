//
//  Created by Guy Kahlon.
//

import Foundation
import RxSwift
import RxCocoa
import Starscream

public enum WebSocketEvent {
  case connected
  case disconnected(Error?)
  case message(String)
  case data(Foundation.Data)
  case pong
}

open class RxWebSocketDelegateProxy: DelegateProxy<WebSocket, WebSocketDelegate>,
                                       WebSocketDelegate,
                                       WebSocketPongDelegate,
                                       DelegateProxyType {
    

    public weak var forwardDelegate: WebSocketDelegate?
    public weak var forwardPongDelegate: WebSocketPongDelegate?

    fileprivate let subject = PublishSubject<WebSocketEvent>()
    
    required public init(parentObject: WebSocket) {
        self.forwardDelegate = parentObject.delegate
        self.forwardPongDelegate = parentObject.pongDelegate
        super.init(parentObject: parentObject, delegateProxy: RxWebSocketDelegateProxy.self)
    }

    public func websocketDidConnect(socket: WebSocket) {
        subject.on(.next(WebSocketEvent.connected))
        forwardDelegate?.websocketDidConnect(socket: socket)
    }

    public func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        subject.on(.next(WebSocketEvent.disconnected(error)))
        forwardDelegate?.websocketDidDisconnect(socket: socket, error: error)
    }

    public func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        subject.on(.next(WebSocketEvent.message(text)))
        forwardDelegate?.websocketDidReceiveMessage(socket: socket, text: text)
    }

    public func websocketDidReceiveData(socket: WebSocket, data: Data) {
        subject.on(.next(WebSocketEvent.data(data)))
        forwardDelegate?.websocketDidReceiveData(socket: socket, data: data)
    }

    public func websocketDidReceivePong(socket: WebSocket, data: Data?) {
        subject.on(.next(WebSocketEvent.pong))
        forwardPongDelegate?.websocketDidReceivePong(socket: socket, data: data)
    }
    
    public static func registerKnownImplementations() {
        self.register { RxWebSocketDelegateProxy(parentObject: $0) }
    }
    
    public static func currentDelegate(for object: WebSocket) -> WebSocketDelegate? {
        return object.delegate
    }
    
    public static func setCurrentDelegate(_ delegate: WebSocketDelegate?, to object: WebSocket) {
        object.delegate = delegate
        object.pongDelegate = delegate as? WebSocketPongDelegate
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
