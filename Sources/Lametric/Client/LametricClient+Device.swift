import LametricFoundation

public extension LametricClient {
    struct Device {
        private let executor: HTTPExecutor

        internal init(executor: HTTPExecutor) {
            self.executor = executor
        }

        /// Gets the current device state
        public func getState() async throws -> Response<DeviceState> {
            try await executor.executeRequest(for: Endpoints.Device.state)
        }
        
        /// Sets the device mode
        public func setMode(_ mode: DeviceState.Mode) async throws -> Response<SetModeResponse> {
            try await executor.executeRequest(for: Endpoints.Device.setMode(mode))
        }
    }
}
