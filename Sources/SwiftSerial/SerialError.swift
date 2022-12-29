import Foundation

/**
 Possible errors occuring during serial operations.
 */
public enum SerialError: Int32, Error {

    /**
     The serial port could not be opened.

     This error occurs when the `open()` system function produces the error value `-1`
     */
    case failedToOpen = -1

    /**
     The serial port settings did not include a baud rate for sending or transmitting.

     At least one baud rate must be set for the port to be opened.
     */
    case mustReceiveOrTransmit

    /**
     The port is not open.

     This can happen if either `open()` is not called, or if it failed with an error.
     */
    case portIsClosed

    /**
     The device is not connected.
     */
    case deviceNotConnected
}
