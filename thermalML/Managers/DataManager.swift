//
//  DataManager.swift
//  thermalML
//
//  Created by Ildar Khabibullin on 14.12.2023.
//

import CoreData
import CoreLocation

class DataManager {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addImageInfo(
        imageNameAndPath: [String],
        imageThermalName: String? = nil,
        fileSize: String? = nil,
        fileDateCreation: String? = nil,
        description: String? = nil,
        tags: [String]? = nil,
        temperatureLow: Float? = nil,
        temperatureHigh: Float? = nil,
        temperatureOutside: Float? = nil,
        temperatureUnit: String? = nil,
        emission: Float? = nil,
        comment: String? = nil,
        location: CLLocation? = nil,
        predictionResults: [NSManagedObject]? = nil
    ) {
        let newImageInfo = PhotoInfo(context: context)
        newImageInfo.imageNameAndPath = imageNameAndPath as NSObject
        // Optional data
        newImageInfo.imageThermalName = imageThermalName ?? ""
        newImageInfo.fileSize = fileSize ?? ""
        newImageInfo.fileDateCreation = fileDateCreation ?? ""
        newImageInfo.decriptionText = description
        newImageInfo.tags = tags as NSObject?
        newImageInfo.temperatureLow = temperatureLow ?? 0.0
        newImageInfo.temperatureHigh = temperatureHigh ?? 0.0
        newImageInfo.temperatureOutside = temperatureOutside ?? 0.0
        newImageInfo.temperatureUnit = temperatureUnit ?? "C"
        newImageInfo.emission = emission ?? 0.0
        newImageInfo.comment = comment ?? ""
        newImageInfo.location = location
        if let predictionResults = predictionResults {
            newImageInfo.addToPredictionResults(NSSet(array: predictionResults))
        }
        do {
            try context.save()
            print("Информация об изображении сохранена")
        } catch {
            print("Ошибка при сохранении: \(error)")
        }
    }
    
    func searchByComment(comment: String) -> [PhotoInfo] {
        let request: NSFetchRequest<PhotoInfo> = PhotoInfo.fetchRequest()
        request.predicate = NSPredicate(format: "comment CONTAINS[c] %@", comment)
        do {
            return try context.fetch(request)
        } catch {
            print("Ошибка при выполнении запроса: \(error)")
            return []
        }
    }
    
    func getAllImages() -> [PhotoInfo] {
        let request: NSFetchRequest<PhotoInfo> = PhotoInfo.fetchRequest()
        do {
            let results = try context.fetch(request)
            print("Получено изображений из Core Data: \(results.count)")
            return results
        } catch {
            print("Ошибка при выполнении запроса: \(error)")
            return []
        }
    }
    
    func deleteImageInfo(withPath path: String) {
        let request: NSFetchRequest<PhotoInfo> = PhotoInfo.fetchRequest()
        request.predicate = NSPredicate(format: "imageNameAndPath == %@", path)
        do {
            let results = try context.fetch(request)
            for object in results {
                context.delete(object)
            }
            try context.save()
        } catch {
            print("Ошибка при удалении информации об изображении: \(error)")
        }
    }
    
//    func filterByTags(tags: [String]) -> [PhotoInfo] {
//        //
//    }
//    
//    func filterByLocation(location: CLLocation, radius: Double) -> [PhotoInfo] {
//        //
//    }
}
