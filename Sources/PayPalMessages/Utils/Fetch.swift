import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

enum FetchError: Error {
    case invalidURL
}

func fetch(
    _ url: URL,
    method: HTTPMethod = .get,
    headers: HTTPHeaders? = nil,
    body: Data? = nil,
    session: URLSession = URLSession.shared,
    fetchQueue: DispatchQueue = DispatchQueue.global(qos: .default),
    completionQueue: DispatchQueue? = DispatchQueue.main,
    completion: @escaping (Data?, URLResponse?, Error?) -> Void
) {
    fetchQueue.async {
        let queue = completionQueue ?? fetchQueue
        var request = URLRequest(url: url)

        request.httpMethod = method.rawValue

        if let headers {
            headers.forEach { request.addValue($1, forHTTPHeaderField: $0.rawValue) }
        }

        if let body {
            request.httpBody = body
        }

        let task = session.dataTask(with: request) { data, response, error in
            guard let data, error == nil else {
                queue.async { completion(nil, response, error) }
                return
            }

            queue.async { completion(data, response, nil) }
        }

        task.resume()
    }
}
