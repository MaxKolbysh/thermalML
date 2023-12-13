//
//  PersistenceController.swift
//  thermalML
//
//  Created by Ildar Khabibullin on 14.12.2023.
//

import CoreData

class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "Photos")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Не удалось загрузить хранилища: \(error), \(error.userInfo)")
            }
        }
    }
}
