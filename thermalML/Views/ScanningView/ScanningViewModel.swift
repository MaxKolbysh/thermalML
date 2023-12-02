//
//  ScanningViewModel.swift
//  thermalML
//
//  Created by Ildar Khabibullin on 26.11.2023.
//

import SwiftUI
import Combine

class ScanningViewModel: ObservableObject {
    unowned let router: Router<AppRoute>
    var cameraManager = FLIRCameraManager()

    @Published var centerSpotText: String = ""
    @Published var distanceText: String = ""
    @Published var distanceValue: Float = 0.0
    @Published var thermalImage: UIImage?
    @Published var isCameraConnected: Bool?
    @Published var isEmulatorLoading: Bool?

    @Published var errorMessage: String?
    @Published var showAlert = false
    
    @Published var isConnecting: Bool = false
    
    private var cancellables = Set<AnyCancellable>()

    var error: Error? {
        didSet {
            if let error = error {
                errorMessage = error.localizedDescription
                showAlert = true
            }
        }
    }
    
    init(router: Router<AppRoute>) {
        self.router = router
        
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
            .sink { [weak self] value in
                self?.isCameraConnected = value
            }
            .store(in: &cancellables)
        cameraManager.$error
                .compactMap { $0 }
                .sink { [weak self] error in
                    self?.errorMessage = error.localizedDescription
                    self?.showAlert = true
                }
                .store(in: &cancellables)
        
        onCameraConnected()
    }
    
    deinit {
        cameraManager.disconnectClicked()
        cancellables.forEach { $0.cancel() }
    }
    
    func connectDeviceClicked() {
        isConnecting = true
        cameraManager.connectDeviceClicked()
    }
    
    func disconnectClicked() {
        cameraManager.disconnectClicked()
        isConnecting = false
    }
    
    func connectEmulatorClicked() {
        print("connectEmulatorClicked")
        cameraManager.connectEmulatorClicked()
    }
    
    func onCameraConnected() {
        print("onCameraConnected")
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.isConnecting = false
        }
    }
    
    func isConnected() {
        cameraManager.isConnected()
    }
    
    func ironPaletteClicked() {
        cameraManager.ironPaletteClicked()
    }
    
    func saveImageToFile(image: UIImage, fileName: String) {
        // Получение данных изображения в формате JPEG
        guard let imageData = image.jpegData(compressionQuality: 1) else {
            print("Не удалось получить данные изображения")
            return
        }

        // Получение пути к директории Documents
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Не удалось найти директорию Documents")
            return
        }

        // Определение пути к файлу
        let fileURL = documentsDirectory.appendingPathComponent(fileName)

        do {
            // Запись данных в файл
            try imageData.write(to: fileURL)
            print("Изображение сохранено в \(fileURL)")
        } catch {
            print("Ошибка при сохранении изображения: \(error)")
        }
    }
}
