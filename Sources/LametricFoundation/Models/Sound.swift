import Foundation

// MARK: - Sound

public enum Sound: Codable, Sendable {
    /// Built-in notification sound
    case notification(id: NotificationSound, repeatCount: Int = 1)

    /// Built-in alarm sound
    case alarm(id: AlarmSound, repeatCount: Int = 1)

    /// Custom MP3 sound with URL and fallback
    case custom(url: String, type: AudioType = .mp3, fallback: BuiltInSound, repeatCount: Int)
}

// MARK: - Supporting Types

public enum AudioType: String, Codable, Sendable {
    case mp3
}

public enum BuiltInSound: Codable, Sendable {
    case notification(NotificationSound)
    case alarm(AlarmSound)
}

// MARK: - Sound Codable Implementation

extension Sound {
    private enum CodingKeys: String, CodingKey {
        case category, id, url, type, fallback
        case repeatCount = "repeat"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let url = try container.decodeIfPresent(String.self, forKey: .url) {
            // Custom sound
            let type = try container.decodeIfPresent(AudioType.self, forKey: .type) ?? .mp3
            let repeatCount = try container.decodeIfPresent(Int.self, forKey: .repeatCount) ?? 1
            let fallback = try container.decode(BuiltInSound.self, forKey: .fallback)
            self = .custom(url: url, type: type, fallback: fallback, repeatCount: repeatCount)
        } else {
            // Built-in sound
            let category = try container.decode(SoundCategory.self, forKey: .category)
            let id = try container.decode(String.self, forKey: .id)
            let repeatCount = try container.decodeIfPresent(Int.self, forKey: .repeatCount) ?? 1

            switch category {
            case .notifications:
                if let notificationSound = NotificationSound(rawValue: id) {
                    self = .notification(id: notificationSound, repeatCount: repeatCount)
                } else {
                    throw DecodingError.dataCorruptedError(
                        forKey: .id,
                        in: container,
                        debugDescription: "Unknown notification sound: \(id)"
                    )
                }
            case .alarms:
                if let alarmSound = AlarmSound(rawValue: id) {
                    self = .alarm(id: alarmSound, repeatCount: repeatCount)
                } else {
                    throw DecodingError.dataCorruptedError(
                        forKey: .id,
                        in: container,
                        debugDescription: "Unknown alarm sound: \(id)"
                    )
                }
            }
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let .notification(id, repeatCount):
            try container.encode(SoundCategory.notifications, forKey: .category)
            try container.encode(id.rawValue, forKey: .id)
            try container.encode(repeatCount, forKey: .repeatCount)

        case let .alarm(id, repeatCount):
            try container.encode(SoundCategory.alarms, forKey: .category)
            try container.encode(id.rawValue, forKey: .id)
            try container.encode(repeatCount, forKey: .repeatCount)

        case let .custom(url, type, fallback, repeatCount):
            try container.encode(url, forKey: .url)
            try container.encode(type, forKey: .type)
            try container.encode(fallback, forKey: .fallback)
            try container.encode(repeatCount, forKey: .repeatCount)
        }
    }
}

extension BuiltInSound {
    private enum CodingKeys: String, CodingKey {
        case category, id
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let category = try container.decode(SoundCategory.self, forKey: .category)
        let id = try container.decode(String.self, forKey: .id)

        switch category {
        case .notifications:
            if let notificationSound = NotificationSound(rawValue: id) {
                self = .notification(notificationSound)
            } else {
                throw DecodingError.dataCorruptedError(
                    forKey: .id,
                    in: container,
                    debugDescription: "Unknown notification sound: \(id)"
                )
            }
        case .alarms:
            if let alarmSound = AlarmSound(rawValue: id) {
                self = .alarm(alarmSound)
            } else {
                throw DecodingError.dataCorruptedError(
                    forKey: .id,
                    in: container,
                    debugDescription: "Unknown alarm sound: \(id)"
                )
            }
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let .notification(sound):
            try container.encode(SoundCategory.notifications, forKey: .category)
            try container.encode(sound.rawValue, forKey: .id)
        case let .alarm(sound):
            try container.encode(SoundCategory.alarms, forKey: .category)
            try container.encode(sound.rawValue, forKey: .id)
        }
    }
}

// MARK: - Sound Enums

public enum SoundCategory: String, Codable, Sendable, CaseIterable {
    case notifications
    case alarms
}

public enum NotificationSound: String, Codable, Sendable, CaseIterable {
    case bicycle
    case car
    case cash
    case cat
    case dog
    case dog2
    case energy
    case knockKnock = "knock-knock"
    case letterEmail = "letter_email"
    case lose1
    case lose2
    case negative1
    case negative2
    case negative3
    case negative4
    case negative5
    case notification
    case notification2
    case notification3
    case notification4
    case openDoor = "open_door"
    case positive1
    case positive2
    case positive3
    case positive4
    case positive5
    case positive6
    case statistic
    case thunder
    case water1
    case water2
    case win
    case win2
    case wind
    case windShort = "wind_short"
}

public enum AlarmSound: String, Codable, Sendable, CaseIterable {
    case alarm1
    case alarm2
    case alarm3
    case alarm4
    case alarm5
    case alarm6
    case alarm7
    case alarm8
    case alarm9
    case alarm10
    case alarm11
    case alarm12
    case alarm13
}
