//
//  Created by Guy Kahlon.
//

import Foundation
import RxSwift
import RxCocoa
import Starscream

public enum WebSocketEvent {
  case connected
  case disconnected(NSError?)
  case message(String)
  case data(Foundation.Data)
  case pong
}

public class RxWebSocketDelegateProxy: DelegateProxy,
                                      WebSocketDelegate,
                                      WebSocketPongDelegate,
                                      DelegateProxyType {
  
  public static func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
    let webSocket = object as! WebSocket
    webSocket.delegate = delegate as! WebSocketDelegate?
  }

  public static func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
    let webSocket = object as! WebSocket
    return webSocket.delegate
  }
  
  private weak var forwardDelegate: WebSocketDelegate?
  private weak var forwardPongDelegate: WebSocketPongDelegate?
  
  fileprivate let subject = PublishSubject<WebSocketEvent>()
  
  required public init(parentObject: AnyObject) {
    let webSocket = parentObject as! WebSocket
    self.forwardDelegate = webSocket.delegate
    self.forwardPongDelegate = webSocket.pongDelegate
    super.init(parentObject: parentObject)
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
  
  deinit {
    subject.on(.completed)
  }
}

extension Reactive where Base: WebSocket {
  
  public var response: Observable<WebSocketEvent> {
    return RxWebSocketDelegateProxy.proxyForObject(base).subject
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
