import Foundation

// MARK: - LaMetric App

public struct App: Codable, Sendable {
    /// Package name that identifies the app
    public let package: String

    /// App vendor/developer name
    public let vendor: String

    /// App version (e.g., "1.0.19")
    public let version: String

    /// Numeric version code
    public let versionCode: String

    /// App widgets (instances) running on the device
    public let widgets: [String: Widget]

    /// Available actions for this app
    public let actions: [String: [String: Action]]?

    public init(
        package: String,
        vendor: String,
        version: String,
        versionCode: String,
        widgets: [String: Widget],
        actions: [String: [String: Action]]
    ) {
        self.package = package
        self.vendor = vendor
        self.version = version
        self.versionCode = versionCode
        self.widgets = widgets
        self.actions = actions
    }
}

// MARK: - Widget

public struct Widget: Codable, Sendable {
    /// Position/order of the widget
    public let index: Int

    /// Package name this widget belongs to
    public let package: String

    /// Whether the widget is currently visible (API 2.3.0+)
    private let visible: Bool?

    public var isVisible: Bool { visible ?? false }

    public init(index: Int, package: String, visible: Bool? = nil) {
        self.index = index
        self.package = package
        self.visible = visible
    }
}

// MARK: - Action

public struct Action: Codable, Sendable {
    /// Data type of the parameter
    public let dataType: DataType

    /// Human-readable parameter name
    public let name: String

    /// Whether this parameter is required
    public let required: Bool

    /// Validation format/regex (optional)
    public let format: String?

    public init(
        dataType: DataType,
        name: String,
        required: Bool,
        format: String? = nil
    ) {
        self.dataType = dataType
        self.name = name
        self.required = required
        self.format = format
    }
}

// MARK: - Action Request

public struct ActionRequest: Codable, Sendable {
    /// Action identifier
    public let id: String

    /// Action parameters
    public let params: [String: ActionValue]

    /// Whether to activate/show widget when action is executed
    public let activate: Bool?

    public init(
        id: String,
        params: [String: ActionValue] = [:],
        activate: Bool? = nil
    ) {
        self.id = id
        self.params = params
        self.activate = activate
    }
}

// MARK: - Supporting Types

public enum DataType: String, Codable, Sendable {
    case bool
    case int
    case string
}

public enum ActionValue: Codable, Sendable {
    case bool(Bool)
    case int(Int)
    case string(String)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let boolValue = try? container.decode(Bool.self) {
            self = .bool(boolValue)
        } else if let intValue = try? container.decode(Int.self) {
            self = .int(intValue)
        } else if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else {
            throw DecodingError.typeMismatch(
                ActionValue.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unable to decode ActionValue"
                )
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case let .bool(value):
            try container.encode(value)
        case let .int(value):
            try container.encode(value)
        case let .string(value):
            try container.encode(value)
        }
    }
}

// MARK: - App Configuration (for push/poll setup)

public struct AppConfiguration: Codable, Sendable {
    /// The communication method for the app ("push" or "poll")
    public let communication: CommunicationType

    /// The URL from which the app fetches data (used with poll method)
    public let url: String?

    /// The access token used to authenticate push requests (used with push method)
    public let accessToken: String?

    /// The poll frequency in seconds (used with poll method)
    public let pollFrequency: Int?

    public init(
        communication: CommunicationType,
        url: String? = nil,
        accessToken: String? = nil,
        pollFrequency: Int? = nil
    ) {
        self.communication = communication
        self.url = url
        self.accessToken = accessToken
        self.pollFrequency = pollFrequency
    }

    /// Convenience initializer for push-based apps
    public static func push(accessToken: String) -> AppConfiguration {
        AppConfiguration(
            communication: .push,
            accessToken: accessToken
        )
    }

    /// Convenience initializer for poll-based apps
    public static func poll(
        url: String,
        frequency: Int = 60
    ) -> AppConfiguration {
        AppConfiguration(
            communication: .poll,
            url: url,
            pollFrequency: frequency
        )
    }
}

public enum CommunicationType: String, Codable, Sendable {
    case push
    case poll
}
