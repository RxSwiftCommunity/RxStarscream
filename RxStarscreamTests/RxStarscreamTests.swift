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
    case (.disconnected, .disconnected):
        return true
    case (.text(let lhsText), .text(let rhsText)):
        return lhsText == rhsText
    case (.binary(let lhsData), .binary(let rhsData)):
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
    private var binaryObserver: TestableObserver<WebSocketEvent>!
    private var socket: WebSocket!

    let disposeBag = DisposeBag()

    override func setUp() {
        super.setUp()

        socket = WebSocket(request: URLRequest(url: URL(string: "wss://echo.websocket.org")!))
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
        
        socket.delegate!.didReceive(event: .connected([:]), client: socket)
        socket.delegate!.didReceive(event: .disconnected("", UInt16.zero), client: socket)

        XCTAssertEqual(self.connectedObserver.events.count, 2)
        XCTAssertEqual(self.connectedObserver.events[0].value.element!, true)
        XCTAssertEqual(self.connectedObserver.events[1].value.element!, false)
    }
    
    func testBinary() {
        let scheuler = TestScheduler(initialClock: 0)
        binaryObserver = scheuler.createObserver(WebSocketEvent.self)
        
        let binaryEvent = WebSocketEvent.binary(Data())
        
        socket.rx.response
            .subscribe(binaryObserver)
            .disposed(by: disposeBag)
        
        XCTAssertNotNil(socket.delegate)
        
        socket.delegate?.didReceive(event: binaryEvent, client: socket)
        XCTAssertEqual(self.binaryObserver.events.count, 1)
        XCTAssertEqual(self.binaryObserver.events[0].value.element!, binaryEvent)
    }

    func testPongMessage() {
        let scheduler = TestScheduler(initialClock: 0)
        pongObserver = scheduler.createObserver(WebSocketEvent.self)
        
        let pongEvent = WebSocketEvent.pong(Data())

        socket.rx.response
                .subscribe(pongObserver)
                .disposed(by: disposeBag)
        
        XCTAssertNotNil(socket.delegate)

        socket.delegate?.didReceive(event: pongEvent, client: socket)
        XCTAssertEqual(self.pongObserver.events.count, 1)
        XCTAssertEqual(self.pongObserver.events[0].value.element!, pongEvent)
    }

    func testMessageResponse() {
        let sentMessage = "Hello"

        let scheduler = TestScheduler(initialClock: 0)
        responseObserver = scheduler.createObserver(WebSocketEvent.self)

        socket.rx.response
                .subscribe(responseObserver)
                .disposed(by: disposeBag)
        
        XCTAssertTrue(socket.delegate != nil, "delegate should be set")

        socket.delegate!.didReceive(event: .text(sentMessage), client: socket)
        
        XCTAssertEqual(self.responseObserver.events.count, 1)
        XCTAssertEqual(WebSocketEvent.text(sentMessage), self.responseObserver.events[0].value.element!)
    }
}

