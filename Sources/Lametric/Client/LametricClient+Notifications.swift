import LametricFoundation

public extension LametricClient {
    struct Notifications {
        private let executor: HTTPExecutor

        internal init(executor: HTTPExecutor) {
            self.executor = executor
        }

        /// Sends a notification to the device
        @discardableResult
        public func send(_ notification: LametricFoundation.Notification) async throws -> Response<NotificationSuccessResponse> {
            try await executor.executeRequest(for: Endpoints.Notifications.send(notification))
        }

        /// Returns the list of notifications in queue
        public func getQueue() async throws -> Response<NotificationQueueResponse> {
            try await executor.executeRequest(for: Endpoints.Notifications.getQueue)
        }

        /// Removes notification from queue or dismisses if it is visible
        @discardableResult
        public func remove(id: String) async throws -> Response<DismissNotificationResponse> {
            try await executor.executeRequest(for: Endpoints.Notifications.remove(id))
        }
    }
}
