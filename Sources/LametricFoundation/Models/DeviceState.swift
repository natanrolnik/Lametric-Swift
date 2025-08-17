import Foundation

public struct DeviceState: Codable, Sendable {
    public let id: String
    public let name: String
    public let serialNumber: String
    public let mode: String
    public let model: String
    public let osVersion: String
    public let display: Display
}
