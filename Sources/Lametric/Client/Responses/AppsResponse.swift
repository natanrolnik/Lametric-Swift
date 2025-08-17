import Foundation
import LametricFoundation

// MARK: - Apps Response Models

public typealias AppsListResponse = [String: App]

// MARK: - Type Aliases

public typealias AppActionResponse = SuccessDataResponse<[String: String]>
public typealias ActivateWidgetResponse = SuccessDataResponse<EmptyResponse>
public typealias SwitchAppResponse = SuccessDataResponse<EmptyResponse>

public struct EmptyResponse: Decodable, Sendable {}
