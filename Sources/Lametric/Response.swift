import Foundation
import LametricFoundation

public struct Response<T: Decodable> {
    public let decoded: T?
    private let data: Data?
    private let statusCode: UInt

    init(_ data: Data?, statusCode: UInt) throws {
        decoded = data.flatMap {
            try? lametricJSONDecoder.decode(T.self, from: $0)
        }
        self.data = data
        self.statusCode = statusCode
    }

    init(_ data: Data?, statusCode: Int) throws {
        try self.init(data, statusCode: UInt(statusCode))
    }

    public var isValid: Bool {
        (200..<300).contains(statusCode)
    }

    public var required: T {
        get throws {
            guard isValid else {
                throw Error.invalidStatusCode(statusCode)
            }

            guard let data, !data.isEmpty else {
                throw Error.emptyResponse
            }

            guard let decoded else {
                do {
                    return try lametricJSONDecoder.decode(T.self, from: data)
                } catch {
                    throw Error.decodingFailure(
                        (try? prettyPrinted) ?? String(data: data, encoding: .utf8) ?? "[Invalid UTF-8]",
                        error
                    )
                }
            }

            return decoded
        }
    }

    public var prettyPrinted: String {
        get throws {
            guard let data, !data.isEmpty else {
                return "[Empty Response]"
            }

            do {
                let object = try JSONSerialization.jsonObject(with: data)
                let prettyData = try JSONSerialization.data(
                    withJSONObject: object,
                    options: .prettyPrinted
                )

                guard let string = String(data: prettyData, encoding: .utf8) else {
                    throw Error.invalidJSONResponse
                }

                return string
            } catch {
                let plainString = String(data: data, encoding: .utf8) ?? "[Invalid UTF-8]"
                guard !plainString.isEmpty else {
                    return "Empty Response"
                }

                return plainString
            }
        }
    }
}
