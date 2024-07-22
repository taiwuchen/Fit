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

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage? //@Binding property wrapper allows the parent view(ImagePicker) to pass a reference to its state, so the ImagePicker can update it when an image is selected.
    @Environment(\.presentationMode) var presentationMode
    var sourceType: UIImagePickerController.SourceType

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct WardrobeView: View {
    @State private var clothingItems: [ClothingItem] = []
    @State private var isActionSheetPresented = false
    @State private var isImagePickerPresented = false
    @State private var selectedImage: UIImage?
    @State private var sourceType: UIImagePickerController.SourceType = .camera

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
                    AddClothingButton(action: {
                        isActionSheetPresented = true
                    })
                }
                .padding()
            }
            .navigationTitle("Wardrobe")
            .actionSheet(isPresented: $isActionSheetPresented) {
                ActionSheet(title: Text("Add Clothing Item"), message: Text("Choose a method to add a new item"), buttons: [
                    .default(Text("Take Photo")) {
                        self.sourceType = .camera
                        self.isImagePickerPresented = true
                    },
                    .default(Text("Choose from Library")) {
                        self.sourceType = .photoLibrary
                        self.isImagePickerPresented = true
                    },
                    .cancel()
                ])
            }
            .sheet(isPresented: $isImagePickerPresented, onDismiss: {
                if let image = selectedImage {
                    addNewClothingItem(image: image)
                }
            }) {
                ImagePicker(image: $selectedImage, sourceType: sourceType)
            }
        }
    }

    func addNewClothingItem(image: UIImage) {
        let newItem = ClothingItem(image: Image(uiImage: image), category: "New Item")
        clothingItems.append(newItem)
        selectedImage = nil
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
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
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
