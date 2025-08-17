import Foundation

public enum Frame: Codable, Sendable {
    /// Simple frame with icon and text
    case simple(icon: String?, text: String?)

    /// Goal frame with icon and goal progress data
    case goal(icon: String?, goalData: GoalData)

    /// Spike chart frame with chart data
    case chart(data: [Int])

    // MARK: - Convenience initializers

    /// Create a simple frame with text only
    public static func text(_ text: String) -> Frame {
        .simple(icon: nil, text: text)
    }

    /// Create a simple frame with icon only
    public static func icon(_ icon: String) -> Frame {
        .simple(icon: icon, text: nil)
    }

    /// Create a simple frame with both icon and text
    public static func iconAndText(icon: String, text: String) -> Frame {
        .simple(icon: icon, text: text)
    }

    /// Create a goal frame
    public static func goal(
        icon: String? = nil,
        start: Int,
        current: Int,
        end: Int,
        unit: String
    ) -> Frame {
        .goal(icon: icon, goalData: .init(
            start: start,
            current: current,
            end: end,
            unit: unit
        ))
    }
}

// MARK: - GoalData

public struct GoalData: Codable, Sendable {
    /// Starting value of the goal
    public let start: Int

    /// Current progress value
    public let current: Int

    /// Target/end value of the goal
    public let end: Int

    /// Unit of measurement (e.g., "%", "steps", "km")
    public let unit: String

    public init(start: Int, current: Int, end: Int, unit: String) {
        self.start = start
        self.current = current
        self.end = end
        self.unit = unit
    }
}

// MARK: - Frame Codable Implementation

extension Frame {
    private enum CodingKeys: String, CodingKey {
        case icon
        case text
        case goalData
        case chartData
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let chartData = try container.decodeIfPresent([Int].self, forKey: .chartData) {
            self = .chart(data: chartData)
        } else if let goalData = try container.decodeIfPresent(GoalData.self, forKey: .goalData) {
            let icon = try container.decodeIfPresent(String.self, forKey: .icon)
            self = .goal(icon: icon, goalData: goalData)
        } else {
            let icon = try container.decodeIfPresent(String.self, forKey: .icon)
            let text = try container.decodeIfPresent(String.self, forKey: .text)
            self = .simple(icon: icon, text: text)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let .simple(icon, text):
            try container.encodeIfPresent(icon, forKey: .icon)
            try container.encodeIfPresent(text, forKey: .text)

        case let .goal(icon, goalData):
            try container.encodeIfPresent(icon, forKey: .icon)
            try container.encode(goalData, forKey: .goalData)

        case let .chart(chartData):
            try container.encode(chartData, forKey: .chartData)
        }
    }
}

// MARK: - Enums

public enum Priority: String, Codable, Sendable, CaseIterable {
    case info
    case warning
    case critical
}

public enum IconType: String, Codable, Sendable, CaseIterable {
    case none
    case info
    case alert
}
