import ArgumentParser

@main
struct LametricCLI: AsyncParsableCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            abstract: "A CLI tool to interact with LaMetric Time devices.",
            subcommands: [
                DeviceCommand.self,
                DisplayCommand.self,
                NotificationsCommand.self,
                AppsCommand.self,
                ListEndpointsCommand.self
            ]
        )
    }
}
