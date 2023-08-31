import SwiftUI

struct ReusableToggle: View {

    @Binding var isOn: Bool
    var label: String = ""

    var body: some View {
        Toggle(label, isOn: $isOn)
            .toggleStyle(SwitchToggleStyle(tint: .green))
            .frame(width: 50)
    }
}
