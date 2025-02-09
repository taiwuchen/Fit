import SwiftUI
import UIKit
import PhotosUI  // Needed for PHPickerViewController

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
    @Binding var image: UIImage?  // For single image selection.
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

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct MultiImagePicker: UIViewControllerRepresentable {
    @Binding var images: [UIImage]  // For multiple image selection.
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 5 // 0 allows unlimited selection.
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        // No updates needed.
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: MultiImagePicker
        
        init(_ parent: MultiImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
                        if let image = object as? UIImage {
                            DispatchQueue.main.async {
                                self.parent.images.append(image)
                            }
                        }
                    }
                }
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct WardrobeView: View {
    @State private var clothingItems: [ClothingItem] = []
    @State private var isActionSheetPresented = false
    @State private var isImagePickerPresented = false
    @State private var isMultiImagePickerPresented = false
    @State private var selectedImage: UIImage?
    @State private var selectedImages: [UIImage] = []
    @State private var sourceType: UIImagePickerController.SourceType = .camera

    let columns = [
        GridItem(.adaptive(minimum: 100))
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(clothingItems) { item in
                        ZStack(alignment: .topTrailing) {
                            // Display the clothing item view.
                            ClothingItemView(item: item)
                            
                            // Delete button overlay.
                            Button(action: {
                                deleteItem(item)
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                                    .background(Color.white)
                                    .clipShape(Circle())
                            }
                            .padding(5)
                        }
                    }
                    
                    // Button to add a new clothing item.
                    AddClothingButton(action: {
                        isActionSheetPresented = true
                    })
                }
                .padding()
            }
            .navigationTitle("Wardrobe")
            .actionSheet(isPresented: $isActionSheetPresented) {
                ActionSheet(
                    title: Text("Add Clothing Item"),
                    message: Text("Choose a method to add a new item"),
                    buttons: [
                        .default(Text("Take Photo")) {
                            self.sourceType = .camera
                            self.isImagePickerPresented = true
                        },
                        .default(Text("Choose Photos")) {
                            self.isMultiImagePickerPresented = true
                        },
                        .cancel()
                    ]
                )
            }
            .sheet(isPresented: $isImagePickerPresented, onDismiss: {
                if let image = selectedImage {
                    addNewClothingItem(image: image)
                }
            }) {
                ImagePicker(image: $selectedImage, sourceType: sourceType)
            }
            .sheet(isPresented: $isMultiImagePickerPresented, onDismiss: {
                if !selectedImages.isEmpty {
                    addNewClothingItems(images: selectedImages)
                }
            }) {
                MultiImagePicker(images: $selectedImages)
            }
        }
    }

    /// Adds a new clothing item (single image) to the wardrobe.
    func addNewClothingItem(image: UIImage) {
        let newItem = ClothingItem(image: Image(uiImage: image), category: "New Item")
        clothingItems.append(newItem)
        selectedImage = nil
    }
    
    /// Adds multiple new clothing items to the wardrobe.
    func addNewClothingItems(images: [UIImage]) {
        for image in images {
            let newItem = ClothingItem(image: Image(uiImage: image), category: "New Item")
            clothingItems.append(newItem)
        }
        selectedImages.removeAll()
    }
    
    /// Deletes the specified clothing item from the wardrobe.
    func deleteItem(_ item: ClothingItem) {
        if let index = clothingItems.firstIndex(where: { $0.id == item.id }) {
            clothingItems.remove(at: index)
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
