import Foundation

public struct Display: Codable, Sendable {
    public let brightness: Int
    public let brightnessMode: BrightnessMode
    public let height: Int
    public let width: Int
    public let type: DisplayType
    public let brightnessRange: ValueRange<Int>
    public let brightnessLimit: ValueRange<Int>
    public let screensaver: Screensaver?
}

public struct ValueRange<T: Codable & Sendable>: Codable, Sendable {
    public let max: T
    public let min: T
}

public enum BrightnessMode: String, Codable, Sendable, CaseIterable {
    case auto
    case manual
}

public enum DisplayType: String, Codable, Sendable, CaseIterable {
    case monochrome
    case grayscale
    case color
    case mixed
    case fullRGB = "full_rgb"
}

public struct Screensaver: Codable, Sendable {
    public let enabled: Bool
    public let modes: Mode
    public let widget: String

    public struct Mode: Codable, Sendable {
        public let timeBased: TimeBased
        public let whenDark: WhenDark

        public struct TimeBased: Codable, Sendable {
            public let enabled: Bool
            public let startTime: String
            public let endTime: String
            public let localStartTime: String?
            public let localEndTime: String?
        }

        public struct WhenDark: Codable, Sendable {
            public let enabled: Bool
        }
    }
}

public struct DisplayStateUpdate: Codable, Sendable {
    /// Display brightness (0-100)
    public let brightness: Int?

    /// Brightness mode (auto or manual)
    public let brightnessMode: BrightnessMode?

    /// Screensaver configuration
    public let screensaver: ScreensaverUpdate?

    public init(
        brightness: Int? = nil,
        brightnessMode: BrightnessMode? = nil,
        screensaver: ScreensaverUpdate? = nil
    ) {
        self.brightness = brightness
        self.brightnessMode = brightnessMode
        self.screensaver = screensaver
    }
}

public struct ScreensaverUpdate: Codable, Sendable {
    /// Enable or disable screensaver
    public let enabled: Bool?
    
    /// Screensaver mode
    public let mode: ScreensaverMode?
    
    /// Mode-specific parameters
    public let modeParams: ScreensaverModeParams?
    
    public init(
        enabled: Bool? = nil,
        mode: ScreensaverMode? = nil,
        modeParams: ScreensaverModeParams? = nil
    ) {
        self.enabled = enabled
        self.mode = mode
        self.modeParams = modeParams
    }
    
    /// Create screensaver update for when-dark mode
    public static func whenDark(enabled: Bool) -> ScreensaverUpdate {
        .init(
            enabled: true,
            mode: .whenDark,
            modeParams: ScreensaverModeParams(enabled: enabled)
        )
    }
    
    /// Create screensaver update for time-based mode
    public static func timeBased(
        enabled: Bool,
        startTime: String,
        endTime: String
    ) -> ScreensaverUpdate {
        .init(
            enabled: true,
            mode: .timeBased,
            modeParams: ScreensaverModeParams(
                enabled: enabled,
                startTime: startTime,
                endTime: endTime
            )
        )
    }
}

public enum ScreensaverMode: String, Codable, Sendable, CaseIterable {
    case whenDark = "when_dark"
    case timeBased = "time_based"
}

public struct ScreensaverModeParams: Codable, Sendable {
    /// Enable this specific mode
    public let enabled: Bool?

    /// Start time for time-based mode (GMT, HH:mm:ss format)
    public let startTime: String?

    /// End time for time-based mode (GMT, HH:mm:ss format)
    public let endTime: String?

    public init(
        enabled: Bool? = nil,
        startTime: String? = nil,
        endTime: String? = nil
    ) {
        self.enabled = enabled
        self.startTime = startTime
        self.endTime = endTime
    }
}
