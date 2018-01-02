//
//  RxStarscreamTests.swift
//  RxStarscreamTests
//
//  Created by Cezary Kopacz on 25/03/2017.
//  Copyright © 2017 Guy Kahlon. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import Starscream
import RxStarscream

extension WebSocketEvent: Equatable { }

public func ==(lhs: WebSocketEvent, rhs: WebSocketEvent) -> Bool {
    switch (lhs, rhs) {
    case (.connected, .connected):
        return true
    case (.disconnected(let lhsError), .disconnected(let rhsError)):
        return lhsError?.localizedDescription == rhsError?.localizedDescription
    case (.message(let lhsMsg), .message(let rhsMsg)):
        return lhsMsg == rhsMsg
    case (.data(let lhsData), .data(let rhsData)):
        return lhsData == rhsData
    case (.pong, .pong):
        return true
    default:
        return false
    }
}

class RxStarscreamTests: XCTestCase {

    private var connectedObserver: TestableObserver<Bool>!
    private var pongObserver: TestableObserver<WebSocketEvent>!
    private var responseObserver: TestableObserver<WebSocketEvent>!
    private var socket: WebSocket!

    let disposeBag = DisposeBag()

    override func setUp() {
        super.setUp()

        socket = WebSocket(url: URL(string: "wss://echo.websocket.org")!)
        continueAfterFailure = false
    }

    func testConnection() {
        let scheduler = TestScheduler(initialClock: 0)
        connectedObserver = scheduler.createObserver(Bool.self)

        let connected = socket.rx.connected.share(replay: 1)
        connected.subscribe(onNext: { [unowned self] _ in
                    self.socket.disconnect()
                }).disposed(by: disposeBag)

        socket.rx.connected
                .subscribe(connectedObserver)
                .disposed(by: disposeBag)
        
        XCTAssertTrue(socket.delegate != nil, "delegate should be set")
        
        socket.delegate!.websocketDidConnect(socket: socket)
        socket.delegate!.websocketDidDisconnect(socket: socket, error: nil)

        XCTAssertEqual(self.connectedObserver.events.count, 2)
        XCTAssertEqual(self.connectedObserver.events[0].value.element!, true)
        XCTAssertEqual(self.connectedObserver.events[1].value.element!, false)
    }

    func testPongMessage() {
        let scheduler = TestScheduler(initialClock: 0)
        pongObserver = scheduler.createObserver(WebSocketEvent.self)

        socket.rx.response
                .subscribe(pongObserver)
                .disposed(by: disposeBag)
        
        XCTAssertTrue(socket.pongDelegate != nil, "pongDelegate should be set")
        
        socket.pongDelegate!.websocketDidReceivePong(socket: socket, data: Data())

        XCTAssertEqual(self.pongObserver.events.count, 1)
        XCTAssertEqual(self.pongObserver.events[0].value.element!, WebSocketEvent.pong)
    }

    func testMessageResponse() {
        let sentMessage = "Hello"

        let scheduler = TestScheduler(initialClock: 0)
        responseObserver = scheduler.createObserver(WebSocketEvent.self)

        socket.rx.response
                .subscribe(responseObserver)
                .disposed(by: disposeBag)
        
        XCTAssertTrue(socket.delegate != nil, "delegate should be set")

        socket.delegate!.websocketDidReceiveMessage(socket: socket, text: sentMessage)
        
        XCTAssertEqual(self.responseObserver.events.count, 1)
        XCTAssertEqual(WebSocketEvent.message(sentMessage), self.responseObserver.events[0].value.element!)
    }
}
