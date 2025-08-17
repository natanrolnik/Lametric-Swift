import Foundation
import LametricFoundation
import NIO

#if os(Linux)
import NIOFoundationCompat
#endif

public struct Response<T: Decodable> {
    public let decoded: T?
    private let byteBuffer: ByteBuffer?
    private let statusCode: UInt

    init(_ byteBuffer: ByteBuffer?, statusCode: UInt) throws {
        decoded = byteBuffer.flatMap {
            try? lametricJSONDecoder.decode(T.self, from: $0)
        }
        self.byteBuffer = byteBuffer
        self.statusCode = statusCode
    }

    public var isValid: Bool {
        (200..<300).contains(statusCode)
    }

    public var required: T {
        get throws {
            guard isValid else {
                throw Error.invalidStatusCode(statusCode)
            }

            guard let byteBuffer, byteBuffer.readableBytes > 0 else {
                throw Error.emptyResponse
            }

            guard let decoded else {
                do {
                    return try lametricJSONDecoder.decode(T.self, from: byteBuffer)
                } catch {
                    throw Error.decodingFailure(
                        (try? prettyPrinted) ?? String(buffer: byteBuffer),
                        error
                    )
                }
            }

            return decoded
        }
    }

    public var prettyPrinted: String {
        get throws {
            guard let byteBuffer, byteBuffer.readableBytes > 0 else {
                return "[Empty Response]"
            }

            do {
                let object = try JSONSerialization.jsonObject(with: byteBuffer)
                let prettyData = try JSONSerialization.data(
                    withJSONObject: object,
                    options: .prettyPrinted
                )

                guard let string = String(data: prettyData, encoding: .utf8) else {
                    throw Error.invalidJSONResponse
                }

                return string
            } catch {
                let plainString = String(buffer: byteBuffer)
                guard !plainString.isEmpty else {
                    return "Empty Response"
                }

                return plainString
            }
        }
    }
}
