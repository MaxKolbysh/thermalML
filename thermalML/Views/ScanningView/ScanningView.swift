//
//  ScanningView.swift
//  thermalML
//
//  Created by Ildar Khabibullin on 26.11.2023.
//


import SwiftUI
import CoreML
import PhotosUI
    
struct ScanningView: View {
    @StateObject private var viewModel: ScanningViewModel
    
    @State private var alertMessage = ""
    @State private var isAlertPresented = false

    @State private var classificationLabel: String = .init()
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    
    @State private var isCameraConnected: Bool? = false
    private var isEmulatorLoading: Bool
    private var isClassifyButtonDisable = true
    
    init(router: Router<AppRoute>, isEmulatorLoading: Bool) {
        _viewModel = StateObject(wrappedValue: ScanningViewModel(router: router))
        self.isEmulatorLoading = isEmulatorLoading
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .background(Color.clear)
            ScanningCameraView(thermalImage: $viewModel.thermalImage)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            
            if viewModel.isActivityIndicatorShowed {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(3, anchor: .center)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            }
            
            Button(action: {
                if let image = viewModel.thermalImage {
                    viewModel.saveImageToFile(image: image, fileName: "thermalImage.jpg")
                }
            }, label: {
                HStack {
                    Image(systemName: "camera")
                        .foregroundStyle(.black)
                }
                .frame(maxWidth: 50, maxHeight: 50)
                .background(Color(red: 0, green: 122/255, blue: 255/255, opacity: 1.0))
                .clipShape(Circle())
                .foregroundColor(.black)
            })
            .padding(.bottom, 100)
            
            HStack {
                Spacer()
                Button(action: {
                        //
                }, label: {
                    HStack {
                        Image(systemName: "rectangle.and.text.magnifyingglass")
                            .padding(.leading)
                            .foregroundStyle(.black)
                        Text("Classify")
                            .foregroundColor(.black)
                            .padding(.trailing)
                    }
                    .frame(maxWidth: 125, maxHeight: 50)
                    .background(Color(red: 118/255, green: 118/255, blue: 128/255, opacity: 0.24))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .foregroundColor(.black)
                })
                .disabled(isClassifyButtonDisable)
                
            }
            .padding(.horizontal)
            .padding(.bottom, 100)

        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            if isEmulatorLoading {
                print("Emulator clicked")
                print("isConnecting... \(viewModel.isActivityIndicatorShowed)")
//                viewModel.isActivityIndicatorShowed = true
                viewModel.connectEmulatorClicked()
                viewModel.isConnected()
                print("isCameraConnected: \($isCameraConnected)")
            } else {
                print("Camera clicked")
                viewModel.isActivityIndicatorShowed = true
                viewModel.connectDeviceClicked()
//                viewModel.onCameraConnected()
            }
        }
        .navigationBarItems(
            trailing:
                Button(
                    action: {
                        print("Gallery Button Tapped")
                        viewModel.disconnectClicked()
                    }) {
                    Image(systemName: "photo")
                }
        )
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text("Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    isAlertPresented = false
                    viewModel.router.pop()
                }
            )
        }
    }
}

//#Preview {
//    ScanningView(router: Router())
//}
