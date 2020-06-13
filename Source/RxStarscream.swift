//
//  Created by Guy Kahlon.
//

import Foundation
import RxSwift
import RxCocoa
import Starscream

extension WebSocket: HasDelegate {
    public typealias Delegate = WebSocketDelegate
}

public class RxWebSocketDelegateProxy:DelegateProxy<WebSocket, WebSocketDelegate>,
DelegateProxyType, WebSocketDelegate {
    
    fileprivate let subject = PublishSubject<WebSocketEvent>()
    
    public init(webSocket: ParentObject) {
        super.init(
            parentObject: webSocket,
            delegateProxy: RxWebSocketDelegateProxy.self)
    }
    
    public static func registerKnownImplementations() {
        self.register { RxWebSocketDelegateProxy(webSocket: $0) }
    }
    
    public static func currentDelegate(for object: WebSocket)
        -> WebSocketDelegate? {
            return object.delegate
    }
    
    public static func setCurrentDelegate(
        _ delegate: WebSocketDelegate?, to object: WebSocket) {
        object.delegate = delegate
    }
    
    public func didReceive(event: WebSocketEvent, client: WebSocket) {
        subject.onNext(event)
    }
    
    deinit {
        subject.onCompleted()
    }
}

extension Reactive where Base: WebSocket {
    
    public var response: Observable<WebSocketEvent>{
        return RxWebSocketDelegateProxy.proxy(for: base).subject
    }
    
    public var text: Observable<String> {
        return self.response
            .filter {
                switch $0 {
                    case .text:
                        return true
                    default:
                        return false
                }
        }
        .map {
            switch $0 {
                case .text(let message):
                    return message
                default:
                    return String()
            }
        }
    }
    
    public var connected: Observable<Bool> {
        return response
            .filter {
                switch $0 {
                    case .connected, .disconnected:
                        return true
                    default:
                        return false
                }
        }
        .map {
            switch $0 {
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
    
    public func write(ping: Data) -> Observable<Void> {
        return Observable.create { sub in
            self.base.write(ping: ping) {
                sub.onNext(())
                sub.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
    public func write(string: String) -> Observable<Void> {
        return Observable.create { sub in
            self.base.write(string: string) {
                sub.onNext(())
                sub.onCompleted()
            }
            
            return Disposables.create()
        }
    }
}

extension WebSocket:ReactiveCompatible {}

