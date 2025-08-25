import ArgumentParser
import ColorizeSwift
import Foundation
import Lametric
import LametricFoundation
import PrettyPrint

struct AppsCommand: AsyncParsableCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "apps",
            abstract: "Manage device apps",
            subcommands: [
                ListCommand.self,
                GetCommand.self,
                NextCommand.self,
                PreviousCommand.self,
                ActivateCommand.self,
                ActionCommand.self
            ]
        )
    }
}

// MARK: - Basic App Management

extension AppsCommand {
    struct ListCommand: AsyncParsableCommand {
        static var configuration: CommandConfiguration {
            CommandConfiguration(
                commandName: "list",
                abstract: "List all installed apps"
            )
        }

        @OptionGroup
        var options: LametricCLI.Options

        func run() async throws {
            let client = try options.makeClient()
            let response = try await client.apps.getAll()

            let apps = try response.required

            if options.verbose {
                print("Installed Apps:".bold())
                prettyPrint(apps, includeTypeName: false)
                print()
            }

            print("Installed Apps (\(apps.count)):", terminator: "\n\n".foregroundColor(.green))

            for (package, app) in apps.sorted(by: { $0.key < $1.key }) {
                print("📦 \(package)")
                print("   Vendor: \(app.vendor)")
                print("   Version: \(app.version)")
                print("   Widgets: \(app.widgets.count)")

                for (id, widget) in app.widgets {
                    print("      🔹 \(id), index \(widget.index) \(widget.isVisible ? "(👀 visible 👀)" : "")")
                }

                print()
            }
        }
    }

    struct GetCommand: AsyncParsableCommand {
        static var configuration: CommandConfiguration {
            CommandConfiguration(
                commandName: "get",
                abstract: "Get details about a specific app"
            )
        }

        @OptionGroup
        var options: LametricCLI.Options

        @Argument(help: "App package name (e.g., com.lametric.clock)")
        var package: String

        func run() async throws {
            let client = try options.makeClient()
            let response = try await client.apps.getApp(package: package)

            let app = try response.required

            if options.verbose {
                print("\(package) details:".bold())
                prettyPrint(app, includeTypeName: false)
                print()
            }

            print("\(app.package)".foregroundColor(.green))
            print("Vendor: \(app.vendor)")
            print("Version: \(app.version) (code: \(app.versionCode))", terminator: "\n\n")

            print("Widgets (\(app.widgets.count)):")
            for (id, widget) in app.widgets {
                print("  • \(id)\(widget.isVisible ? " (👀 visible 👀)" : "")")
                print("    Index: \(widget.index)")
                print()
            }

            if let actions = app.actions,
               !actions.isEmpty {
                print("Available Actions:")
                for (actionName, _) in actions {
                    print("  • \(actionName)")
                }
            }
        }
    }

    struct NextCommand: AsyncParsableCommand {
        static var configuration: CommandConfiguration {
            CommandConfiguration(
                commandName: "next",
                abstract: "Switch to next app"
            )
        }

        @OptionGroup
        var options: LametricCLI.Options

        func run() async throws {
            let client = try options.makeClient()
            try await client.apps.switchToNext()

            print("Switched to next app".foregroundColor(.green))
        }
    }

    struct PreviousCommand: AsyncParsableCommand {
        static var configuration: CommandConfiguration {
            CommandConfiguration(
                commandName: "previous",
                abstract: "Switch to previous app"
            )
        }

        @OptionGroup
        var options: LametricCLI.Options

        func run() async throws {
            let client = try options.makeClient()
            try await client.apps.switchToPrevious()

            print("Switched to previous app".foregroundColor(.green))
        }
    }

    struct ActivateCommand: AsyncParsableCommand {
        static var configuration: CommandConfiguration {
            CommandConfiguration(
                commandName: "activate",
                abstract: "Activate a specific widget"
            )
        }

        @OptionGroup
        var options: LametricCLI.Options

        @Argument(help: "App package name")
        var package: String

        @Argument(help: "Widget ID")
        var widgetId: String

        func run() async throws {
            let client = try options.makeClient()
            try await client.apps.activateWidget(
                package: package,
                widgetId: widgetId
            )

            print("Activated widget \(widgetId) in \(package)".foregroundColor(.green))
        }
    }

    struct ActionCommand: AsyncParsableCommand {
        static var configuration: CommandConfiguration {
            CommandConfiguration(
                commandName: "action",
                abstract: "Send custom action to a widget"
            )
        }

        @OptionGroup
        var options: LametricCLI.Options

        @Argument(help: "App package name")
        var package: String

        @Argument(help: "Widget ID")
        var widgetId: String

        @Argument(help: "Action ID")
        var actionId: String

        @Option(help: "JSON parameters for the action")
        var params: String?

        @Flag(help: "Activate widget when sending action")
        var activate: Bool = false

        func run() async throws {
            let client = try options.makeClient()

            var actionParams: [String: AnyCodable]?

            if let params = params {
                guard let data = params.data(using: .utf8),
                      let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    throw ValidationError("Invalid JSON parameters")
                }

                actionParams = [:]
                for (key, value) in json {
                    if let stringValue = value as? String {
                        actionParams![key] = AnyCodable(stringValue)
                    } else if let intValue = value as? Int {
                        actionParams![key] = AnyCodable(intValue)
                    } else if let boolValue = value as? Bool {
                        actionParams![key] = AnyCodable(boolValue)
                    } else if let doubleValue = value as? Double {
                        actionParams![key] = AnyCodable(doubleValue)
                    }
                }
            }

            let action = AppAction(
                id: actionId,
                params: actionParams,
                activate: activate ? true : nil
            )

            try await client.apps.sendAction(
                package: package,
                widgetId: widgetId,
                action: action
            )

            print("Action '\(actionId)' sent to \(package)".foregroundColor(.green))
        }
    }
}
