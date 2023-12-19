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
    unowned let router: Router<AppRoute>

    @Published var centerSpotText: String = ""
    @Published var distanceText: String = ""
    @Published var distanceValue: Float = 0.0
    @Published var thermalImage: UIImage?
    @Published var isEmulatorLoading: Bool?

    @Published var errorMessage: String?
    @Published var showAlert = false
    @Published var isActivityIndicatorShowed: Bool = false

    let fileManager = PhotoFileManager.shared

    var cameraManager = FLIRCameraManager.shared
    @Published var isCameraConnected: Bool?

    private var managedObjectContext: NSManagedObjectContext
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
        
        cameraManager.$isCameraConnected
            .sink { [weak self] isCameraConnected in
                DispatchQueue.main.async {
                    self?.isActivityIndicatorShowed = !(isCameraConnected ?? false)
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
        cancellables.forEach { $0.cancel() }
    }
    
    func connectDeviceClicked() {
        isActivityIndicatorShowed = true
        cameraManager.connectDeviceClicked()
    }
    
    func disconnectClicked() {
        isActivityIndicatorShowed = false
        cameraManager.disconnectClicked()
    }

    func connectEmulatorClicked() {
        isActivityIndicatorShowed = true
        cameraManager.connectEmulatorClicked()
    }
    
    func ironPaletteClicked() {
        cameraManager.ironPaletteClicked()
    }
    
    func streamStart() {
        do {
            try cameraManager.stream?.start()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func streamStop() {
        do {
            try cameraManager.stream?.stop()
        } catch {
            print(error.localizedDescription)
        }

    }
    
    func savePhotos(thermalImage: UIImage, originalImage: UIImage) async {
        guard let thermalImageData = thermalImage.jpegData(compressionQuality: 1),
              let originalImageData = originalImage.jpegData(compressionQuality: 1) else {
            return
        }

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
