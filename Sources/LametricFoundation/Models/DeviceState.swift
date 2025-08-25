import Foundation

// MARK: - Device State

public struct DeviceState: Codable, Sendable {
    public let id: String
    public let name: String
    public let serialNumber: String
    public let mode: Mode
    public let model: String
    public let osVersion: String
    public let display: Display
}

// MARK: - Device Mode

extension DeviceState {
    public enum Mode: String, Codable, Sendable, CaseIterable {
        /// Auto scroll mode, when device switches between apps automatically
        case auto
        /// Click to scroll mode, when user can manually switch between apps  
        case manual
        /// Mode when apps get switched according to a schedule
        case schedule
        /// Kiosk mode when single app is locked on the device
        case kiosk
    }
}
