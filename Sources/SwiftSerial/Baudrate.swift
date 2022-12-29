import Foundation

/**
 The possible baud rate settings for a serial connection
 */
public enum BaudRate {

    /** Baud 0 */
    case baud0

    /** Baud 50 */
    case baud50

    /** Baud 75 */
    case baud75

    /** Baud 0 */
    case baud110

    /** Baud 134 */
    case baud134

    /** Baud 150 */
    case baud150

    /** Baud 200 */
    case baud200

    /** Baud 300 */
    case baud300

    /** Baud 600 */
    case baud600

    /** Baud 1200 */
    case baud1200

    /** Baud 1800 */
    case baud1800

    /** Baud 2400 */
    case baud2400

    /** Baud 4800 */
    case baud4800

    /** Baud 9600 */
    case baud9600

    /** Baud 19200 */
    case baud19200

    /** Baud 38400 */
    case baud38400

    /** Baud 57600 */
    case baud57600

    /** Baud 115200 */
    case baud115200

    /** Baud 230400 */
    case baud230400
#if os(Linux)

    /** Baud 460800 (only available on Linux) */
    case baud460800

    /** Baud 500000 (only available on Linux) */
    case baud500000

    /** Baud 576000 (only available on Linux) */
    case baud576000

    /** Baud 921600 (only available on Linux) */
    case baud921600

    /** Baud 1000000 (only available on Linux) */
    case baud1000000

    /** Baud 1152000 (only available on Linux) */
    case baud1152000

    /** Baud 1500000 (only available on Linux) */
    case baud1500000

    /** Baud 2000000 (only available on Linux) */
    case baud2000000

    /** Baud 2500000 (only available on Linux) */
    case baud2500000

    /** Baud 3500000 (only available on Linux) */
    case baud3500000

    /** Baud 4000000 (only available on Linux) */
    case baud4000000
#endif

    var speedValue: speed_t {
        switch self {
        case .baud0:
            return speed_t(B0)
        case .baud50:
            return speed_t(B50)
        case .baud75:
            return speed_t(B75)
        case .baud110:
            return speed_t(B110)
        case .baud134:
            return speed_t(B134)
        case .baud150:
            return speed_t(B150)
        case .baud200:
            return speed_t(B200)
        case .baud300:
            return speed_t(B300)
        case .baud600:
            return speed_t(B600)
        case .baud1200:
            return speed_t(B1200)
        case .baud1800:
            return speed_t(B1800)
        case .baud2400:
            return speed_t(B2400)
        case .baud4800:
            return speed_t(B4800)
        case .baud9600:
            return speed_t(B9600)
        case .baud19200:
            return speed_t(B19200)
        case .baud38400:
            return speed_t(B38400)
        case .baud57600:
            return speed_t(B57600)
        case .baud115200:
            return speed_t(B115200)
        case .baud230400:
            return speed_t(B230400)
#if os(Linux)
        case .baud460800:
            return speed_t(B460800)
        case .baud500000:
            return speed_t(B500000)
        case .baud576000:
            return speed_t(B576000)
        case .baud921600:
            return speed_t(B921600)
        case .baud1000000:
            return speed_t(B1000000)
        case .baud1152000:
            return speed_t(B1152000)
        case .baud1500000:
            return speed_t(B1500000)
        case .baud2000000:
            return speed_t(B2000000)
        case .baud2500000:
            return speed_t(B2500000)
        case .baud3500000:
            return speed_t(B3500000)
        case .baud4000000:
            return speed_t(B4000000)
#endif
        }
    }
}
