//
//  ScanningView.swift
//  thermalML
//
//  Created by Ildar Khabibullin on 26.11.2023.
//


import SwiftUI
import CoreML
import PhotosUI
import CoreData
    
struct ScanningView: View {
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    @StateObject private var viewModel: ScanningViewModel
    
    @State private var errorMessage = ""
    @State private var isAlertPresented = false

    @State private var classificationLabel: String = .init()
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    
    @State private var isCameraConnected: Bool? = false
    
    private var isEmulatorLoading: Bool
    @State var isClassifyButtonDisable = true
    
    init(
        router: Router<AppRoute>,
        isEmulatorLoading: Bool,
        managedObjectContext: NSManagedObjectContext
    ) {
        _viewModel = StateObject(
            wrappedValue: ScanningViewModel(
                router: router,
                managedObjectContext: managedObjectContext
            )
        )
        self.isEmulatorLoading = isEmulatorLoading
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .background(Color.clear)
            ScanningCameraView(thermalImage: $viewModel.thermalImage)
                .frame(
                    width: UIScreen.main.bounds.width,
                    height: UIScreen.main.bounds.height
                )
            
            if viewModel.isActivityIndicatorShowed {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(3, anchor: .center)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            }
            
            Button(action: {
                if let image = viewModel.thermalImage {
                    viewModel.savePhotos(thermalImage: image, originalImage: image)
                }
                if isClassifyButtonDisable {
                    isClassifyButtonDisable = false
                }
            }, label: {
                HStack {
                    Image(systemName: "camera")
                }
                .frame(maxWidth: 50, maxHeight: 50)
                .background(Color(red: 0, green: 122/255, blue: 255/255, opacity: 1.0))
                .clipShape(Circle())
            })
            .padding(.bottom, 100)
            
            HStack {
                Spacer()
                Button(action: {
                    
                }, label: {
                    HStack {
                        Image(systemName: "rectangle.and.text.magnifyingglass")
                            .padding(.leading)
                        Text("Classify")
                            .padding(.trailing)
                    }
                    .frame(maxWidth: 125, maxHeight: 50)
                    .background(Color.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .foregroundColor(.black)
                })
                .disabled(isClassifyButtonDisable)
                .opacity(0.6)
            }
            .padding(.horizontal)
            .padding(.bottom, 100)

        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            if isEmulatorLoading {
                print("Emulator clicked")
                print("isConnecting... \(viewModel.isActivityIndicatorShowed)")
                viewModel.connectEmulatorClicked()
                viewModel.isConnected()
                print("isCameraConnected: \($isCameraConnected)")
            } else {
                print("Camera clicked")
                viewModel.isActivityIndicatorShowed = true
                viewModel.connectDeviceClicked()
            }
        }
        .navigationBarItems(
            trailing:
                Button(
                    action: {
                        viewModel.disconnectClicked()
                        viewModel.goToStartPhotoGalleryView()
                    }) {
                    Image(systemName: "photo")
                }
        )
        .onChange(of: viewModel.showAlert) { showAlert in
            if showAlert {
                viewModel.isActivityIndicatorShowed = false
            }
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.errorMessage ?? ""),
                dismissButton: .default(Text("OK")) {
                    isAlertPresented = false
                    viewModel.router.pop()
                }
            )
        }
    }
}
