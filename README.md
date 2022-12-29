# SwiftSerial

A Swift wrapper around the system functions to interact with serial interfaces based on `async/await`.

Ports are implemented using the Swift `actor` pattern, which provides thread safety and asynchronous interactions with the interfaces.

## Usage

`SwiftSerial` provides an easy way to interact with serial interfaces.

```swift

// Create the port
let serial = SerialPort(path: "/dev/ttyUSB0")

// Configure and open
try await serial.open(
    receiveRate: .baud112500, 
    transmitRate: .baud112500, 
    parity: .none, 
    stopBits: .one, 
    dataBits: .eight)
    
// Receive data
let data = try await serial.readBytes(count: 10)

// Wait for data to arrive
let data2 = try await serial.readBytesBlocking(count: 10, timeout: 1.0)

// Transmit data
try await serial.writeBytes([0x00, 0x01, 0x02, 0x04])

// Close the port when finished
serial.close()
```

## Installation

Include the package in your `Package.swift` file: 

```swift
...
    dependencies: [.package(url: "https://github.com/christophhagen/SwiftSerial", from: "1.0.0")
...
    .target(name: "MyTarget", dependencies: [.product(name: "SwiftSerial", package: "SwiftSerial")]),
...
```

## License

MIT.

## Thanks

This library is loosly based on [SerialSwift](https://github.com/yeokm1/SwiftSerial) (the name just made sense), but re-implemented to use `async/await`, with a bit fewer functions, but more documentation.
