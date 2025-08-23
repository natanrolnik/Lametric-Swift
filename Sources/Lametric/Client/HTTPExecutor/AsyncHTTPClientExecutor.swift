#if os(Linux)
import AsyncHTTPClient
import Foundation
import HTTPTypes
import LametricFoundation
import NIOCore
import NIOFoundationCompat
import ColorizeSwift

internal struct AsyncHTTPClientExecutor: HTTPExecutor {
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
                print("\(method.bold()) \(request.url)")
                print(bodyString, terminator: "\n\n")
            } else {
                print("\(method.bold()) \(request.url)", terminator: "\n\n")
            }
        }

        do {
            let response = try await HTTPClient.shared.execute(request, timeout: .seconds(5))
            let body = try await response.body.collect(upTo: .max)
            let data = Data(buffer: body)
            return try Response(data, statusCode: response.status.code)
        } catch let error as HTTPClientError where error == .deadlineExceeded {
            throw Error.timeout
        } catch {
            throw error
        }
    }

    private func makeRequest(
        for endpoint: Endpoint
    ) throws -> HTTPClientRequest {
        // Build full URL string
        var urlString = baseURLString

        if let prefix = endpoint.prefix, !prefix.isEmpty {
            urlString.append(prefix + "/")
        }

        urlString.append(endpoint.path)

        var request = HTTPClientRequest(url: urlString)
        request.method = .init(rawValue: endpoint.method.rawValue)

        if let body = endpoint.body {
            let encoded = try lametricJSONEncoder.encode(body)
            request.body = .bytes(encoded)
        }

        let headers: [HTTPField.Name: String] = [
            .contentType: "application/json",
            .authorization: "Basic \(authHeader)"
        ]

        request.headers = .init(headers.map {
            ($0.key.canonicalName, $0.value)
        })

        return request
    }
}

#endif
