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
    
    @Published var isCameraConnected: Bool?
    
    var discovery: FLIRDiscovery?
    var camera: FLIRCamera?
    var ironPalette: Bool = false
    
    var thermalStreamer: FLIRThermalStreamer?
    var stream: FLIRStream?
    
    let renderQueue = DispatchQueue(label: "render")

    override init() {
        super.init()
        configureDiscovery()
    }
    
    deinit {
        camera?.disconnect()
        discovery?.stop()
        print("FLIRCameraManager is being deinitialized")
    }
    
    func configureDiscovery() {
        print("configureDiscovery: \(configureDiscovery)")
        discovery = FLIRDiscovery()
        discovery?.delegate = self
    }
    
    func requireCamera() {
        guard camera == nil else {
            print("camera not found")
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
        print("Camera disconnected: \(camera.debugDescription)")
//        stream?.stop()
        discovery?.stop()
    }
    
    func isConnected() {
        isCameraConnected = camera?.isConnected()
    }
    
    func connectEmulatorClicked() {
        print("connectEmulatorClicked in Manager")
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
                DispatchQueue.global().async { [weak self] in
                    guard let self = self else { return }
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
        renderQueue.async { [weak self] in
            guard let self = self else { return }
            do {
                try self.thermalStreamer?.update()
            } catch {
                NSLog("update error \(error)")
            }
            let image = self.thermalStreamer?.getImage()
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                print(image)
// шкала
//                if let scaleImage = self.thermalStreamer?.getScaleImage() {
//                    let tImage = scaleImage.resizableImage(withCapInsets: .zero, resizingMode: .stretch)
//                    print("1234: \(tImage.size)")
//                }
                self.thermalImage = image
                print("thermalImage: \(self.thermalImage)")
                self.ironPalette = true
                
                
                self.thermalStreamer?.withThermalImage { [weak self] image in
                    guard let self = self else { return }
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
