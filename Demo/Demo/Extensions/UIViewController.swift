import UIKit

extension UIViewController {

    // MARK: - UI Helpers

    func getButton(title: String, action: Selector, tag: Int? = nil) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .preferredFont(forTextStyle: .body)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        button.tag = tag ?? 0
        return button
    }

    func getLabel(text: String, font: UIFont = .boldSystemFont(ofSize: 15)) -> UILabel {
        let label = UILabel()
        label.font = font
        label.text = text
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        return label
    }

    func getStackView(
        subviews: [UIView] = [],
        axis: NSLayoutConstraint.Axis = .vertical,
        alignment: UIStackView.Alignment = .fill,
        spacing: CGFloat = 16.0,
        distribution: UIStackView.Distribution = .fill,
        padding: CGFloat = 0.0
    ) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: subviews)
        stackView.axis = axis
        stackView.alignment = alignment
        stackView.spacing = spacing
        stackView.distribution = .fill
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layoutMargins = UIEdgeInsets(
            top: padding,
            left: padding,
            bottom: padding,
            right: padding
        )
        return stackView
    }

    func getSeparator() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return view
    }

    func getSegmentedControl<T: PayPalMessageEnumType>(
        action: Selector,
        forType type: T.Type
    ) -> UISegmentedControl {
        let items = T.allCases.map { $0.description }
        let segment = UISegmentedControl(items: items)
        segment.selectedSegmentIndex = UISegmentedControl.noSegment
        segment.addTarget(self, action: action, for: .valueChanged)
        return segment
    }

    func getTextField(
        action: Selector,
        keyboardType: UIKeyboardType,
        autoCapitalizationType: UITextAutocapitalizationType,
        text: String? = nil
    ) -> UITextField {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        textField.placeholder = nil
        textField.clearButtonMode = .always
        textField.tag = 0
        textField.addTarget(self, action: action, for: .editingChanged)
        textField.keyboardType = keyboardType
        textField.autocapitalizationType = autoCapitalizationType
        textField.autocorrectionType = .no
        textField.textAlignment = .right
        textField.widthAnchor.constraint(equalToConstant: 200).isActive = true
        textField.text = text

        if let textDelegate = self as? UITextFieldDelegate {
            textField.delegate = textDelegate
        }

        return textField
    }

    func getSwitch(isOn: Bool = false, action: Selector) -> UISwitch {
        let switchField = UISwitch(frame: .zero)
        switchField.addTarget(self, action: action, for: .valueChanged)
        switchField.isOn = isOn
        return switchField
    }
}
