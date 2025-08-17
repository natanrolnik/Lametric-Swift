import Foundation

public struct Notification: Codable, Sendable {
    /// The model containing frames and notification settings
    public let model: Model

    /// Priority level of the notification (optional)
    public let priority: Priority?

    /// The nature of the notification icon (optional)
    public let iconType: IconType

    /// Lifetime of the message in milliseconds (optional)
    public let lifetime: Int?

    public init(
        model: Model,
        priority: Priority? = nil,
        iconType: IconType = .none,
        lifetime: Int? = nil
    ) {
        self.model = model
        self.priority = priority
        self.iconType = iconType
        self.lifetime = lifetime
    }

    /// Convenience initializer for creating a notification with frames directly
    public init(
        frames: [Frame],
        sound: Sound? = nil,
        cycles: Int? = nil,
        priority: Priority? = nil,
        iconType: IconType = .none,
        lifetime: Int? = nil
    ) {
        self.model = Model(
            frames: frames,
            sound: sound,
            cycles: cycles
        )
        self.priority = priority
        self.iconType = iconType
        self.lifetime = lifetime
    }
}
