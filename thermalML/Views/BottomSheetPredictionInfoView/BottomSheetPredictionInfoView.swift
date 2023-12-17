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
    @Binding var resizedImageForUI: UIImage?
    
    init(
        isPredictionShow: Binding<Bool>,
        detail: Binding<String>,
        recommendation: Binding<String>,
        resizedImageForUI: Binding<UIImage?>
    ) {
        _isPredictionShow = isPredictionShow
        _detail = detail
        _recommendation = recommendation
        _resizedImageForUI = resizedImageForUI
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Classification results")
                    .font(.system(size: 19, weight: .bold))
                Spacer()
                Button(action: {
                    isPredictionShow.toggle()
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .padding(.leading)
                        .foregroundStyle(.gray)
                        .frame(maxWidth: 30, maxHeight: 30)
                })
            }
            .padding(.top, 20)
            .padding(.horizontal)
            HStack {
                VStack {
                    if let image = resizedImageForUI {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .padding(.horizontal)
                    }
                    Spacer()
                }
                VStack(alignment: .leading) {
                    Text("Prediction results:")
                        .font(.headline)
                    Text(detail)
                        .padding()
                        .font(.system(size: 15, weight: .regular))
                    Text("Recommendations:")
                        .font(.headline)
                    Text(recommendation)
                        .padding()
                        .font(.system(size: 15, weight: .regular))
                    Spacer()
                }
            }
        }
    }
}
