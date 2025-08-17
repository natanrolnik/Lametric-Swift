import ArgumentParser
import Lametric
import LametricFoundation
import PrettyPrint
import ColorizeSwift

struct NotificationsCommand: AsyncParsableCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "notifications",
            abstract: "Manage notifications",
            subcommands: [
                SendCommand.self,
                ListCommand.self,
                RemoveCommand.self
            ]
        )
    }
}

extension NotificationsCommand {
    struct SendCommand: AsyncParsableCommand {
        static var configuration: CommandConfiguration {
            CommandConfiguration(
                commandName: "send",
                abstract: "Send a notification to the device"
            )
        }

        @OptionGroup
        var options: LametricCLI.Options

        @Option(help: "The notification text")
        var text: String

        @Option(help: "Icon ID (e.g., 'i298' for standard icons)")
        var icon: String?

        @Option(help: "The notification priority")
        var priority: Priority = .info

        @Option(help: "The system icon to be displayed before the notification.")
        var iconType: IconType = .none

        @Option(help: "Number of times to show the notification")
        var cycles: Int = 1

        func run() async throws {
            let client = try options.makeClient()

            let frame = Frame.simple(
                icon: icon,
                text: text
            )

            let notification = Notification(
                model: Model(frames: [frame], cycles: cycles),
                priority: priority,
                iconType: iconType,
                lifetime: nil,
            )

            let response = try await client.notifications.send(notification)

            if options.verbose {
                print("Sent notification:".bold())
                prettyPrint(try response.required)
                print()
            }

            let id = try response.required.success.id
            print("Notification sent successfully. Id: \(id)".foregroundColor(.green))
        }
    }

    struct ListCommand: AsyncParsableCommand {
        static var configuration: CommandConfiguration {
            CommandConfiguration(
                commandName: "list",
                abstract: "List notifications in the device's queue"
            )
        }

        @OptionGroup
        var options: LametricCLI.Options

        func run() async throws {
            let client = try options.makeClient()
            let response = try await client.notifications.getQueue()

            let queue = try response.required

            guard !queue.isEmpty else {
                print("No notifications in queue".foregroundColor(.green))
                return
            }

            print("\(queue.count) notification(s) in queue:".foregroundColor(.green))
            for (index, notification) in queue.enumerated() {
                print("\(index + 1). ID: \(notification.id)")
                print("   Type: \(notification.type)")
                print("   Created: \(notification.created)", terminator: "\n\n")
            }
        }
    }

    struct RemoveCommand: AsyncParsableCommand {
        static var configuration: CommandConfiguration {
            CommandConfiguration(
                commandName: "remove",
                abstract: "Remove a notification from the device's queue"
            )
        }

        @OptionGroup
        var options: LametricCLI.Options

        @Argument(help: "The notification ID to remove")
        var id: String

        func run() async throws {
            let client = try options.makeClient()
            try await client.notifications.remove(id: id)

            print("Notification with id \(id) removed successfully".foregroundColor(.green))
        }
    }
}

extension Priority: ExpressibleByArgument {}
extension IconType: ExpressibleByArgument {}
