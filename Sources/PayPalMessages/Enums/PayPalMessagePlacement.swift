/// Message location within an application
public enum PayPalMessagePlacement: String, CaseIterable {
    /// Home view
    case home
    /// Category view displaying multiple products
    case category
    /// Individual product view
    case product
    /// Shopping cart view
    case cart
    /// Checkout view
    case payment
}
