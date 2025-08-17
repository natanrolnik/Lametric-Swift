import Foundation

public struct ListEndpointsResponse: Decodable, Sendable {
    public let apiVersion: String
    public let endpoints: [String: String]
}
