import LametricFoundation

public extension LametricClient {
    struct Apps {
        private let executor: HTTPExecutor

        internal init(executor: HTTPExecutor) {
            self.executor = executor
        }

        /// Returns the list of installed apps
        public func getAll() async throws -> Response<AppsListResponse> {
            try await executor.executeRequest(for: Endpoints.Apps.getAll)
        }

        /// Switches to next app
        @discardableResult
        public func switchToNext() async throws -> Response<SwitchAppResponse> {
            try await executor.executeRequest(for: Endpoints.Apps.switchToNext)
        }

        /// Switches to previous app
        @discardableResult
        public func switchToPrevious() async throws -> Response<SwitchAppResponse> {
            try await executor.executeRequest(for: Endpoints.Apps.switchToPrevious)
        }

        /// Returns info about installed app identified by package name
        public func getApp(package: String) async throws -> Response<App> {
            try await executor.executeRequest(for: Endpoints.Apps.getApp(package))
        }

        /// Sends application specific action to a widget
        @discardableResult
        public func sendAction(
            package: String,
            widgetId: String,
            action: AppAction
        ) async throws -> Response<AppActionResponse> {
            try await executor.executeRequest(for: Endpoints.Apps.sendAction(
                package: package,
                widgetId: widgetId,
                action: action
            ))
        }

        /// Activates specific widget (app instance)
        @discardableResult
        public func activateWidget(
            package: String,
            widgetId: String
        ) async throws -> Response<ActivateWidgetResponse> {
            try await executor.executeRequest(for: Endpoints.Apps.activateWidget(
                package: package,
                widgetId: widgetId
            ))
        }
    }
}
