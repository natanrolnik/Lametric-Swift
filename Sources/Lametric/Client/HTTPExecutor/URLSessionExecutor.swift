#if canImport(Foundation) && !os(Linux)
import Foundation
import LametricFoundation
import ColorizeSwift

internal struct URLSessionExecutor: HTTPExecutor {
    private let authHeader: String
    private let verbose: Bool
    private let baseURLString: String

    init(
        authHeader: String,
        baseURLString: String,
        verbose: Bool = false
    ) {
        self.authHeader = authHeader
        self.baseURLString = baseURLString
        self.verbose = verbose
    }

    func executeRequest<T: Decodable>(
        for endpoint: Endpoint
    ) async throws -> Response<T> {
        let request = try makeRequest(for: endpoint)

        if verbose {
            let method = endpoint.method.rawValue.uppercased()

            if let body = endpoint.body,
               let bodyData = try? lametricJSONEncoder.encode(body),
               let bodyString = String(data: bodyData, encoding: .utf8) {
                print("\(method.bold()) \(request.url?.absoluteString ?? "")")
                print(bodyString, terminator: "\n\n")
            } else {
                print("\(method.bold()) \(request.url?.absoluteString ?? "")", terminator: "\n\n")
            }
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw Error.invalidResponse
            }

            return try Response(data, statusCode: httpResponse.statusCode)
        } catch let error as URLError where error.code == .timedOut {
            throw Error.timeout
        } catch {
            throw error
        }
    }

    private func makeRequest(for endpoint: Endpoint) throws -> URLRequest {
        var urlString = baseURLString

        if let prefix = endpoint.prefix, !prefix.isEmpty {
            urlString.append(prefix + "/")
        }

        urlString.append(endpoint.path)

        guard let url = URL(string: urlString) else {
            throw Error.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue.uppercased()

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic \(authHeader)", forHTTPHeaderField: "Authorization")

        if let body = endpoint.body {
            request.httpBody = try lametricJSONEncoder.encode(body)
        }

        return request
    }
}

#endif
