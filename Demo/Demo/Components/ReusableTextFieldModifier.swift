import SwiftUI

struct ReusableTextFieldModifier: ViewModifier {

    var binding: Binding<String>?

    func body(content: Content) -> some View {
        content
            .frame(width: 200)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .disableAutocorrection(true)
            .truncationMode(.tail)
            .overlay(
                clearButtonOverlay(for: binding)
            )
    }

    private func clearButtonOverlay(for binding: Binding<String>?) -> some View {
        HStack {
            if let binding = binding, !binding.wrappedValue.isEmpty {
                Spacer()
                Button(
                    action: {
                        binding.wrappedValue = ""
                    },
                    label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                )
                .background(Color.white)
                .padding(.trailing, 1)
            }
        }
    }
}
