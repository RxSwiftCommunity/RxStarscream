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
  let socket = WebSocket(url: NSURL(string: "wss://echo.websocket.org")!)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    socket.rx_response
      .subscribeNext { [weak self] (response: WebSocketEvent) in
        
        guard let `self` = self else {
          return
        }
        
        switch response {
        case .Connected:
          self.logTextView.text = self.logTextView.text + "Connected\n"
        case .Disconnected(let error):
          self.logTextView.text = self.logTextView.text + "Disconnected with optional error: \(error) \n "
        case .Message(let msg):
          self.logTextView.text = self.logTextView.text + "RESPONSE (Message): \(msg) \n"
        case .Data(let data):
          self.logTextView.text = self.logTextView.text + "RESPONSE (Data): \(data) \n"
        case .Pong:
          self.logTextView.text = self.logTextView.text + "RESPONSE (Pong)"
        }
      }.addDisposableTo(disposeBag)
    
    socket.connect()
  }

  @IBAction func sendButtonAction(sender: UIButton) {
    if let text = inputTextField.text where !text.isEmpty {
      sendMessage(text)
    }
  }
  
  private func sendMessage(message: String) {
    socket.writeString(message)
    logTextView.text = logTextView.text + "SENT: \(message) \n"
    inputTextField.text = nil
    inputTextField.resignFirstResponder()
  }
}


extension ViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    if let text = textField.text where !text.isEmpty {
      sendMessage(text)
      return true
    }
    return false
  }
}
