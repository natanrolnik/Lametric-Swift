import ArgumentParser
import ColorizeSwift
import Lametric
import PrettyPrint

struct DeviceCommand: AsyncParsableCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "device",
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
