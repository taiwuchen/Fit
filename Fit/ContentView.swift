import SwiftUI
import UIKit


struct ContentView: View {
    var body: some View {
        TabView {
            WardrobeView()
                .tabItem {
                    Label("Wardrobe", systemImage: "tshirt")
                }
            
            OutfitsView()
                .tabItem {
                    Label("Outfits", systemImage: "person.crop.square")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
