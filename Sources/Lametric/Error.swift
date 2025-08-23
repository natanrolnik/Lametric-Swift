import Foundation

public enum Error: Swift.Error {
    case invalidApiKey
    case emptyResponse
    case timeout
    case invalidStatusCode(UInt)
    case invalidJSONResponse
    case decodingFailure(String, Swift.Error)
    case invalidURL
    case invalidResponse
}

extension Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .invalidApiKey:
            "Invalid API key"
        case .emptyResponse:
            "Empty response"
        case .timeout:
            "The request timed out. When using local, make sure that the device name is correct"
        case let .invalidStatusCode(code):
            "Invalid status code: \(code)"
        case .invalidJSONResponse:
            "The response could not be parsed as JSON"
        case let .decodingFailure(rawString, error):
            "Failed to decode JSON: \(rawString)\nError: \(error)"
        case .invalidURL:
            "Invalid URL"
        case .invalidResponse:
            "Invalid response"
        }
    }
}
