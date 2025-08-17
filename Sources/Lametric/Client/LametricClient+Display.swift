import AsyncHTTPClient
import LametricFoundation

public extension LametricClient {
    struct Display {
        private let executor: RequestExecutor
        
        internal init(executor: RequestExecutor) {
            self.executor = executor
        }
        
        /// Gets the current display state
        public func getState() async throws -> Response<LametricFoundation.Display> {
            try await executor.executeRequest(for: Endpoints.DisplayState.get)
        }

        /// Updates the display state
        @discardableResult
        public func setState(_ update: DisplayStateUpdate) async throws -> Response<DisplaySuccessResponse> {
            try await executor.executeRequest(for: Endpoints.DisplayState.put(update))
        }
    }
}
