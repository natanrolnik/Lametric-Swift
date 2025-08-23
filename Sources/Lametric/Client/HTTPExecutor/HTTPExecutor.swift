import Foundation
import LametricFoundation

/// Protocol for executing HTTP requests across different platforms
internal protocol HTTPExecutor: Sendable {
    func executeRequest<T: Decodable>(for endpoint: Endpoint) async throws -> Response<T>
}
