import Foundation
import HTTPTypes

protocol Endpoint: Sendable {
    var prefix: String? { get }

    var path: String { get }

    /// An HTTP Method
    var method: HTTPRequest.Method { get }

    /// The request's body - this can be either raw data or parameters serialized according
    /// to the request's HTTP Method.
    var body: (any Encodable)? { get }
}

extension Endpoint {
    var prefix: String? { "device" }
}

enum Endpoints {}
