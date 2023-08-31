import SwiftUI

struct ContentView: View {

    var body: some View {
        TabView {
            SwiftUIContentView()
                .tabItem {
                    Text("SwiftUI")
                }
            UIKitContentView()
                .tabItem {
                    Text("UIKit")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {

    static var previews: some View {
        ContentView()
    }
}
