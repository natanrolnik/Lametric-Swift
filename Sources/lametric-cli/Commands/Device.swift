import ArgumentParser
import ColorizeSwift
import Lametric
import LametricFoundation
import PrettyPrint

struct DeviceCommand: AsyncParsableCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "device",
            abstract: "Manage device settings",
            subcommands: [
                InfoCommand.self,
                SetModeCommand.self
            ]
        )
    }
}

// MARK: - Device Information

extension DeviceCommand {
    struct InfoCommand: AsyncParsableCommand {
        static var configuration: CommandConfiguration {
            CommandConfiguration(
                commandName: "info",
                abstract: "Get the device state"
            )
        }

        @OptionGroup
        var options: LametricCLI.Options

        func run() async throws {
            let client = try options.makeClient()
            let deviceState = try await client.device.getState().required
            print("\(deviceState.name) info:".foregroundColor(.green))
            prettyPrint(deviceState, includeTypeName: false)
        }
    }

    struct SetModeCommand: AsyncParsableCommand {
        static var configuration: CommandConfiguration {
            CommandConfiguration(
                commandName: "set-mode",
                abstract: "Change the device mode"
            )
        }

        @OptionGroup
        var options: LametricCLI.Options

        @Argument(help: "The device mode to set")
        var mode: DeviceState.Mode

        func run() async throws {
            let client = try options.makeClient()
            let response = try await client.device.setMode(mode)

            let mode = try response.required.success.data.mode
            print("Device mode set to '\(mode.rawValue)' successfully".foregroundColor(.green))
        }
    }
}

// MARK: - ArgumentParser Extensions

extension DeviceState.Mode: ExpressibleByArgument {}
