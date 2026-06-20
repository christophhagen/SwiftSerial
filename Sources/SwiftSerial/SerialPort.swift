import Foundation

/**
 A serial port to receive and transmit data.

 The serial port is implemented as an `actor`, which forces all calls to functions and properties to be called asynchronously, but also provides threat safety.
 */
public actor SerialPort {

    /** The path of the serial port */
    public let path: String

    var fileDescriptor: Int32?

    /**
     Create a serial port interface.
     - Parameter path: The path to the serial device
     */
    public init(path: String) {
        self.path = path
    }

    /**
     Configure and open the serial port.
     - Parameter receiveRate: The baud rate for incoming data. Set to `nil` to only transmit.
     - Parameter transmitRate: The baud rate for outgoing data. Set to `nil` to only receive.
     - Parameter minimumBytesToRead: The minimum number of bytes to read before they are made available (default: `1`)
     - Parameter timout: The timeout for reading data. A timeout of `0` will let the call wait indefinitely for incoming data (default: `0`)
     - Parameter parity: The parity setting for the connection (default: `none`)
     - Parameter stopBits: The number of stop bits to use (default: `one`)
     - Parameter dataBits: The number of data bits to use (default: `eight`)
     - Parameter useHardwareFlowControl: Use hardware flow control (default: `false`)
     - Parameter useSoftwareFlowControl: Use software flow control (default: `false`)
     - Parameter processOutput: Wether to process the received output (default: `false`)
     */
    public func open(receiveRate: BaudRate? = nil,
                     transmitRate: BaudRate? = nil,
                     minimumBytesToRead: Int = 1,
                     timeout: Int = 0,
                     parity: Parity = .none,
                     stopBits: StopBits = .one,
                     dataBits: DataBits = .eight,
                     useHardwareFlowControl: Bool = false,
                     useSoftwareFlowControl: Bool = false,
                     processOutput: Bool = false) throws {

        var readWriteParam : Int32

        if receiveRate != nil && transmitRate != nil {
            readWriteParam = O_RDWR
        } else if receiveRate != nil {
            readWriteParam = O_RDONLY
        } else if transmitRate != nil {
            readWriteParam = O_WRONLY
        } else {
            throw SerialError.mustReceiveOrTransmit
        }

        fileDescriptor = openPort(path: path, readWriteParam: readWriteParam)

        // Throw error if open() failed
        if fileDescriptor == SerialError.failedToOpen.rawValue {
            fileDescriptor = nil
            throw SerialError.failedToOpen
        }

        // Set up the control structure
        var settings = termios()

        // Get options structure for the port
        tcgetattr(fileDescriptor!, &settings)

        // Set baud rates
        if let receiveRate {
            cfsetispeed(&settings, receiveRate.speedValue)
        }
        if let transmitRate {
            cfsetospeed(&settings, transmitRate.speedValue)
        }

        // Enable parity (even/odd) if needed
        settings.c_cflag |= parity.parityValue

        // Set stop bit flag
        switch stopBits {
        case .one:
            settings.c_cflag &= ~tcflag_t(CSTOPB)
        case .two:
            settings.c_cflag |= tcflag_t(CSTOPB)
        }

        // Set data bits size flag
        settings.c_cflag &= ~tcflag_t(CSIZE)
        settings.c_cflag |=  dataBits.flagValue

        //Disable input mapping of CR to NL, mapping of NL into CR, and ignoring CR
        settings.c_iflag &= ~tcflag_t(ICRNL | INLCR | IGNCR)

        // Set hardware flow control flag
    #if os(Linux)
        if useHardwareFlowControl {
            settings.c_cflag |= tcflag_t(CRTSCTS)
        } else {
            settings.c_cflag &= ~tcflag_t(CRTSCTS)
        }
    #elseif os(OSX)
        if useHardwareFlowControl {
            settings.c_cflag |= tcflag_t(CRTS_IFLOW)
            settings.c_cflag |= tcflag_t(CCTS_OFLOW)
        } else {
            settings.c_cflag &= ~tcflag_t(CRTS_IFLOW)
            settings.c_cflag &= ~tcflag_t(CCTS_OFLOW)
        }
    #endif

        // Set software flow control flags
        let softwareFlowControlFlags = tcflag_t(IXON | IXOFF | IXANY)
        if useSoftwareFlowControl {
            settings.c_iflag |= softwareFlowControlFlags
        } else {
            settings.c_iflag &= ~softwareFlowControlFlags
        }

        // Turn on the receiver of the serial port, and ignore modem control lines
        settings.c_cflag |= tcflag_t(CREAD | CLOCAL)

        // Turn off canonical mode
        settings.c_lflag &= ~tcflag_t(ICANON | ECHO | ECHOE | ISIG)

        // Set output processing flag
        if processOutput {
            settings.c_oflag |= tcflag_t(OPOST)
        } else {
            settings.c_oflag &= ~tcflag_t(OPOST)
        }

        //Special characters
        //We do this as c_cc is a C-fixed array which is imported as a tuple in Swift.
        //To avoid hardcoding the VMIN or VTIME value to access the tuple value, we use the typealias instead
    #if os(Linux)
        typealias specialCharactersTuple = (VINTR: cc_t, VQUIT: cc_t, VERASE: cc_t, VKILL: cc_t, VEOF: cc_t, VTIME: cc_t, VMIN: cc_t, VSWTC: cc_t, VSTART: cc_t, VSTOP: cc_t, VSUSP: cc_t, VEOL: cc_t, VREPRINT: cc_t, VDISCARD: cc_t, VWERASE: cc_t, VLNEXT: cc_t, VEOL2: cc_t, spare1: cc_t, spare2: cc_t, spare3: cc_t, spare4: cc_t, spare5: cc_t, spare6: cc_t, spare7: cc_t, spare8: cc_t, spare9: cc_t, spare10: cc_t, spare11: cc_t, spare12: cc_t, spare13: cc_t, spare14: cc_t, spare15: cc_t)
        var specialCharacters: specialCharactersTuple = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0) // NCCS = 32
    #elseif os(OSX)
        typealias specialCharactersTuple = (VEOF: cc_t, VEOL: cc_t, VEOL2: cc_t, VERASE: cc_t, VWERASE: cc_t, VKILL: cc_t, VREPRINT: cc_t, spare1: cc_t, VINTR: cc_t, VQUIT: cc_t, VSUSP: cc_t, VDSUSP: cc_t, VSTART: cc_t, VSTOP: cc_t, VLNEXT: cc_t, VDISCARD: cc_t, VMIN: cc_t, VTIME: cc_t, VSTATUS: cc_t, spare: cc_t)
        var specialCharacters: specialCharactersTuple = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0) // NCCS = 20
    #else
        #error("Unsupported platform")
    #endif
        specialCharacters.VMIN = cc_t(minimumBytesToRead)
        specialCharacters.VTIME = cc_t(timeout)
        settings.c_cc = specialCharacters

        // Commit settings
        tcsetattr(fileDescriptor!, TCSANOW, &settings)
    }

    /**
     Close the serial port.
     */
    public func close() {
        guard let fileDescriptor else {
            return
        }
        _ = closePort(fileDescriptor)
        self.fileDescriptor = nil
    }

    // MARK: Receiving

    /**
     Attempt to read a single byte.

     This function checks whether a single byte is available, and returns immediately.
     - Throws: `SerialError.portIsClosed`, `SerialError.deviceNotConnected`
     - Returns: The received byte, or `nil`, if no byte is available.
     */
    public func readByte() throws -> UInt8? {
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 1)
        defer { buffer.deallocate() }
        guard try readBytes(into: buffer, count: 1) == 0 else {
            return nil
        }
        return buffer[0]
    }

    /**
     Read received bytes up to a fixed length.

     This call returns immediatelly with the received data, up to `count` bytes.
     - Parameter count: The maximum number of bytes to return.
     - Throws: `SerialError.portIsClosed`, `SerialError.deviceNotConnected`
     - Returns: The received data, up to `count` bytes.
     - Note: The returned data is not necessarily of the requested length.
     If the call should wait for all bytes to arrive, use `readBytesBlocking(count:timeout:)` instead.
     */
    public func readBytes(count: Int) throws -> Data {
        var data = Data(capacity: count)
        let bytesRead = try data.withUnsafeMutableBytes { (ptr: UnsafeMutableRawBufferPointer) in
            try readBytes(into: ptr.baseAddress, count: count)
        }
        return data.prefix(bytesRead)
    }

    func readBytes(into buffer: UnsafeMutableRawPointer?, count: Int) throws -> Int {
        guard let fileDescriptor = fileDescriptor else {
            throw SerialError.portIsClosed
        }

        var s: stat = stat()
        fstat(fileDescriptor, &s)
        if s.st_nlink != 1 {
            throw SerialError.deviceNotConnected
        }

        let bytesRead = read(fileDescriptor, buffer, count)
        return max(0, bytesRead)
    }

    /**
     Read a fixed length of bytes.

     This call waits for the required number of bytes to arrive, or the timeout is exceeded.
     - Parameter count: The number of bytes to return.
     - Parameter timeout: The amount of time (in seconds) to wait for the requested number of bytes.
     - Throws: `SerialError.portIsClosed`, `SerialError.deviceNotConnected`
     - Returns: The received data of up to `count` bytes. If the timeout is reached, fewer bytes are returned.
     - Note: The returned data is not necessarily of the requested length.
     If the timeout is reached, then all bytes received up to this point are returned.
     - Note: If the call should not wait for all bytes to arrive, use `readBytes(count:)` instead.
     */
    public func readBytesBlocking(count: Int, timeout: TimeInterval) throws -> Data {
        var data = Data(count: count)
        var receivedByteCount = 0
        let start = Date()
        while receivedByteCount < count, -start.timeIntervalSinceNow < timeout {
            receivedByteCount += try data.withUnsafeMutableBytes { (ptr: UnsafeMutableRawBufferPointer) in
                try readBytes(into: ptr.baseAddress?.advanced(by: receivedByteCount), count: count - receivedByteCount)
            }
        }
        return data
    }

    // MARK: Transmitting

    /**
     Write a number of bytes to the serial port for transmission.
     - Parameter data: The data to write.
     - Throws: `SerialError.portIsClosed`
     - Returns: The number of bytes written.
     */
    public func writeBytes(_ data: Data) throws -> Int {
        guard let fileDescriptor = fileDescriptor else {
            throw SerialError.portIsClosed
        }
        return data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
            write(fileDescriptor, ptr.baseAddress, data.count)
        }
    }

    /**
     Write a number of bytes to the serial port for transmission.
     - Parameter bytes: The bytes to write.
     - Throws: `SerialError.portIsClosed`
     - Returns: The number of bytes written.
     */
    public func writeBytes(_ bytes: [UInt8]) throws -> Int {
        guard let fileDescriptor = fileDescriptor else {
            throw SerialError.portIsClosed
        }
        return bytes.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
            write(fileDescriptor, ptr.baseAddress, bytes.count)
        }
    }


    #if os(OSX)
    /**
     List all available serial ports.
     - Returns: A String array containing the paths to all available serial ports.
     */
    public static func listAvailablePorts() throws -> [String] {
        let task = Process()
        task.launchPath = "/bin/zsh"
        task.arguments = ["-c", "for port in /dev/tty.*; do echo \"$port\"; done"]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = Pipe()

        try task.run()
        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: data, encoding: .utf8) else {
            return []
        }

        let ports = output
            .split(separator: "\n")
            .map { String($0) }
            .filter { !$0.isEmpty }

        return ports
    }
    #endif
}

private func openPort(path: String, readWriteParam: Int32) -> Int32 {
#if os(Linux)
    return open(path, readWriteParam | O_NOCTTY)
#elseif os(OSX)
    return open(path, readWriteParam | O_NOCTTY | O_EXLOCK)
#endif
}

private func closePort(_ fileDescriptor: Int32) -> Int32 {
    close(fileDescriptor)
}
