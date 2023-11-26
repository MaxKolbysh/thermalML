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
    func createScanningView() -> Scanning
}

extension NavViewBuilder: MainFlow {
    func createWelcomeView() -> some View {
        WelcomeView(router: router)
    }
    func createStartConnectionView() -> some View {
        StartConnectionView(router: router)
    }
    func createScanningView() -> some View {
        ScanningView(router: router)
    }
}
