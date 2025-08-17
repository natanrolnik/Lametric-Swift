import Foundation

public struct AppAction: Codable, Sendable {
    public let id: String
    public let params: [String: AnyCodable]?
    public let activate: Bool?

    public init(id: String, params: [String: AnyCodable]? = nil, activate: Bool? = nil) {
        self.id = id
        self.params = params
        self.activate = activate
    }
}

// Helper for encoding any codable value
public struct AnyCodable: Codable, Sendable {
    public let value: Sendable

    public init<T: Codable & Sendable>(_ value: T) {
        self.value = value
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch value {
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let string as String:
            try container.encode(string)
        case let double as Double:
            try container.encode(double)
        default:
            throw EncodingError.invalidValue(value, EncodingError.Context(
                codingPath: container.codingPath,
                debugDescription: "Unsupported type for AnyCodable"
            ))
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else {
            throw DecodingError.typeMismatch(AnyCodable.self, DecodingError.Context(
                codingPath: container.codingPath,
                debugDescription: "Cannot decode AnyCodable"
            ))
        }
    }
}
