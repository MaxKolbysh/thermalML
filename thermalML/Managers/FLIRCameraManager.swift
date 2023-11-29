//
//  FLIRCameraManager.swift
//  thermalML
//
//  Created by Ildar Khabibullin on 26.11.2023.
//

import ThermalSDK
import Combine

class FLIRCameraManager: NSObject, FLIRDiscoveryEventDelegate, FLIRDataReceivedDelegate, FLIRStreamDelegate {
    @Published var centerSpotText: String = ""
    @Published var distanceText: String = ""
    @Published var distanceValue: Float = 0.0
    @Published var thermalImage: UIImage?
    @Published var scaleImage: UIImage?
    @Published var currentImage: UIImage?
    
    var viewModel: ScanningViewModel?

    var discovery: FLIRDiscovery?
    var camera: FLIRCamera?
    var ironPalette: Bool = false
    
    var thermalStreamer: FLIRThermalStreamer?
    var stream: FLIRStream?
    
    let renderQueue = DispatchQueue(label: "render")
    
    func requireCamera() {
        guard camera == nil else {
            return
        }
        let camera = FLIRCamera()
        self.camera = camera
        camera.delegate = self
    }
    
    func connectDeviceClicked() {
        discovery?.start([.lightning, .flirOneWireless])
    }
    
    func disconnectClicked() {
        camera?.disconnect()
    }
    
    func connectEmulatorClicked() {
        discovery?.start(.emulator)
    }
    
    func ironPaletteClicked() {
        ironPalette = !ironPalette
    }
//    
//    func distanceSliderValueChanged() {
//        if let remoteControl = self.camera?.getRemoteControl(),
//           let fusionController = remoteControl.getFusionController() {
//            let newDistance = distanceSlider.value
//            try? fusionController.setFusionDistance(Double(newDistance))
//        }
//    }
        
    func cameraDiscovered(_ discoveredCamera: FLIRDiscoveredCamera) {
        let cameraIdentity = discoveredCamera.identity
        switch cameraIdentity.cameraType() {
            case .flirOne, .flirOneEdge, .flirOneEdgePro:
                requireCamera()
                guard !camera!.isConnected() else {
                    return
                }
                DispatchQueue.global().async {
                    do {
                        try self.camera?.connect(cameraIdentity)
                        let streams = self.camera?.getStreams()
                        guard let stream = streams?.first else {
                            NSLog("No streams found on camera!")
                            return
                        }
                        self.stream = stream
                        let thermalStreamer = FLIRThermalStreamer(stream: stream)
                        self.thermalStreamer = thermalStreamer
                        thermalStreamer.autoScale = true
                        thermalStreamer.renderScale = true
                        stream.delegate = self
                        do {
                            try stream.start()
                        } catch {
                            NSLog("stream.start error \(error)")
                        }
                    } catch {
                        NSLog("Camera connect error \(error)")
                    }
                }
            case .generic:
                ()
            @unknown default:
                fatalError("unknown cameraType")
        }
    }
    
    func discoveryError(_ error: String, netServiceError nsnetserviceserror: Int32, on iface: FLIRCommunicationInterface) {
        NSLog("\(#function)")
    }
    
    func discoveryFinished(_ iface: FLIRCommunicationInterface) {
        NSLog("\(#function)")
    }
    
    func cameraLost(_ cameraIdentity: FLIRIdentity) {
        NSLog("\(#function)")
    }
    
    func onDisconnected(_ camera: FLIRCamera, withError error: Error?) {
        NSLog("\(#function) \(String(describing: error))")
        DispatchQueue.main.async {
            self.thermalStreamer = nil
            self.stream = nil
//            let alert = UIAlertController(title: "Disconnected",
//                                          message: "Flir One disconnected",
//                                          preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func onError(_ error: Error) {
        NSLog("\(#function) \(error)")
    }
    
    func onImageReceived() {
        renderQueue.async {
            do {
                try self.thermalStreamer?.update()
            } catch {
                NSLog("update error \(error)")
            }
            let image = self.thermalStreamer?.getImage()
            DispatchQueue.main.async {
//                self.imageView.image = image
                if let image = self.thermalStreamer?.getImage() {
                    self.viewModel?.thermalImage = image
                }
//                if let scaleImage = self.thermalStreamer?.getScaleImage() {
//                    self.scaleImageView.image = scaleImage.resizableImage(withCapInsets: .zero, resizingMode: .stretch)
//                }
                self.thermalStreamer?.withThermalImage { image in
                    if image.palette?.name == image.paletteManager?.iron.name {
                        if !self.ironPalette {
                            image.palette = image.paletteManager?.gray
                        }
                    } else {
                        if self.ironPalette {
                            image.palette = image.paletteManager?.iron
                        }
                    }
                    if let measurements = image.measurements {
                        if measurements.getAllSpots().isEmpty {
                            do {
                                try measurements.addSpot(CGPoint(x: CGFloat(image.getWidth()) / 2,
                                                                 y: CGFloat(image.getHeight()) / 2))
                            } catch {
                                NSLog("addSpot error \(error)")
                            }
                        }
                        if let spot = measurements.getAllSpots().first {
                            self.centerSpotText = spot.getValue().description()
                        }
                    }
                    if let remoteControl = self.camera?.getRemoteControl(),
                       let fusionController = remoteControl.getFusionController() {
                        let distance = fusionController.getFusionDistance()
                        self.distanceText = "\((distance * 1000).rounded() / 1000)"
                        self.distanceValue = Float(distance)
                    }
                }
            }
        }
    }
}
