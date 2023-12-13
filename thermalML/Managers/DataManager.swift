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
        imageName: [String],
        imagePath: String,
        description: String,
        tags: [String],
        temperatureLow: Float,
        temperatureHigh: Float,
        temperatureOutside: Float,
        temperatureUnit: String,
        emission: Float,
        comment: String,
        location: CLLocation,
        predictionResults: [NSManagedObject]
    ) {
        let newImageInfo = PhotoInfo(context: context)
        newImageInfo.imageName = imageName as NSObject
        newImageInfo.imagePath = imagePath
        newImageInfo.decriptionText = description
        newImageInfo.tags = tags as NSObject
        newImageInfo.temperatureLow = temperatureLow
        newImageInfo.temperatureHigh = temperatureHigh
        newImageInfo.temperatureOutside = temperatureOutside
        newImageInfo.temperatureUnit = temperatureUnit
        newImageInfo.emission = emission
        newImageInfo.comment = comment
        newImageInfo.location = location
        newImageInfo.addToPredictionResults(NSSet(array: predictionResults))
        
        do {
            try context.save()
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
            return try context.fetch(request)
        } catch {
            print("Ошибка при выполнении запроса: \(error)")
            return []
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
