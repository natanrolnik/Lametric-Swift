import Foundation

// MARK: - Model

public struct Model: Codable, Sendable {
    /// Array of frames to display
    public let frames: [Frame]

    /// Optional sound to play with the notification
    public let sound: Sound?

    /// Number of times the notification should repeat (optional)
    public let cycles: Int?

    public init(
        frames: [Frame],
        sound: Sound? = nil,
        cycles: Int? = nil
    ) {
        self.frames = frames
        self.sound = sound
        self.cycles = cycles
    }
}
