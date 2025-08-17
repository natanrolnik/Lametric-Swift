import AsyncHTTPClient
import ColorizeSwift
import Foundation
import HTTPTypes
import LametricFoundation
import NIOCore

public struct LametricClient {
    private let authHeader: String
    private let mode: Mode
    private let verbose: Bool

    public init(
        apiKey: String,
        mode: Mode,
        verbose: Bool = false
    ) throws(Error) {
        guard !apiKey.isEmpty,
        let authHeaderData = "dev:\(apiKey)".data(using: .utf8) else {
            throw .invalidApiKey
        }
        self.authHeader = authHeaderData.base64EncodedString()
        self.mode = mode
        self.verbose = verbose
    }

    // MARK: - Namespaced API Access
    
    /// Device-related operations
    public var device: Device {
        Device(executor: self)
    }
    
    /// Notification-related operations  
    public var notifications: Notifications {
        Notifications(executor: self)
    }
    
    /// Display-related operations
    public var display: Display {
        Display(executor: self)
    }
    
    /// App-related operations
    public var apps: Apps {
        Apps(executor: self)
    }

    internal func executeRequest<T: Decodable>(for endpoint: Endpoint) async throws -> Response<T> {
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

        return try await execute(request)
    }

    // MARK: - General API Methods

    /// Lists all available API endpoints
    public func listEndpoints() async throws -> Response<ListEndpointsResponse> {
        try await executeRequest(for: Endpoints.list)
    }

    private func makeRequest(for endpoint: Endpoint) throws -> HTTPClientRequest {
        var url = "\(mode.scheme)://\(mode.domain)/api/v2/"

        if let prefix = endpoint.prefix, !prefix.isEmpty {
            url.append(prefix + "/")
        }

        url.append(endpoint.path)

        var request = HTTPClientRequest(url: url)
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

    private func execute<T: Decodable>(_ request: HTTPClientRequest) async throws -> Response<T> {
        let response = try await HTTPClient.shared.execute(request, timeout: .seconds(5))

        do {
            let body = try await response.body.collect(upTo: .max)
            return try Response(body, statusCode: response.status.code)
        } catch let error as HTTPClientError where error == .deadlineExceeded {
            throw Error.timeout
        } catch {
            throw error
        }
    }
}

public extension LametricClient {
    enum Mode {
        case local(name: String, port: Int = 8080)
        case remote(domain: String)
    }
}

extension LametricClient.Mode {
    var domain: String {
        switch self {
        case let .local(name, port):
            "\(name).local:\(port)"
        case let .remote(domain):
            domain
        }
    }

    var scheme: String {
        switch self {
        case .local: "http"
        case .remote: "https"
        }
    }
}

// MARK: - Execution Protocol

internal protocol RequestExecutor {
    func executeRequest<T: Decodable>(for endpoint: Endpoint) async throws -> Response<T>
}

extension LametricClient: RequestExecutor {}
