import UIKit

extension UIView {

    func rotateIndefinitely() {
        DispatchQueue.main.async { [weak self] in
            let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
            rotation.toValue = NSNumber(value: Double.pi * 2)
            rotation.duration = 1
            rotation.isCumulative = true
            rotation.repeatCount = .infinity
            rotation.isRemovedOnCompletion = false
            self?.layer.add(rotation, forKey: "rotation_animation")
        }
    }
}
