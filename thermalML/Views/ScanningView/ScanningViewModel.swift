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
    var cameraManager = FLIRCameraManager.shared
    let fileManager = PhotoFileManager.shared

    @Published var centerSpotText: String = ""
    @Published var distanceText: String = ""
    @Published var distanceValue: Float = 0.0
    @Published var thermalImage: UIImage?
    var isCameraConnected: Bool {
        UserDefaults.standard.bool(forKey: "isCameraConnected")
    }
    @Published var isEmulatorLoading: Bool?

    @Published var errorMessage: String?
    @Published var showAlert = false
    
    @Published var isActivityIndicatorShowed: Bool = false
    private var dataManager: DataManager
    private var lastImage: UIImage?
    private var lastImageName: String?
    
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
        self.dataManager = DataManager(context: managedObjectContext)

        cameraManager.$centerSpotText
            .compactMap { $0 }
            .sink { [weak self] value in
                DispatchQueue.main.async {
                    self?.centerSpotText = value
                }
            }
            .store(in: &cancellables)

        cameraManager.$distanceText
            .compactMap { $0 }
            .sink { [weak self] value in
                DispatchQueue.main.async {
                    self?.distanceText = value
                }
            }
            .store(in: &cancellables)
        
        cameraManager.$distanceValue
            .compactMap { $0 }
            .sink { [weak self] value in
                DispatchQueue.main.async {
                    self?.distanceValue = value
                }
            }
            .store(in: &cancellables)
        
        cameraManager.$thermalImage
            .sink { [weak self] value in
                self?.thermalImage = value
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
//        cameraManager.disconnectClicked()
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
    
//    func isConnected() {
//        cameraManager.isConnected()
//    }
    
    func ironPaletteClicked() {
        cameraManager.ironPaletteClicked()
    }
    
    func savePhotos(thermalImage: UIImage, originalImage: UIImage) async {
        guard let thermalImageData = thermalImage.jpegData(compressionQuality: 1),
              let originalImageData = originalImage.jpegData(compressionQuality: 1) else {
            print("Не удалось получить данные изображений")
            return
        }

//        let dataManager = DataManager(context: managedObjectContext)
        lastImage = thermalImage
        
        if let thermalPhotoInfo = await fileManager.savePhoto(isOriginal: false, thermalImageData),
           let originalPhotoInfo = await fileManager.savePhoto(isOriginal: true, originalImageData) {

            let fileAddtionalInfo = await fileManager.fetchPhotoInfo(withPath: thermalPhotoInfo)
            if !fileAddtionalInfo.isEmpty {
                let imageNameAndPath = [thermalPhotoInfo, originalPhotoInfo]
                
                let imageName = fileAddtionalInfo["name"]
                let imageSize = fileAddtionalInfo["size"]
                let imageCreation = fileAddtionalInfo["creationDate"]
                self.lastImageName = imageName
                self.dataManager.addImageInfo(
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
    
    func gotoImageView() {
        if let currentImage = lastImage,
            let photoInfo = fetchLastImagePhotoInfo(lastImageName: lastImageName ?? "") {
            router.push(.imagePrediction(
                currentImage: currentImage,
                photoInfo: photoInfo,
                photoFileManager: fileManager,
                dataManager: dataManager
            ))
        }
    }
    
    func fetchLastImagePhotoInfo(lastImageName: String) -> PhotoInfo? {
        dataManager.getImageInfoByThermalName(thermalName: lastImageName)
    }
}
