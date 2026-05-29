import SwiftUI
import Foundation

struct HomeScreen : View {
    var body: some View {
        NavigationView {
            ScrollView{
                    Text("hi")
                        .navigationTitle("Home")
                        .navigationBarItems(trailing: Text("Settings"))
                        .toolbarTitleDisplayMode(.inlineLarge)
            }
        }
    }
}

#Preview {
    HomeScreen()
}
