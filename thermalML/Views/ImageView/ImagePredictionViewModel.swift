//
//  ImageViewModel.swift
//  thermalML
//
//  Created by Ildar Khabibullin on 16.12.2023.
//

import Foundation
import SwiftUI
import CoreML

class ImagePredictionViewModel: ObservableObject {

    unowned let router: Router<AppRoute>
    private var photoFileManager: PhotoFileManager
    private var dataManager: DataManager

    var photoInfo: PhotoInfo?
    var currentImage: UIImage?

    @Published var detail: String = ""
    @Published var recommendation: String = ""
    
    private let mlModel: thermalclassification_1
    
    let renderQueue = DispatchQueue.init(label: "render")
    var classificationResults: [String: Double] = .init()
    
    init(
        router: Router<AppRoute>,
        photoFileManager: PhotoFileManager,
        dataManager: DataManager,
        photoInfo: PhotoInfo,
        currentImage: UIImage
    ) {
        self.router = router
        self.photoFileManager = photoFileManager
        self.dataManager = dataManager
        self.photoInfo = photoInfo
        self.currentImage = currentImage
        do {
            let configuration = MLModelConfiguration()
            configuration.computeUnits = .cpuOnly
            mlModel = try thermalclassification_1(configuration: configuration)
            print("Model loaded successfully")
        } catch {
            print("Error loading model: \(error)")
            fatalError("Unable to load the thermalclassification_1 model.")
        }
    }
    // MARK: - Delete photo info from DB
    func deletePhotoAndInfo() {
        if let photoInfo = photoInfo {
            if let imagePathArray = photoInfo.imageNameAndPath as? [String] {
                for imagePath in imagePathArray {
                    // Delete file
                    photoFileManager.deletePhoto(withPath: imagePath)
                }
            }
            // Delete data from DB
            dataManager.deleteImageInfo(withThermalName: photoInfo.imageThermalName ?? "")
        }
    }
    // MARK: - Classify image
    func classifyImage() {
        guard let image = currentImage,
              let resizedImage = image.resizeImageTo(size: CGSize(width: 299, height: 299)),
              let buffer = resizedImage.convertToBuffer() else {
            print("Failed to create pixel buffer from UIImage")
            return
        }
        print("Buffer: \(buffer)")
        
        do {
            let input = thermalclassification_1Input(image: buffer)
            let output = try mlModel.prediction(input: input)
            print("Classified image as: \(output.target)")
            print("Prediction probabilities: \(output.targetProbability)")
            classificationResults = output.targetProbability
            let results = output.targetProbability.sorted { $0.1 > $1.1 }
            detail = results.map { (key, value) in
                return "\(key) = \(String(format: "%.2f", value * 100))%"
            }.joined(separator: "\n")
        } catch {
            print("Error during classification: \(error)")
        }
    }
    
    // MARK: - Classification Results
    func processClassificationResults() {
        let sortedResults = classificationResults.sorted { $0.value > $1.value }
        
        guard let highestResult = sortedResults.first else {
            recommendation = "Unable to identify the object."
            return
        }
        
            // Form a recommendation based on the most probable result
        switch highestResult.key {
            case "hot object":
                recommendation = "Hot object detected. Insulation check recommended."
            case "hot object hotfloor":
                recommendation = "Signs of heat leakage on the floor and other objects detected."
            case "cold object hotfloor":
                recommendation = "Cold objects detected with heat leakage on the floor."
            case "cold floor":
                recommendation = "The floor is cold. Improved insulation may be needed."
            case "hotfloor":
                recommendation = "The floor is hot. Check the heating system or for heat leaks."
            case "cold object hot object hotfloor":
                recommendation = "A combination of cold and hot objects detected. Detailed analysis required."
            default:
                recommendation = "Object status is undefined."
        }
    }
}
