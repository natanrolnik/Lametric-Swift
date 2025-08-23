import Foundation
import HTTPTypes
import LametricFoundation

extension Endpoints {
    enum Apps {
        case getAll
        case switchToNext
        case switchToPrevious
        case getApp(String)
        case sendAction(package: String, widgetId: String, action: AppAction)
        case activateWidget(package: String, widgetId: String)
    }
}

extension Endpoints.Apps: Endpoint {
    var prefix: String? { "device" }

    var path: String {
        switch self {
        case .getAll:
            "apps"
        case .switchToNext:
            "apps/next"
        case .switchToPrevious:
            "apps/prev"
        case let .getApp(package):
            "apps/\(package)"
        case let .sendAction(package, widgetId, _):
            "apps/\(package)/widgets/\(widgetId)/actions"
        case let .activateWidget(package, widgetId):
            "apps/\(package)/widgets/\(widgetId)/activate"
        }
    }

    var method: HTTPRequest.Method {
        switch self {
        case .getAll,
             .getApp:
            .get
        case .switchToNext,
             .switchToPrevious,
             .activateWidget:
            .put
        case .sendAction:
            .post
        }
    }

    var body: (any Encodable)? {
        if case let .sendAction(_, _, action) = self {
            return action
        }

        return nil
    }
}
