import Foundation
import HTTPTypes
import LametricFoundation

extension Endpoints {
    enum Notifications {
        case send(LametricFoundation.Notification)
        case getQueue
        case remove(String)
    }
}

extension Endpoints.Notifications: Endpoint {
    var path: String {
        switch self {
        case .send, .getQueue: "notifications"
        case let .remove(id): "notifications/\(id)"
        }
    }

    var method: HTTPRequest.Method {
        switch self {
        case .send: .post
        case .getQueue: .get
        case .remove: .delete
        }
    }

    var body: (any Encodable)? {
        switch self {
        case let .send(notification): notification
        case .getQueue, .remove: nil
        }
    }
}
