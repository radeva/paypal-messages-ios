import UIKit

extension UIViewController {

    static func getPresentingViewController() -> UIViewController? {
        if var rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = rootViewController.presentedViewController {
                rootViewController = presentedViewController
            }

            return rootViewController
        }
        return nil
    }
}
