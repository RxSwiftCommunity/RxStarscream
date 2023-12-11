//
//  Created by Guy Kahlon.
//

import UIKit
import RxSwift
import Starscream

class ViewController: UIViewController {

    @IBOutlet fileprivate weak var inputTextField: UITextField!
    @IBOutlet fileprivate weak var sendButton: UIButton!
    @IBOutlet fileprivate weak var logTextView: UITextView!
    @IBOutlet fileprivate weak var pongButton: UIBarButtonItem!

    private let disposeBag = DisposeBag()
    private let socket = WebSocket(request: URLRequest(url: URL(string: "wss://echo.websocket.org")!))
    private let writeSubject = PublishSubject<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sendButton.rx.tap
                .subscribe(onNext: { [unowned self] in
                    guard let text = self.inputTextField.text, !text.isEmpty else {
                        return
                    }
                    self.sendMessage(message: text)
                }).disposed(by: disposeBag)

        pongButton.rx.tap.subscribe(onNext: { [unowned self] in
                    self.socket.write(ping: Data())
                    self.writeSubject.onNext("PING")
                }).disposed(by: disposeBag)
        
        let responseString = socket.rx.response
            .map { response -> String in
                switch response {
                case .connected:
                    return "Connected\n"
                case .disconnected(let error, _):
                    return "Disconnected with error: \(String(describing: error)) \n"
                case .text(let text):
                    return "RESPONSE (Message): \(text) \n"
                case .binary(let data):
                    return  "RESPONSE (Data): \(data) \n"
                case .pong:
                    return "RESPONSE (Pong)"
                case .ping:
                    return "PING \n"
                case .error(let error):
                    return error?.localizedDescription ?? "Unknow error \n"
                case .viabilityChanged(let changed):
                    return "Viability changed: \(changed) \n"
                case .reconnectSuggested(let suggested):
                    return "Reconnect suggested: \(suggested) \n"
                case .cancelled:
                    return "Cancelled \n"
                case .peerClosed:
                    return "Peer closed \n"
                }
        }
        
        Observable.merge([responseString, writeSubject.asObservable()])
            .scan([]) { lastMsg, newMsg -> Array<String> in
                return Array(lastMsg + [newMsg])
            }.map { $0.joined(separator: "\n")
            }.asDriver(onErrorJustReturn: "")
            .drive(logTextView.rx.text)
            .disposed(by: disposeBag)
        
        socket.connect()
    }

    fileprivate func sendMessage(message: String) {
        socket.write(string: message)
        writeSubject.onNext("SENT: \(message)")
        inputTextField.text = nil
        inputTextField.resignFirstResponder()
    }
}

extension ViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, !text.isEmpty {
            sendMessage(message: text)
            return true
        }
        return false
    }
}
