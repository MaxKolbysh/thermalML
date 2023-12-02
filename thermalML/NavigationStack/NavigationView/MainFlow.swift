//
//  MainFlow.swift
//  thermalML
//
//  Created by Ildar Khabibullin on 26.11.2023.
//

import SwiftUI

protocol MainFlow {
    associatedtype Welcome: View
    associatedtype StartConnection: View
    associatedtype Scanning: View
    
    func createWelcomeView() -> Welcome
    func createStartConnectionView() -> StartConnection
    func createScanningView(isEmulatorLoading: Bool) -> Scanning
}

extension NavViewBuilder: MainFlow {
    func createWelcomeView() -> some View {
        WelcomeView(router: router)
    }
    func createStartConnectionView() -> some View {
        StartConnectionView(router: router)
    }
    func createScanningView(isEmulatorLoading: Bool) -> some View {
        ScanningView(router: router, isEmulatorLoading: isEmulatorLoading)
    }
}
