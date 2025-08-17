import Foundation
import HTTPTypes
import LametricFoundation

extension Endpoints {
    enum DisplayState {
        case get
        case put(DisplayStateUpdate)
    }
}

extension Endpoints.DisplayState: Endpoint {
    var path: String { "display" }

    var method: HTTPRequest.Method {
        switch self {
        case .get: .get
        case .put: .put
        }
    }

    var body: (any Encodable)? {
        switch self {
        case .get: nil
        case let .put(update): update
        }
    }
}
