#if os(Linux)
import AsyncHTTPClient
import NIOCore
#endif
import ColorizeSwift
import Foundation
import HTTPTypes
import LametricFoundation

public struct LametricClient: Sendable {
    private let authHeader: String
    private let verbose: Bool
    private let baseURLString: String
    private let httpExecutor: HTTPExecutor

    public init(
        apiKey: String,
        connection: Connection,
        verbose: Bool = false
    ) throws(Error) {
        guard !apiKey.isEmpty,
        let authHeaderData = "dev:\(apiKey)".data(using: .utf8) else {
            throw .invalidApiKey
        }
        self.authHeader = authHeaderData.base64EncodedString()
        self.verbose = verbose

        let scheme = connection.scheme
        let host = connection.host
        let port = connection.portString
        baseURLString = "\(scheme)://\(host)\(port)/api/v2/"

        #if os(Linux)
        self.httpExecutor = AsyncHTTPClientExecutor(
            authHeader: authHeader,
            baseURLString: baseURLString,
            verbose: verbose
        )
        #else
        self.httpExecutor = URLSessionExecutor(
            authHeader: authHeader,
            baseURLString: baseURLString,
            verbose: verbose
        )
        #endif
    }

    // MARK: - Namespaced API Access

    /// Device-related operations
    public var device: Device {
        Device(executor: httpExecutor)
    }

    /// Notification-related operations  
    public var notifications: Notifications {
        Notifications(executor: httpExecutor)
    }

    /// Display-related operations
    public var display: Display {
        Display(executor: httpExecutor)
    }

    /// App-related operations
    public var apps: Apps {
        Apps(executor: httpExecutor)
    }

    // MARK: - General API Methods

    /// Lists all available API endpoints
    public func listEndpoints() async throws -> Response<ListEndpointsResponse> {
        try await httpExecutor.executeRequest(for: Endpoints.list)
    }
}

public extension LametricClient {
    struct Connection: Sendable {
        let scheme: Scheme
        let host: String
        let port: Int?

        public static func local(
            name: String,
            port: Int = 8080
        ) -> Self {
            .init(scheme: .http, host: name, port: port)
        }

        public static func url(
            scheme: Scheme = .https,
            host: String,
            port: Int? = nil
        ) -> Self {
            .init(scheme: scheme, host: host, port: port)
        }
    }

    enum Scheme: String, Sendable, CaseIterable {
        case http
        case https
    }
}

private extension LametricClient.Connection {
    var portString: String {
        port.map { ":\($0)" } ?? ""
    }
}
