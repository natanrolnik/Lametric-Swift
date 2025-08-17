import AsyncHTTPClient
import LametricFoundation

public extension LametricClient {
    struct Device {
        private let executor: RequestExecutor
        
        internal init(executor: RequestExecutor) {
            self.executor = executor
        }
        
        /// Gets the current device state
        public func getState() async throws -> Response<DeviceState> {
            try await executor.executeRequest(for: Endpoints.Device.state)
        }
    }
}
