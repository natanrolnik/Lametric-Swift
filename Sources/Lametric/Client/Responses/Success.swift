import Foundation

// MARK: - Generic Success Response

public struct SuccessResponse<T: Decodable>: Decodable, Sendable where T: Sendable {
    public let success: T
}

public struct SuccessDataResponse<T: Decodable>: Decodable, Sendable where T: Sendable {
    public let success: SuccessData<T>
}

public struct SuccessData<T: Decodable>: Decodable, Sendable where T: Sendable {
    public let data: T
    public let path: String
}

// MARK: - Simple Success Response

public struct SimpleSuccessResponse: Decodable, Sendable {
    public let success: Bool
}
