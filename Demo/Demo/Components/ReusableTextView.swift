import SwiftUI

struct ReusableTextView: View {

    var text: String
    var font: Font
    var weight: Font.Weight
    var foregroundColor: Color?
    var padding: EdgeInsets?

    var body: some View {
        Text(self.text)
            .font(self.font)
            .fontWeight(self.weight)
            .padding(padding ?? .init(top: 5, leading: 0, bottom: 5, trailing: 10))
            .foregroundColor(foregroundColor)
    }
}
