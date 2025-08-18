![Lametric-Swift](.github/media/Hero-Dark.png#gh-dark-mode-only)
![Lametric-Swift](.github/media/Hero-Light.png#gh-light-mode-only)

<p align="center">
  A Swift package for interacting with LaMetric Time and Sky devices, providing both a client library and command-line interface
  <hr>
</p>

> [!NOTE]
> This package is **not affiliated with LaMetric**, but rather a personal project that can help others to interact with their LaMetric devices, from the command line on macOS or Linux, and from Swift code.

## Overview

This package consists of three main components:

- **LametricFoundation**: Core models and data structures for interacting with LaMetric APIs
- **Lametric**: HTTP client library for interacting with LaMetric devices
- **lametric**: A command-line interface if you want to interact with your device from the terminal (macOS or Linux)

## Features

- 🔌 Support for both local and remote device connections (if you expose your device to the internet)
- 📱 Send notifications with text, icons, charts, and goal progress
- 🎵 Play notification sounds and alarms (not supported in the Lametric Sky, only Lametric Time)
- 📊 Display device state and manage notifications queue
- 🖥️ Control display brightness, manage apps and widgets
- 🛠️ Full-featured CLI for all operations supported by the package

## Installation

### Using Swift Package Manager

Add this package to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/natanrolnik/lametric-swift.git", from: "0.1.0")
]
```

Then add the appropriate target dependency:

```swift
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "Lametric", package: "lametric-swift"),           // For client library
            .product(name: "LametricFoundation", package: "lametric-swift")  // For models only
        ]
    )
]
```

### CLI Installation with Mise

Install the CLI using [mise](https://mise.jdx.dev/) (JDX's tool version manager):

1. **Install mise** (if not already installed):
```bash
curl https://mise.run | sh
```

2. **Install the lametric CLI** from GitHub releases:
```bash
# Install globally
mise use -g "ubi:natanrolnik/lametric-swift[exe=lametric]"

# Install specific version
mise use -g "ubi:natanrolnik/lametric-swift[exe=lametric]@0.1.0"
```

3. **Verify installation**:
```bash
lametric --help
```

> [!TIP]
> Alternatively, download pre-built binaries from the [releases page](https://github.com/natanrolnik/lametric-swift/releases) and place them manually in your PATH.

## Usage

### Library Usage

#### Basic Setup

```swift
import Lametric
import LametricFoundation

// For a local device (recommended for Raspberry Pi, local servers)
let client = try LametricClient(
    apiKey: "your-device-api-key",
    connection: .local(name: "your-device-name")  // e.g., "sky3845" or "time1234"
)

// For a device being exposed to the internet via a proxy
let client = try LametricClient(
    apiKey: "your-device-api-key", 
    connection: .url(host: "your-domain.com")
)
```

#### Sending Notifications

```swift
// Simple text notification
let notification = Notification(
    frames: [.text("Hello World!")],
    priority: .info
)

let response = try await client.notifications.send(notification)
print("Notification ID: \(response.required.success.data.id)")
```

```swift
// Notification with icon and sound (only in the Lametric Time, not in the Lametric Sky)
let notification = Notification(
    frames: [.iconAndText(icon: "i298", text: "Temperature: 22°C")],
    sound: .notification(id: .positive1),
    priority: .warning
)

try await client.notifications.send(notification)
```

More complex notifications are available by using different `Frame` types. Besides icon and text, you can also use:

- `.goal(icon: String?, goalData: GoalData)` to display a goal progress
- `.chart(data: [Int])` to display a chart

#### Server Applications

If you want to develop a Lametric app that polls a server, you can use the **LametricFoundation** target only for the models, without importing the target containing the client and all the endpoints.

For example, when Lametric polls your server, you should return a `Model` object with a `frames` array:

```swift
import Vapor
import Lametric
import LametricFoundation

func routes(_ app: Application) throws {
    app.get("next-lametric-state") { req -> Model in
        return Model(frames: [
            .iconAndText(icon: "i69917", text: "Hello from Vapor!"),
            .text("")
        ])
    }
}
```

> [!IMPORTANT]
> The Lametric API uses snake_case for the keys in the JSON payloads.
> When using only the models, without the client, you'll need to use a `JSONEncoder` or `JSONDecoder` with the snake case strategy. **LametricFoundation** provides pre-configured instances, `lametricJSONEncoder` and `lametricJSONDecoder`, for this purpose.

#### Raspberry Pi / IoT Device Example

If you want to send requests from a Mac, Raspberry Pi, or devices in the same network, you can use the **Lametric** target, which contains the HTTP client and all the endpoints.

```swift
import Foundation
import Lametric
import LametricFoundation

// Example of a system monitor that sends temperature alerts
class SystemMonitor {
    private let client: LametricClient

    init() throws {
        self.client = try LametricClient(
            apiKey: ProcessInfo.processInfo.environment["LAMETRIC_API_KEY"] ?? "",
            connection: .local(name: "time1234")
        )
    }

    func sendTemperatureAlert(temperature: Double) async throws {
        let icon = temperature > 30 ? "i120" : "i121"  // Hot/cold icons
        let priority: Priority = temperature > 50 ? .critical : .warning

        let notification = Notification(
            frames: [.iconAndText(icon: icon, text: "\(Int(temperature))°C")],
            sound: priority == .critical ? .alarm(id: .alarm1) : nil,
            priority: priority
        )

        try await client.notifications.send(notification)
    }
}
```

### CLI Usage

The CLI supports environment variables for convenient configuration. If you don't configure these, you'll need to pass the api key and the device name (or an explicit host) as options **in every command**.

```bash
export LAMETRIC_API_KEY="your-api-key"
export LAMETRIC_DEVICE_NAME="your-device-name"  # For local devices
# OR
export LAMETRIC_HOST="your-domain.com"   # For remote devices or devices in the same network with a known host
```

#### Basic Commands

```bash
# Get device information
lametric device

# Send a simple notification
lametric notifications send --text "Hello from CLI!"

# Send notification with icon and priority
lametric notifications send \
  --text "Temperature Alert" \
  --icon "i120" \
  --priority critical \
  --cycles 3

# List notifications in queue
lametric notifications list

# Control display
lametric display --brightness 50

# List installed apps
lametric apps list

# Change to next app
lametric apps next

# Change to previous app
lametric apps previous

# Activate a specific widget
lametric apps activate com.lametric.clock 1234567890
```

#### Using with Different Connection Types

```bash
# Local device (Raspberry Pi, same network)
lametric --local-device-name "lametric-12ab34" notifications send --text "Local message"

# Remote device (cloud server, exposing your local device to the internet via some proxy) or device in the same network with a known host
lametric --host "my-lametric.example.com" notifications send --text "Remote message"
```

## Configuration

### Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `LAMETRIC_API_KEY` | Device API key | `abc123def456` |
| `LAMETRIC_DEVICE_NAME` | Local device name | `sky3298` |
| `LAMETRIC_HOST` | Host domain or IP address | `my-device.example.com` or `192.168.1.100` |

### Getting Your API Key

1. Open the LaMetric Time app on your phone
2. Go to your device settings
3. Find "Developer" section
4. Copy the API key

### Finding Device Name

Your device name is typically displayed in the LaMetric Time app or can be found on your local network as `<device-name>.local`.

## Icon Reference

LaMetric supports thousands of built-in icons. Use icon IDs like:
- `i69917` - The Swift bird
- `i298` - Thermometer
- `i120` - Warning triangle  
- `i121` - Snowflake
- `i2867` - Heart
- `a7956` - Animated loading

Browse icons at: [LaMetric Icon Gallery](https://developer.lametric.com/icons)

## Requirements

- Swift 6.1+
- CLI: macOS or Linux

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
Use it at your own responsibility and risk.

## Related Links

- [LaMetric Developer Documentation](https://lametric-documentation.readthedocs.io/)
- [LaMetric Icon Gallery](https://developer.lametric.com/icons)
- [Mise Tool Manager](https://mise.jdx.dev/)
