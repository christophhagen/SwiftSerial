import Foundation

/** The parity type  */
public enum Parity {

    /** No parity */
    case none

    /** Even parity */
    case even

    /** Odd parity */
    case odd

    var parityValue: tcflag_t {
        switch self {
        case .none:
            return 0
        case .even:
            return tcflag_t(PARENB)
        case .odd:
            return tcflag_t(PARENB | PARODD)
        }
    }
}
