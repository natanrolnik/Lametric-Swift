import Foundation
import LametricFoundation

// MARK: - Device Mode Response

public struct SetModeData: Codable, Sendable {
    public let mode: DeviceState.Mode
}

public typealias SetModeResponse = SuccessDataResponse<SetModeData>
