//
//  NavViewBuilder.swift
//  thermalML
//
//  Created by Ildar Khabibullin on 26.11.2023.
//

import SwiftUI
import CoreData

final class NavViewBuilder {
    unowned let router: Router<AppRoute>
    let managedObjectContext: NSManagedObjectContext
    
    init(router: Router<AppRoute>, managedObjectContext: NSManagedObjectContext) {
        self.router = router
        self.managedObjectContext = managedObjectContext
    }
}
