//
//  PhotoGalleryViewModel.swift
//  thermalML
//
//  Created by Ildar Khabibullin on 14.12.2023.
//

import SwiftUI
import Combine
import CoreData

class PhotoGalleryViewModel: ObservableObject {
    @Published var photos: [PhotoInfo] = []
    
    unowned let router: Router<AppRoute>

    let fileManager = PhotoFileManager.shared

    private var dataManager: DataManager
    private var managedObjectContext: NSManagedObjectContext

    init(
        router: Router<AppRoute>,
        managedObjectContext: NSManagedObjectContext
    ) {
        self.router = router
        self.managedObjectContext = managedObjectContext
        self.dataManager = DataManager(context: managedObjectContext)
        Task {
            await loadPhotosInfoFromDB()
        }
    }
    
    // MARK: - Get photo info from DB
    func loadPhotosInfoFromDB() async {
        let loadedPhotos = dataManager.getAllImages()
        
        DispatchQueue.main.async {
            self.photos = loadedPhotos
        }
        
        for photo in photos {
            if let imagePathArray = photo.imageNameAndPath as? [String] {
                for imagePath in imagePathArray {
                    if let photoData = await fileManager.fetchPhoto(withPath: imagePath),
                       let image = UIImage(data: photoData) {
                    } else {
                        print("Ошибка загрузки фотографии по пути: \(imagePath)")
                    }
                }
            }
        }
    }
    
    func loadPhotoFromDisk(from path: String) async -> UIImage? {
        if let photoData = await fileManager.fetchPhoto(withPath: path),
           let image = UIImage(data: photoData) {
            return image
        } else {
            print("Не удалось загрузить изображение по пути: \(path)")
            return nil
        }
    }
    func gotoImageView(imagePath: String, photoInfo: PhotoInfo) async {
        if let image = await loadPhotoFromDisk(from: imagePath) {
            router.push(.imagePrediction(
                currentImage: image,
                photoInfo: photoInfo,
                photoFileManager: fileManager,
                dataManager: dataManager
            ))
        } else {
            print("Не удалось загрузить изображение по пути: \(imagePath)")
        }
    }
}
