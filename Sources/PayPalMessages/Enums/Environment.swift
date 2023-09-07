import Foundation

public enum Environment: Equatable {
    case local(port: String = "8443")
    case stage(host: String)
    case sandbox
    case live

    public var rawValue: String {
        switch self {
        case .live:
            return "production"
        case .sandbox:
            return "sandbox"
        case .stage:
            return "stage"
        case .local:
            return "local"
        }
    }

    public var isProduction: Bool {
        switch self {
        case .live, .sandbox:
            return true
        case .stage, .local:
            return false
        }
    }

    public var urlSession: URLSession {
        switch self {
        case .live, .sandbox:
            return URLSession.shared
        case .stage, .local:
            return URLSession(
                configuration: .default,
                delegate: DevelopmentSession(),
                delegateQueue: .main
            )
        }
    }

    // swiftlint:disable force_unwrapping
    private var baseURL: URL {
        switch self {
        case .local(let port):
            return URL(string: "https://localhost.paypal.com:\(port)")!
        case .stage(let host):
            return URL(string: "https://www.\(host)")!
        case .sandbox:
            return URL(string: "https://www.sandbox.paypal.com")!
        case .live:
            return URL(string: "https://www.paypal.com")!
        }
    }
    // swiftlint:enable force_unwrapping

    enum PayPalMessagePath: String {
        case message = "/credit-presentment/native/message"
        case modal = "/credit-presentment/lander/modal"
        case merchantProfile = "/credit-presentment/merchant-profile"
        case log = "/credit-presentment/glog"
    }

    func url(_ path: PayPalMessagePath, _ queryParams: [String: String?]? = nil) -> URL? {
        var parts = URLComponents()
        var queryItems: [URLQueryItem]?

        if let queryParams, !queryParams.isEmpty {
            queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        parts.scheme = baseURL.scheme
        parts.host = baseURL.host
        parts.port = baseURL.port
        parts.path = path.rawValue
        parts.queryItems = queryItems

        return parts.url
    }
}

class DevelopmentSession: NSObject, URLSessionDelegate {

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.useCredential, nil)
            return
        }

        completionHandler(.useCredential, URLCredential(trust: serverTrust))
    }
}