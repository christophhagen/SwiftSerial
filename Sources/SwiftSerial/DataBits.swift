import Foundation

/** The number of data bits */
public enum DataBits: UInt {

    /** 5 data bits */
    case five = 5

    /** 6 data bits */
    case six = 6

    /** 7 data bits */
    case seven = 7

    /** 8 data bits */
    case eight = 8

    var flagValue: tcflag_t {
        switch self {
        case .five:
            return tcflag_t(CS5)
        case .six:
            return tcflag_t(CS6)
        case .seven:
            return tcflag_t(CS7)
        case .eight:
            return tcflag_t(CS8)
        }
    }
}
