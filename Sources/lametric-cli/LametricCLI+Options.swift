import ArgumentParser
import Foundation
import Lametric

extension LametricCLI {
    struct Options: ParsableArguments {
        @Option(
            name: [.customLong("local-device-name"), .customShort("n")],
            help: """
            The name of the device in the local network.
            Either this or --remote-host must be specified.
            The `LAMETRIC_DEVICE_NAME` environment variable can be used instead.
            """
        )
        var _localDeviceName: String?

        fileprivate var localDeviceName: String? {
            _localDeviceName ?? ProcessInfo.processInfo.environment["LAMETRIC_DEVICE_NAME"]
        }

        @Option(
            name: [.customLong("remote-host"), .customShort("h")],
            help: """
            The remote host that exposes your Lametric device to the web.
            Either this or --local-device-name must be specified.
            The `LAMETRIC_REMOTE_HOST` environment variable can be used instead.
            """
        )
        var _remoteHost: String?

        fileprivate var remoteHost: String? {
            _remoteHost ?? ProcessInfo.processInfo.environment["LAMETRIC_REMOTE_HOST"]
        }

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
            guard localDeviceName != nil || remoteHost != nil else {
                throw ValidationError("""
                Please specify either one of the following options:
                  - a local device name using the --local-device-name (-n) option
                  - a remote host using the --remote-host (-h) option
                
                You can also set one of the following environment variables:
                  - `LAMETRIC_DEVICE_NAME`
                  - `LAMETRIC_REMOTE_HOST`
                """
                )
            }

            guard !(localDeviceName != nil && remoteHost != nil) else {
                throw ValidationError("Please specify either a local device name OR a remote host, not both.")
            }

            guard apiKey != nil else {
                throw ValidationError("Please specify an API key using --api-key (-k) or set the LAMETRIC_API_KEY environment variable.")
            }
        }
    }
}

extension LametricCLI.Options {
    func makeClient() throws -> LametricClient {
        let mode: LametricClient.Mode = if let localDeviceName {
            .local(name: localDeviceName)
        } else if let remoteHost {
            .remote(domain: remoteHost)
        } else {
            // This should never happen due to validation, but we include it for safety
            throw ValidationError("Neither local device name nor remote host is available.")
        }

        return try LametricClient(
            apiKey: apiKey ?? "",
            mode: mode,
            verbose: verbose
        )
    }
}
