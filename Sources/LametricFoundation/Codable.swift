import Foundation

/// All models in this package should be encoded and decoded using this encoder and decoder,
/// as they are configured to use snake_case, and the models are named in camelCase.

public let lametricJSONEncoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    return encoder
}()

public let lametricJSONDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
}()
