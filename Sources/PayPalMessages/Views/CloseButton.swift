import UIKit

class CloseButton: UIButton {

    enum Constants {
        static let fadeDuration: TimeInterval = 0.1
        static let trailingPadding: CGFloat = 16
        static let fadeOutAlpha: CGFloat = 0.3
        static let padding: CGFloat = 10
        static let contenInset = UIEdgeInsets(
            top: padding,
            left: padding,
            bottom: padding,
            right: padding
        )
        static let buttonSize = CGSize(width: 44, height: 44)
    }

    typealias OnTap = () -> Void
    var onTap: OnTap?

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(
                withDuration: Constants.fadeDuration,
                delay: 0,
                options: isHighlighted ? .curveEaseOut : .curveEaseIn
            ) {
                self.alpha = self.isHighlighted ? Constants.fadeOutAlpha : 1
            }
        }
    }

    override var intrinsicContentSize: CGSize {
        let totalFromEdgeInset = Constants.contenInset.top + Constants.contenInset.bottom
        return CGSize(
            width: Constants.buttonSize.width + totalFromEdgeInset,
            height: Constants.buttonSize.height + totalFromEdgeInset
        )
    }

    required init() {
        super.init(frame: .zero)
        configure()
        registerListeners()
    }

    required init(onTap: OnTap?) {
        self.onTap = onTap
        super.init(frame: .zero)
        configure()
        registerListeners()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        setImage(ImageAsset.image(.closeIcon).withRenderingMode(.alwaysTemplate), for: .normal)
        // TODO: Handle localization (localizable strings?)
        accessibilityLabel = "Cancel"
        imageView?.contentMode = .scaleAspectFit
    }

    private func registerListeners() {
        addTarget(self, action: #selector(tappedCloseButton(_:)), for: .touchUpInside)
    }

    @objc func tappedCloseButton(_ sender: CloseButton) {
        onTap?()
    }
}
