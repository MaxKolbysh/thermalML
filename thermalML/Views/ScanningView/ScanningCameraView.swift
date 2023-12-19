//
//  ScanningCameraView.swift
//  thermalML
//
//  Created by Ildar Khabibullin on 26.11.2023.
//

import SwiftUI

struct ScanningCameraView: View {
    @Binding var thermalImage: UIImage?
    
    var body: some View {
        if let thermalImage = thermalImage {
            Image(uiImage: thermalImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
    }
}
