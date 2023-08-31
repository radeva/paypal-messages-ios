import SwiftUI

struct UIKitContentView: View {

    var body: some View {
        UIKitDemoViewControllerWrapper()
    }
}

struct UIKitDemoView_Previews: PreviewProvider {

    static var previews: some View {
        UIKitContentView()
    }
}

struct UIKitDemoViewControllerWrapper: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> UIViewController {
        UIKitContentViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}
