//
//  Created by Guy Kahlon.
//

import Foundation
import RxSwift
import Starscream

import Foundation
import RxSwift
import Starscream

public enum WebSocketEvent {
  case Connected
  case Disconnected(NSError?)
  case Message(String)
  case Data(NSData)
  case Pong
}

public class RxWebSocket: WebSocket {
  
  private let subject = PublishSubject<WebSocketEvent>()
  private var forwardDelegate: WebSocketDelegate?
  private var forwardPongDelegate: WebSocketPongDelegate?
  
  public override weak var delegate: WebSocketDelegate? {
    didSet {
      if delegate === self {
        return
      }
      forwardDelegate = delegate
      delegate = self
    }
  }
  
  public override weak var pongDelegate: WebSocketPongDelegate? {
    didSet {
      if pongDelegate === self {
        return
      }
      forwardPongDelegate = pongDelegate
      pongDelegate = self
    }
  }
  
  public private(set) lazy var rx_response: Observable<WebSocketEvent> = {
    return self.subject
  }()
  
  public private(set) lazy var rx_text: Observable<String> = {
    return self.subject.filter { response in
      switch response {
      case .Message(_):
        return true
      default:
        return false
      }
      }.map { response in
        switch response {
        case .Message(let message):
          return message
        default:
          return String()
        }
    }
  }()
  
  public override func connect() {
    super.connect()
    delegate = self
    pongDelegate = self
  }
}

extension RxWebSocket: WebSocketPongDelegate {
  public func websocketDidReceivePong(socket: WebSocket) {
    subject.on(.Next(WebSocketEvent.Pong))
  }
}

extension RxWebSocket: WebSocketDelegate {
  
  public func websocketDidConnect(socket: WebSocket) {
    subject.on(.Next(WebSocketEvent.Connected))
    forwardDelegate?.websocketDidConnect(socket)
  }
  
  public func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
    subject.on(.Next(WebSocketEvent.Disconnected(error)))
    forwardDelegate?.websocketDidDisconnect(socket, error: error)
    socket.delegate = nil
  }
  
  public func websocketDidReceiveMessage(socket: WebSocket, text: String) {
    subject.on(.Next(WebSocketEvent.Message(text)))
    forwardDelegate?.websocketDidReceiveMessage(socket, text: text)
  }
  
  public func websocketDidReceiveData(socket: WebSocket, data: NSData) {
    subject.on(.Next(WebSocketEvent.Data(data)))
    forwardDelegate?.websocketDidReceiveData(socket, data: data)
  }
}