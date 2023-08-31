public enum PayPalMessageError: Error, Equatable {
    case invalidURL
    case invalidResponse(paypalDebugID: String? = nil)

    public var paypalDebugId: String? {
        switch self {
        case .invalidResponse(let paypalDebugID):
            return paypalDebugID

        default:
            return nil
        }
    }

    public var description: String? {
        switch self {
        case .invalidURL:
            return "InvalidURL"
        case .invalidResponse:
            return "InvalidResponse"
        }
    }

    static public func == (lhs: PayPalMessageError, rhs: PayPalMessageError) -> Bool {
        lhs.paypalDebugId == rhs.paypalDebugId && lhs.description == rhs.description
    }
}
