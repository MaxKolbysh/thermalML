//
//  BottomSheetPredictionInfoView.swift
//  thermalML
//
//  Created by Ildar Khabibullin on 16.12.2023.
//

import SwiftUI

struct BottomSheetPredictionInfoView: View {
    @Binding var isPredictionShow: Bool
    @Binding var detail: String
    @Binding var recommendation: String
    
    init(
        isPredictionShow: Binding<Bool>,
        detail: Binding<String>,
        recommendation: Binding<String>
    ) {
        _isPredictionShow = isPredictionShow
        _detail = detail
        _recommendation = recommendation
    }
    
    var body: some View {
        VStack {
            Text(detail)
                .padding()
                .font(.body)
            Text(recommendation)
                .padding()
                .font(.body)
        }
    }
}
