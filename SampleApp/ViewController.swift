//
//  Created by Guy Kahlon.
//

import UIKit
import RxSwift
import Starscream

class ViewController: UIViewController {
  
  @IBOutlet weak var inputTextField: UITextField!
  @IBOutlet weak var sendButton: UIButton!
  @IBOutlet weak var logTextView: UITextView!
  
  let disposeBag = DisposeBag()
  let socket = WebSocket(url: URL(string: "wss://echo.websocket.org")!)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    socket.rx.response.subscribe(onNext: { [weak self] (response: WebSocketEvent) in
        
        guard let `self` = self else {
          return
        }
        
        switch response {
        case .connected:
          self.logTextView.text = self.logTextView.text + "Connected\n"
        case .disconnected(let error):
          self.logTextView.text = self.logTextView.text + "Disconnected with optional error: \(error) \n "
        case .message(let msg):
          self.logTextView.text = self.logTextView.text + "RESPONSE (Message): \(msg) \n"
        case .data(let data):
          self.logTextView.text = self.logTextView.text + "RESPONSE (Data): \(data) \n"
        case .pong:
          self.logTextView.text = self.logTextView.text + "RESPONSE (Pong)"
        }
      }).addDisposableTo(disposeBag)
    
    socket.connect()
  }

  @IBAction func sendButtonAction(sender: UIButton) {
    if let text = inputTextField.text, !text.isEmpty {
      sendMessage(message: text)
    }
  }
  
  fileprivate func sendMessage(message: String) {
    socket.write(string: message)
    logTextView.text = logTextView.text + "SENT: \(message) \n"
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
