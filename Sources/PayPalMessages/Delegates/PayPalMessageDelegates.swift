/// State Delegate
public protocol PayPalMessageViewStateDelegate: AnyObject {
    /// Function invoked when the message first starts to fetch data
    func onLoading(_ paypalMessageView: PayPalMessageView)
    /// Function invoked when the message has rendered
    func onSuccess(_ paypalMessageView: PayPalMessageView)
    /// Function invoked when the message encounters an error
    func onError(_ paypalMessageView: PayPalMessageView, error: PayPalMessageError)
}

/// Event Delegate
public protocol PayPalMessageViewEventDelegate: AnyObject {
    /// Function invoked when the message is tapped
    func onClick(_ paypalMessageView: PayPalMessageView)
    /// Function invoked when a user has begun the PayPal Credit application
    func onApply(_ paypalMessageView: PayPalMessageView)
}
