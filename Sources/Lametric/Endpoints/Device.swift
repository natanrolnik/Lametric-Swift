import Foundation
import HTTPTypes

extension Endpoints {
    enum Device {
        case state
    }
}

extension Endpoints.Device: Endpoint {
    var prefix: String? { "device" }

    var path: String {
        switch self {
        case .state: ""
        }
    }
    
    var method: HTTPRequest.Method {
        switch self {
        case .state: .get
        }
    }
    
    var body: (any Encodable)? {
        switch self {
        case .state: nil
        }
    }
}
