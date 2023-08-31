import Foundation

extension UserDefaults {

    enum Key: String {
        case merchantProfileData = "paypal.messages.merchantProfileHash"
    }

    // holds the data for a merchant profile, of type PayPalMessageMerchantData
    static var merchantProfileData: Data? {
        get {
            standard.data(forKey: Key.merchantProfileData.rawValue)
        }
        set {
            standard.set(newValue, forKey: Key.merchantProfileData.rawValue)
        }
    }
}
