import LametricFoundation

public extension LametricClient.Apps {
    /// Configures alarm clock
    func configureAlarm(
        enabled: Bool? = nil,
        time: String? = nil,
        wakeWithRadio: Bool? = nil,
        widgetId: String
    ) async throws -> Response<AppActionResponse> {
        var params: [String: AnyCodable] = [:]

        if let enabled = enabled {
            params["enabled"] = AnyCodable(enabled)
        }
        if let time = time {
            params["time"] = AnyCodable(time)
        }
        if let wakeWithRadio = wakeWithRadio {
            params["wake_with_radio"] = AnyCodable(wakeWithRadio)
        }

        let action = AppAction(
            id: "clock.alarm",
            params: params.isEmpty ? nil : params,
            activate: true
        )

        return try await sendAction(
            package: "com.lametric.clock",
            widgetId: widgetId,
            action: action
        )
    }

    /// Controls radio playback
    func controlRadio(
        action: RadioAction,
        widgetId: String
    ) async throws -> Response<AppActionResponse> {
        let actionId: String
        switch action {
        case .play: actionId = "radio.play"
        case .stop: actionId = "radio.stop"
        case .next: actionId = "radio.next"
        case .previous: actionId = "radio.prev"
        }

        let radioAction = AppAction(
            id: actionId,
            activate: true
        )

        return try await sendAction(
            package: "com.lametric.radio",
            widgetId: widgetId,
            action: radioAction
        )
    }

    /// Configures countdown timer
    func configureCountdown(
        duration: Int? = nil,
        startNow: Bool? = nil,
        widgetId: String
    ) async throws -> Response<AppActionResponse> {
        var params: [String: AnyCodable] = [:]

        if let duration = duration {
            params["duration"] = AnyCodable(duration)
        }
        if let startNow = startNow {
            params["start_now"] = AnyCodable(startNow)
        }

        let action = AppAction(
            id: "countdown.configure",
            params: params.isEmpty ? nil : params,
            activate: true
        )

        return try await sendAction(
            package: "com.lametric.countdown",
            widgetId: widgetId,
            action: action
        )
    }

    /// Controls countdown timer
    func controlCountdown(
        action: CountdownAction,
        widgetId: String
    ) async throws -> Response<AppActionResponse> {
        let actionId: String
        switch action {
        case .start: actionId = "countdown.start"
        case .pause: actionId = "countdown.pause"
        case .reset: actionId = "countdown.reset"
        }

        let countdownAction = AppAction(
            id: actionId,
            activate: true
        )

        return try await sendAction(
            package: "com.lametric.countdown",
            widgetId: widgetId,
            action: countdownAction
        )
    }

    /// Controls stopwatch
    func controlStopwatch(
        action: StopwatchAction,
        widgetId: String
    ) async throws -> Response<AppActionResponse> {
        let actionId: String
        switch action {
        case .start: actionId = "stopwatch.start"
        case .pause: actionId = "stopwatch.pause"
        case .reset: actionId = "stopwatch.reset"
        }

        let stopwatchAction = AppAction(
            id: actionId,
            activate: true
        )

        return try await sendAction(
            package: "com.lametric.stopwatch",
            widgetId: widgetId,
            action: stopwatchAction
        )
    }

    /// Shows weather forecast
    func showWeatherForecast(widgetId: String) async throws -> Response<AppActionResponse> {
        let action = AppAction(
            id: "weather.forecast",
            activate: true
        )

        return try await sendAction(
            package: "com.lametric.weather",
            widgetId: widgetId,
            action: action
        )
    }
}

// MARK: - Action Enums

public enum RadioAction {
    case play
    case stop
    case next
    case previous
}

public enum CountdownAction {
    case start
    case pause
    case reset
}

public enum StopwatchAction {
    case start
    case pause
    case reset
}
