//
//  StartConnectionView.swift
//  thermalML
//
//  Created by Ildar Khabibullin on 26.11.2023.
//

import SwiftUI

struct StartConnectionView: View {
    @StateObject var viewModel: StartConnectionViewModel
    @State private var isSheetPresented = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isAlertPresented = false
    private var isEmulatorLoading: Bool = false
    
    init(router: Router<AppRoute>) {
        _viewModel = StateObject(wrappedValue: StartConnectionViewModel(router: router))
    }
    
    var body: some View {
        VStack {
            Image("mainLogo")
                .padding(.top, 120)
            Spacer()

            Text("Camera connecting")
                .font(.system(size: 17, weight: .black))
            VStack(alignment: .leading) {
                Text("1. Switch on the flir camera")
                     // Add padding below this text

                Text("2. Then click start connecting")
            }.padding(.bottom, 30)
            Spacer()

            Image("cameraImage")
            Spacer()

            Button(action: {
                alertTitle = "Create connection"
                alertMessage = "Confirm device connection?"
                isAlertPresented.toggle()
            }, label: {
                HStack {
                    Image(systemName: "link")
                        .padding(.leading)
                        .foregroundStyle(.white)
                    Text("Start connecting")
                        .foregroundColor(.white)
                        .padding(.trailing)
                }
                .frame(maxWidth: 190, maxHeight: 50)
                .background(Color(red: 0, green: 122/255, blue: 255/255, opacity: 1.0))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .foregroundColor(.white)
            })
            Button(action: {
                viewModel.goToScanningView(isEmulatorLoading: true)
            }, label: {
                Text("Start emulator")
                    .foregroundColor(Color(red: 0, green: 122/255, blue: 255/255, opacity: 1.0))
            })
            Spacer()
            Button(action: {
                isSheetPresented.toggle()
            }, label: {
                HStack {
                    Image(systemName: "info.circle")
                        .padding(.leading)
                        .foregroundStyle(.black)
                }
                .foregroundColor(.black)
            })
            .padding(.bottom, 100)
        }
        .edgesIgnoringSafeArea(.top)
        .sheet(isPresented: $isSheetPresented) {
            BottomSheetView(isPresented: $isSheetPresented)
        }
        .navigationBarItems(trailing:
            Button(action: {
                print("Gallery Button Tapped")
            }) {
                Image(systemName: "photo")
            }
        )
        .alert(isPresented: $isAlertPresented) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                primaryButton: .default(Text("Cancel")) {
                    isAlertPresented = false
                },
                secondaryButton: .default(Text("Join")) {
                    isAlertPresented = false
                    viewModel.goToScanningView(isEmulatorLoading: false)
                }
            )
        }
    }
}

#Preview {
    StartConnectionView(router: Router())
}
