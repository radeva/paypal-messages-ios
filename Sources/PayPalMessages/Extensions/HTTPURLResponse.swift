import Foundation

extension HTTPURLResponse {

    var paypalDebugID: String? {
        // Debug id keys are different between rest endpoints and gql responses, handle both
        allHeaderFields["paypal-debug-id"] as? String
            ?? allHeaderFields["Paypal-Debug-Id"] as? String
    }
}
