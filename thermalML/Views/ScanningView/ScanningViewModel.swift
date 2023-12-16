//
//  ScanningViewModel.swift
//  thermalML
//
//  Created by Ildar Khabibullin on 26.11.2023.
//

import SwiftUI
import Combine
import CoreData

class ScanningViewModel: ObservableObject {
    private var managedObjectContext: NSManagedObjectContext

    unowned let router: Router<AppRoute>
    var cameraManager = FLIRCameraManager()
    let fileManager = PhotoFileManager.shared

    @Published var centerSpotText: String = ""
    @Published var distanceText: String = ""
    @Published var distanceValue: Float = 0.0
    @Published var thermalImage: UIImage?
    @Published var isCameraConnected: Bool?
    @Published var isEmulatorLoading: Bool?

    @Published var errorMessage: String?
    @Published var showAlert = false
    
    @Published var isActivityIndicatorShowed: Bool = false

    private var cancellables = Set<AnyCancellable>()

    var error: Error? {
        didSet {
            if let error = error {
                errorMessage = error.localizedDescription
                showAlert = true
            }
        }
    }
    
    init(router: Router<AppRoute>, managedObjectContext: NSManagedObjectContext) {
        self.router = router
        self.managedObjectContext = managedObjectContext

        cameraManager.$centerSpotText
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.centerSpotText = value
            }
            .store(in: &cancellables)

        cameraManager.$distanceText
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.distanceText = value
            }
            .store(in: &cancellables)
        
        cameraManager.$distanceValue
            .compactMap { $0 }
            .sink { [weak self] value in
                self?.distanceValue = value
            }
            .store(in: &cancellables)
        
        cameraManager.$thermalImage
            .sink { [weak self] value in
                self?.thermalImage = value
            }
            .store(in: &cancellables)
        
        cameraManager.$isCameraConnected
            .compactMap { $0 }
            .sink { [weak self] isConnected in
                self?.isActivityIndicatorShowed = !isConnected
                print("isActivityIndicatorShowed ===== \(self?.isActivityIndicatorShowed)")
            }
            .store(in: &cancellables)
        
        cameraManager.$error
                .compactMap { $0 }
                .sink { [weak self] error in
                    self?.errorMessage = error.localizedDescription
                    self?.showAlert = true
                }
                .store(in: &cancellables)
    }
    
    deinit {
        cameraManager.disconnectClicked()
        cancellables.forEach { $0.cancel() }
    }
    
    func connectDeviceClicked() {
        isActivityIndicatorShowed = true
        cameraManager.connectDeviceClicked()
    }
    
    func disconnectClicked() {
        cameraManager.disconnectClicked()
        isActivityIndicatorShowed = false
    }
    
    func connectEmulatorClicked() {
        print("connectEmulatorClicked")
        cameraManager.connectEmulatorClicked()
    }
    
    func isConnected() {
        cameraManager.isConnected()
    }
    
    func ironPaletteClicked() {
        cameraManager.ironPaletteClicked()
    }
    
    func savePhotos(thermalImage: UIImage, originalImage: UIImage) {
        guard let thermalImageData = thermalImage.jpegData(compressionQuality: 1),
              let originalImageData = originalImage.jpegData(compressionQuality: 1) else {
            print("Не удалось получить данные изображений")
            return
        }

        let dataManager = DataManager(context: managedObjectContext)

        if let thermalPhotoInfo = fileManager.savePhoto(isOriginal: false, thermalImageData),
           let originalPhotoInfo = fileManager.savePhoto(isOriginal: true, originalImageData) {

            let fileAddtionalInfo = fileManager.fetchPhotoInfo(withPath: thermalPhotoInfo)
            if !fileAddtionalInfo.isEmpty {
                let imageNameAndPath = [thermalPhotoInfo, originalPhotoInfo]
                
                let imageName = fileAddtionalInfo["name"]
                let imageSize = fileAddtionalInfo["size"]
                let imageCreation = fileAddtionalInfo["creationDate"]
                
                dataManager.addImageInfo(
                    imageNameAndPath: imageNameAndPath,
                    imageThermalName: imageName,
                    fileSize: imageSize,
                    fileDateCreation: imageCreation
                )
            }
        }
    }
    
    func goToStartPhotoGalleryView() {
        router.push(.photoGallery)
    }
}
