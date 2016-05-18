//
//  Created by Jesse Squires
//  Guy Kahlon
//

import Foundation
import RxSwift
import Starscream

enum WebSocketEvent {
  case Connected
  case Disconnected(NSError?)
  case Message(String)
  case Data(NSData)
  case Pong
}

class RxWebSocket: WebSocket {
  
  private let subject = PublishSubject<WebSocketEvent>()
  private var forwardDelegate: WebSocketDelegate?
  private var forwardPongDelegate: WebSocketPongDelegate?
  
  override weak var delegate: WebSocketDelegate? {
    didSet {
      if delegate === self {
        return
      }
      forwardDelegate = delegate
      delegate = self
    }
  }
  
  override weak var pongDelegate: WebSocketPongDelegate? {
    didSet {
      if pongDelegate === self {
        return
      }
      forwardPongDelegate = pongDelegate
      pongDelegate = self
    }
  }

  private(set) lazy var rx_response: Observable<WebSocketEvent> = {
    return self.subject
  }()
 
  private(set) lazy var rx_text: Observable<WebSocketEvent> = {
    return self.subject.filter { response in
      switch response {
      case .Message(_):
        return true
      default:
        return false
      }
    }
  }()
  
  override func connect() {
    super.connect()
    delegate = self
    pongDelegate = self
  }
}

extension RxWebSocket: WebSocketPongDelegate {
  func websocketDidReceivePong(socket: WebSocket) {
    subject.on(.Next(WebSocketEvent.Pong))
  }
}

extension RxWebSocket: WebSocketDelegate {
  
  func websocketDidConnect(socket: WebSocket) {
    subject.on(.Next(WebSocketEvent.Connected))
    forwardDelegate?.websocketDidConnect(socket)
  }
  
  func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
    subject.on(.Next(WebSocketEvent.Disconnected(error)))
    forwardDelegate?.websocketDidDisconnect(socket, error: error)
    socket.delegate = nil
  }
  
  func websocketDidReceiveMessage(socket: WebSocket, text: String) {
    subject.on(.Next(WebSocketEvent.Message(text)))
    forwardDelegate?.websocketDidReceiveMessage(socket, text: text)
  }
  
  func websocketDidReceiveData(socket: WebSocket, data: NSData) {
    subject.on(.Next(WebSocketEvent.Data(data)))
    forwardDelegate?.websocketDidReceiveData(socket, data: data)
  }
}

































//class RxWebSocketDelegate: WebSocketDelegate {
//
//  var observable: Observable<WebSocketEvent>
//
//  init(observable: Observable<WebSocketEvent>) {
//    self.observable = observable
//  }
//  
//  func websocketDidReceiveData(socket: WebSocket, data: NSData) {
//    sendNext(observable, WebSocketEvent.DataMessage(socket: socket, data: data))
//  }
//  
//  func websocketDidReceiveMessage(socket: WebSocket, text: String) {
//    sendNext(observable, WebSocketEvent.TextMessage(socket: socket, message: text))
//  }
//  
//  func websocketDidConnect(socket: WebSocket) {
//    sendNext(observable, WebSocketEvent.Connected(socket: socket))
//  }
//  
//  func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
//    
//    // Clean Disconnect
//    if error?.code == 1000 {
//      sendNext(observable, WebSocketEvent.Disconnected(socket: socket))
//      return
//    }
//    
//    // Thrown after disconnection. Not sure if this is a bug with starscream.
//    // Temporarily handling it this way
//    if error == nil || error?.code == 1 {
//      return
//    }
//    
//    // Websocket Error
//    sendError(observable, error ?? NSError(domain: RxWebSocketErrorDomain, code: -1, userInfo: nil))
//    
//    // Remove Delegate
//    socket.delegate = nil
//  }
//}


//public protocol WebSocketDelegate: class {
//  func websocketDidConnect(socket: WebSocket)
//  func websocketDidDisconnect(socket: WebSocket, error: NSError?)
//  func websocketDidReceiveMessage(socket: WebSocket, text: String)
//  func websocketDidReceiveData(socket: WebSocket, data: NSData)
//}

//public class RxWebSocketDelegate: WebSocketDelegate {
//  
//  public func websocketDidConnect(socket: WebSocket) {
//    
//  }
//  
//  public func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
//    
//  }
//  
//  public func websocketDidReceiveMessage(socket: WebSocket, text: String) {
//    
//  }
//  
//  public func websocketDidReceiveData(socket: WebSocket, data: NSData) {
//    
//  }
//}

//class RxStarscreanDelegateProxy: DelegateProxy, DelegateProxyType, WebSocketDelegate {
//  
//  //We need a way to read the current delegate
//  static func currentDelegateFor(object: AnyObject) -> AnyObject? {
//    let webSocket: WebSocket = object as! WebSocket
//    return webSocket.delegate
//  }
//  
//  //We need a way to set the current delegate
//  static func setCurrentDelegate(delegate: AnyObject?, toObject object: AnyObject) {
//    let webSocket: WebSocket = object as! WebSocket
//    webSocket.delegate = delegate as? WebSocketDelegate
//  }
//}
//
//
//extension WebSocket {
//  
//  public var rx_delegate: DelegateProxy {
//    
//    _ = #selector(WebSocketDelegate.websocketDidReceiveMessage(_: text:))
//    
//    return proxyForObject(RxStarscreanDelegateProxy.self, self)
//  }
//
//
////  public var rx_didReceiveMessage: Observable<String> {
////    
////    //WebSocketDelegate.websocketDidReceiveMessage(socket: WebSocket, text: String)
////    
////
////    
////    return rx_delegate.observe(selector).map { params in
////        //return params[1] as! Bool
////        return "Text"
////    }
////  }
//  
//}