import SwiftUI

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

struct WardrobeView: View {
    @State private var clothingItems: [ClothingItem] = []
    
    let columns = [
        GridItem(.adaptive(minimum: 100))
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(clothingItems) { item in
                        ClothingItemView(item: item)
                    }
                    AddClothingButton()
                }
                .padding()
            }
            .navigationTitle("Wardrobe")
        }
    }
}

struct ClothingItem: Identifiable {
    let id = UUID()
    let image: Image
    let category: String
}

struct ClothingItemView: View {
    let item: ClothingItem
    
    var body: some View {
        VStack {
            item.image
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
            Text(item.category)
                .font(.caption)
        }
    }
}

struct AddClothingButton: View {
    var body: some View {
        Button(action: {
            // Add logic to open camera and scan clothing
        }) {
            VStack {
                Image(systemName: "plus")
                    .font(.system(size: 40))
                Text("Add Item")
                    .font(.caption)
            }
            .frame(width: 80, height: 80)
            .foregroundColor(.blue)
        }
    }
}

struct OutfitsView: View {
    var body: some View {
        Text("Outfits View")
    }
}

struct SettingsView: View {
    var body: some View {
        Text("Settings View")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
