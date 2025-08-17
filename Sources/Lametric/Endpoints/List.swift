import Foundation
import HTTPTypes

extension Endpoints {
    struct List {}

    public static var list: List { List() }
}

extension Endpoints.List: Endpoint {
    var prefix: String? { nil }
    var path: String { "" }
    var method: HTTPRequest.Method { .get }
    var body: (any Encodable)? { nil }
}

