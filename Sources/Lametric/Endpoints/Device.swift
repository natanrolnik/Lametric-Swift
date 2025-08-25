import Foundation
import HTTPTypes
import LametricFoundation

// MARK: - Endpoints

extension Endpoints {
    enum Device {
        case state
        case setMode(DeviceState.Mode)
    }
}

extension Endpoints.Device: Endpoint {
    var prefix: String? { "device" }

    var path: String {
        switch self {
        case .state: ""
        case .setMode: ""
        }
    }

    var method: HTTPRequest.Method {
        switch self {
        case .state: .get
        case .setMode: .put
        }
    }

    var body: (any Encodable)? {
        switch self {
        case let .setMode(mode):
            SetModeRequest(mode: mode)
        case .state:
            nil
        }
    }
}

// MARK: - Request Models

private struct SetModeRequest: Codable, Sendable {
    let mode: DeviceState.Mode
}
