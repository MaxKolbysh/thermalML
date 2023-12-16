//
//  PhotoGalleryView.swift
//  thermalML
//
//  Created by Ildar Khabibullin on 14.12.2023.
//

import SwiftUI
import CoreData

struct PhotoGalleryView: View {
    @Environment(\.managedObjectContext) private var managedObjectContext
    @StateObject private var viewModel: PhotoGalleryViewModel
    @State var currentImage: UIImage?
    
    init(
        router: Router<AppRoute>,
        managedObjectContext: NSManagedObjectContext
    ) {
        _viewModel = StateObject(
            wrappedValue: PhotoGalleryViewModel(
                router: router,
                managedObjectContext: managedObjectContext
            )
        )
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.fixed(geometry.size.width / 3)),
                    GridItem(.fixed(geometry.size.width / 3)),
                    GridItem(.fixed(geometry.size.width / 3))
                ]) {
                    ForEach(viewModel.photos, id: \.self) { photo in
                        if let imagePathArray = photo.imageNameAndPath as? [String],
                           let firstImagePath = imagePathArray.first,
                           let image = loadImage(from: firstImagePath) {
                            Button {
                                viewModel.gotoImageView(currentImage: image)
                            } label: {
                                Image(uiImage: image)
                                    .resizable()
                                    .frame(width: geometry.size.width / 3, height: geometry.size.width / 3)
                            }
                            
                        }
                    }
                }
            }
            .navigationTitle(Text("Gallery"))
            .padding(.horizontal, 9)
        }
    }

    
    func loadImage(from path: String) -> UIImage? {
        print("Загрузка изображения по пути: \(path)")
        if let photoData = viewModel.fileManager.fetchPhoto(withPath: path),
           let image = UIImage(data: photoData) {
            return image
        } else {
            print("Не удалось загрузить изображение по пути: \(path)")
            return nil
        }
    }
}
