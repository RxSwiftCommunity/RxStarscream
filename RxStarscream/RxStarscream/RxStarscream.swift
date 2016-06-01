//
//  Created by Jesse Squires
//  Guy Kahlon
//

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

extension WebSocket {
  
  static public func rx_webSocket(url: NSURL, protocols: [String]? = nil) -> Observable<WebSocket> {
    
    return Observable.create { observer in
      
      let webSocket = WebSocket(url: url, protocols: protocols)
      
      observer.onNext(webSocket)
      
      return NopDisposable.instance
      
      }.shareReplayLatestWhileConnected()
  }
}

var connectKey: UInt8 = 0
var disconnectKey: UInt8 = 0
var textKey: UInt8  = 0
var dataKey: UInt8  = 0
var pongKey: UInt8  = 0

extension WebSocket {
  
  public var rx_connect: Observable<Void> {
    
    return memoize(&connectKey) {
      
      Observable.create { [weak self] observer in
        
        guard let webSocket = self else {
          observer.on(.Completed)
          return NopDisposable.instance
        }
        
        webSocket.onConnect = {
          observer.on(.Next())
        }
        
        return NopDisposable.instance
        }
        .shareReplayLatestWhileConnected()
    }
  }
  
  public var rx_disconnect: Observable<NSError?> {
    
    return memoize(&disconnectKey) {
      
      Observable.create { [weak self] observer in
        
        guard let webSocket = self else {
          observer.on(.Completed)
          return NopDisposable.instance
        }
        
        webSocket.onDisconnect = { error in
          observer.on(.Next(error))
        }
        
        return NopDisposable.instance
        }
        .shareReplayLatestWhileConnected()
    }
  }
  
  public var rx_text: Observable<String> {
    
    return memoize(&textKey) {
      
      Observable.create { [weak self] observer in
        
        guard let webSocket = self else {
          observer.on(.Completed)
          return NopDisposable.instance
        }
        
        webSocket.onText = { text in
          observer.on(.Next(text))
        }
        
        return NopDisposable.instance
        }
        .shareReplayLatestWhileConnected()
    }
  }
  
  public var rx_data: Observable<NSData> {
    
    return memoize(&dataKey) {
      
      Observable.create { [weak self] observer in
        
        guard let webSocket = self else {
          observer.on(.Completed)
          return NopDisposable.instance
        }
        
        
        webSocket.onData = { data in
          observer.on(.Next(data))
        }
        
        return NopDisposable.instance
        }
        .shareReplayLatestWhileConnected()
    }
  }
  
  public var rx_pong: Observable<Void> {
    
    return memoize(&pongKey) {
      
      Observable.create { [weak self] observer in
        
        guard let webSocket = self else {
          observer.on(.Completed)
          return NopDisposable.instance
        }
        
        
        webSocket.onPong = {
          observer.on(.Next())
        }
        
        return NopDisposable.instance
        }
        .shareReplayLatestWhileConnected()
    }
  }
  
  public var rx_response: Observable<WebSocketEvent> {
    
    let connect = rx_connect.map { WebSocketEvent.Connected }
    let disconnect = rx_disconnect.map { WebSocketEvent.Disconnected($0) }
    let text = rx_text.map { WebSocketEvent.Message($0) }
    let data = rx_data.map { WebSocketEvent.Data($0) }
    let pong = rx_pong.map { WebSocketEvent.Pong }
    
    return Observable.of(connect, disconnect, text, data, pong).merge()
  }
}

extension WebSocket {
  
  func memoize<D>(key: UnsafePointer<Void>, createLazily: () -> Observable<D>) -> Observable<D> {
    objc_sync_enter(self); defer { objc_sync_exit(self) }
    
    if let sequence = objc_getAssociatedObject(self, key) as? Observable<D> {
      return sequence
    }
    
    let sequence = createLazily()
    objc_setAssociatedObject(self, key, sequence, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    
    return sequence
  }
}
