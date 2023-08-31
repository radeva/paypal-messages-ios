/// Logo type option for a PayPal Message
public enum PayPalMessageLogoType: String, CaseIterable {
    /// PayPal logo positioned inline within the message
    case inline
    /// Primary logo including both the PayPal monogram and logo
    case primary
    /// Alternative logo including just the PayPal monogram
    case alternative
    /// "PayPal" as bold text inline with the message
    case none
}
