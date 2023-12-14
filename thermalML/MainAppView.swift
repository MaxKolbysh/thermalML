//
//  MainAppView.swift
//  thermalML
//
//  Created by Ildar Khabibullin on 26.11.2023.
//

import SwiftUI

struct MainAppView: View {
    @Environment(\.managedObjectContext) private var managedObjectContext
    @StateObject var router: Router<AppRoute>
    let navViewBuilder: NavViewBuilder

    var body: some View {
        NavigationStack(path: $router.paths) {
            navViewBuilder.createWelcomeView()
                .navigationDestination(for: AppRoute.self, destination: buildViews)
        }
    }

    @ViewBuilder
    private func buildViews(view: AppRoute) -> some View {
        switch view {
        case .welcome: navViewBuilder.createWelcomeView()
        case .startConnection: navViewBuilder.createStartConnectionView()
        case .scanning(let isEmulatorLoading): navViewBuilder.createScanningView(isEmulatorLoading: isEmulatorLoading)
        }
    }
}
