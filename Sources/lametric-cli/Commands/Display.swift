import ArgumentParser
import Lametric
import LametricFoundation
import PrettyPrint

struct DisplayCommand: AsyncParsableCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "display",
            abstract: "Manage display settings",
            subcommands: [
                GetStateCommand.self,
                SetBrightnessCommand.self
            ],
            defaultSubcommand: GetStateCommand.self
        )
    }
}

extension DisplayCommand {
    struct GetStateCommand: AsyncParsableCommand {
        static var configuration: CommandConfiguration {
            CommandConfiguration(
                commandName: "get-state",
                abstract: "Get current display state"
            )
        }

        @OptionGroup
        var options: LametricCLI.Options

        func run() async throws {
            let client = try options.makeClient()
            let display = try await client.display.getState().required

            print("Display state:".foregroundColor(.green))
            prettyPrint(display, includeTypeName: false)
        }
    }

    struct SetBrightnessCommand: AsyncParsableCommand {
        static var configuration: CommandConfiguration {
            CommandConfiguration(
                commandName: "set-brightness",
                abstract: "Set the display brightness"
            )
        }

        @OptionGroup
        var options: LametricCLI.Options

        @Argument(help: "Brightness level (0-100)")
        var brightness: Int

        @Option(help: "Brightness mode: auto or manual")
        var mode: BrightnessMode = .manual

        func validate() throws {
            guard brightness >= 0 && brightness <= 100 else {
                throw ValidationError("Brightness must be between 0 and 100")
            }
        }

        func run() async throws {
            let client = try options.makeClient()

            let update = DisplayStateUpdate(
                brightness: brightness,
                brightnessMode: mode
            )

            let response = try await client.display.setState(update).required

            if options.verbose {
                print("Display info:".bold())
                prettyPrint(response.success.data, includeTypeName: false)
                print()
            }

            print("Display brightness set to \(brightness)% (\(mode) mode)".foregroundColor(.green))
        }
    }
}

extension BrightnessMode: ExpressibleByArgument {}
