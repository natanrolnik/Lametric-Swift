import ArgumentParser
import Foundation
import Lametric

extension LametricCLI {
    struct Options: ParsableArguments {
        @Option(
            name: [.customLong("local-device-name"), .customShort("n")],
            help: """
            The name of the device in the local network.
            Either this or --host must be specified.
            The `LAMETRIC_DEVICE_NAME` environment variable can be used instead.
            """
        )
        var _localDeviceName: String?

        fileprivate var localDeviceName: String? {
            _localDeviceName ?? ProcessInfo.processInfo.environment["LAMETRIC_DEVICE_NAME"]
        }

        @Option(
            name: [.customLong("host"), .customShort("h")],
            help: """
            The host that exposes your Lametric device, to the web or in a
            local network.
            Either this or --local-device-name must be specified.
            The `LAMETRIC_HOST` environment variable can be used instead.
            """
        )
        var _host: String?

        fileprivate var host: String? {
            _host ?? ProcessInfo.processInfo.environment["LAMETRIC_HOST"]
        }

        @Option(
            help: """
            The port component of the URL to connect to.
            When using a local name, defaults to 8080.
            When using an explicit host, defaults to nil. 
            """
        )
        var port: Int? = nil

        @Option(
            help: """
            The scheme component of the URL to connect to.
            When using a local name, you shouldn't use this option.
            When using an explicit host, defaults to https.
            """
        )
        var scheme: LametricClient.Scheme?

        @Option(
            name: [.customLong("api-key"), .customShort("k")],
            help: """
            The API key to use for authentication.
            The `LAMETRIC_API_KEY` environment variable can be used instead.
            """
        )
        var _apiKey: String?

        fileprivate var apiKey: String? {
            _apiKey ?? ProcessInfo.processInfo.environment["LAMETRIC_API_KEY"]
        }

        @Flag(
            name: [.customLong("verbose"), .customShort("v")],
            help: """
            When enabled, prints information about the request before calling the Lametric API.
            Use also VERBOSE=1 or VERBOSE=true to enable.
            """
        )
        var _verbose: Bool = false

        var verbose: Bool {
            if _verbose {
                return true
            }

            guard let envVerboseString = ProcessInfo.processInfo.environment["VERBOSE"] else {
                return false
            }

            return (Bool(envVerboseString) ?? false) || envVerboseString == "true"
        }

        func validate() throws {
            guard localDeviceName != nil || host != nil else {
                throw ValidationError("""
                Please specify either one of the following options:
                  - a local device name using the --local-device-name (-n) option
                  - a host using the --host (-h) option
                
                You can also set one of the following environment variables:
                  - `LAMETRIC_DEVICE_NAME`
                  - `LAMETRIC_HOST`
                """
                )
            }

            if localDeviceName != nil, scheme == .https {
                throw ValidationError("Scheme should be http when connecting to a local device using --local-device-name (-n) (or LAMETRIC_DEVICE_NAME environment variable).")
            }

            guard !(localDeviceName != nil && host != nil) else {
                throw ValidationError("Please specify either a local device name OR a host, not both.")
            }

            guard apiKey != nil else {
                throw ValidationError("Please specify an API key using --api-key (-k) or set the LAMETRIC_API_KEY environment variable.")
            }
        }
    }
}

extension LametricCLI.Options {
    func makeClient() throws -> LametricClient {
        let connection: LametricClient.Connection = if let localDeviceName {
            .local(name: localDeviceName, port: port ?? 8080)
        } else if let host {
            .url(scheme: scheme ?? .https, host: host, port: port)
        } else {
            // This should never happen due to validation, but we include it for safety
            throw ValidationError("Neither local device name nor remote host is available.")
        }

        return try LametricClient(
            apiKey: apiKey ?? "",
            connection: connection,
            verbose: verbose
        )
    }
}

extension LametricClient.Scheme: ExpressibleByArgument {}
