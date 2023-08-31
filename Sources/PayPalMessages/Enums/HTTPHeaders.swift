typealias HTTPHeaders = [HTTPHeader: String]

enum HTTPHeader: String {
    // MARK: - Standard Headers

    case accept = "Accept"
    case acceptLanguage = "Accept-Language"

    // MARK: - PayPal Specific Headers

    case requestedBy = "X-Requested-By"
}
