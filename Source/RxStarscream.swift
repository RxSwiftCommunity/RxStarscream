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

public class RxWebSocketDelegateProxy: DelegateProxy<WebSocket, WebSocketDelegate>, DelegateProxyType, WebSocketDelegate {

    fileprivate let subject = PublishSubject<WebSocketEvent>()

    required public init(websocket: WebSocket) {
        super.init(parentObject: websocket, delegateProxy: RxWebSocketDelegateProxy.self)
    }
    
    public func didReceive(event: WebSocketEvent, client: WebSocketClient) {
        subject.onNext(event)
    }

    public static func currentDelegate(for object: WebSocket) -> Starscream.WebSocketDelegate? {
        object.delegate
    }
    
    public static func setCurrentDelegate(_ delegate: WebSocketDelegate?, to object: Starscream.WebSocket) {
        object.delegate = delegate
    }

    public static func registerKnownImplementations() {
        self.register { RxWebSocketDelegateProxy(websocket: $0) }
    }

    deinit {
        subject.onCompleted()
    }
}

extension WebSocket: ReactiveCompatible {}

extension Reactive where Base: WebSocket {

    public var response: Observable<WebSocketEvent> {
        RxWebSocketDelegateProxy.proxy(for: base).subject.asObservable()
    }

    public var text: Observable<String> {
        self.response
            .filter {
                switch $0 {
                case .text(_):
                    return true
                default:
                    return false
                }
            }
            .map {
                switch $0 {
                case .text(let text):
                    return text
                default:
                    return ""
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
