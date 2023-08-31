@testable import PayPalMessages
import Foundation

class LogSenderMock: LogSendable {

    var data: Data?

    func send(_ data: Data, to environement: Environment) {
        self.data = data
    }
}
