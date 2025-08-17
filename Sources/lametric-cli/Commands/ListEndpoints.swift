import ArgumentParser
import Lametric
import PrettyPrint

struct ListEndpointsCommand: AsyncParsableCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "list-endpoints",
            abstract: "List the available endpoints"
        )
    }

    @OptionGroup
    var options: LametricCLI.Options

    func run() async throws {
        let client = try options.makeClient()
        let deviceState = try await client.listEndpoints()

        prettyPrint(try deviceState.required)
    }
}
