import Foundation
import LametricFoundation

// MARK: - Notification Responses

public struct NotificationCreatedResponse: Codable, Sendable {
    public let id: String
}

public struct NotificationQueueItem: Codable, Sendable {
    public let id: String
    public let type: NotificationType
    public let priority: Priority
    public let created: String
    public let expirationDate: String
    public let model: Model
}

public enum NotificationType: String, Codable, Sendable {
    case `internal`
    case external
}

// MARK: - Type Aliases

public typealias NotificationSuccessResponse = SuccessResponse<NotificationCreatedResponse>
public typealias NotificationQueueResponse = [NotificationQueueItem]
public typealias DismissNotificationResponse = SimpleSuccessResponse
