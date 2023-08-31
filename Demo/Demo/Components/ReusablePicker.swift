import SwiftUI

struct ReusablePicker<T: Hashable>: View {

    var options: [T]
    @Binding var selectedOption: T

    var body: some View {
        Picker("", selection: $selectedOption) {
            ForEach(options, id: \.self) { option in
                Text(String(describing: option))
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
}
