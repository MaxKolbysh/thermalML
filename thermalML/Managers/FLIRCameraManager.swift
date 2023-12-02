//
//  FLIRCameraManager.swift
//  thermalML
//
//  Created by Ildar Khabibullin on 26.11.2023.
//

import ThermalSDK
import Combine

class FLIRCameraManager: NSObject {
    
    @Published var centerSpotText: String = ""
    @Published var distanceText: String = ""
    @Published var distanceValue: Float = 0.0
    @Published var thermalImage: UIImage?
    
    @Published var isCameraConnected: Bool?
    
    @Published var error: Error?
    
    var discovery: FLIRDiscovery?
    var camera: FLIRCamera?
    var ironPalette: Bool = false
    
    var thermalStreamer: FLIRThermalStreamer?
    var stream: FLIRStream?
    
    let renderQueue = DispatchQueue(label: "render")
    
    override init() {
        super.init()
        print("Initializing FLIRCameraManager")
        configureDiscovery()
    }
    
    deinit {
        camera?.disconnect()
        discovery?.stop()
        print("FLIRCameraManager is being deinitialized")
    }
    
    func configureDiscovery() {
        print("Configuring discovery")
        discovery = FLIRDiscovery()
        discovery?.delegate = self
        print("Discovery configured")
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
        discovery?.stop()
        stream?.stop()
        self.thermalStreamer = nil
        self.stream = nil
        print("Camera disconnected: \(camera.debugDescription)")
    }
    
    func isConnected() {
        isCameraConnected = camera?.isConnected()
    }
    
    func connectEmulatorClicked() {
        print("connectEmulatorClicked in Manager - Starting discovery for emulator")
        discovery?.start(.emulator, cameraType: .flirOne)
    }
    
    func ironPaletteClicked() {
        ironPalette = !ironPalette
    }
}

extension FLIRCameraManager: FLIRDiscoveryEventDelegate {
    func cameraDiscovered(_ discoveredCamera: FLIRDiscoveredCamera) {
        print("Camera discovered: \(discoveredCamera.identity)")

        let cameraIdentity = discoveredCamera.identity
        switch cameraIdentity.cameraType() {
            case .flirOne, .flirOneEdge, .flirOneEdgePro:
                requireCamera()
                
                guard let camera = camera else { 
                    NSLog("Camera is nil")
                    return
                }

                guard !camera.isConnected() else {
                    print("====Camera is not connected")
                    return
                }
                                
                DispatchQueue.global().async { [weak self] in
                    
                    guard let self = self else { return }
                    
                    do {
                        try camera.connect(cameraIdentity)
                    } catch {
                        print("Error connecting to camera: \(error)")
                        self.error = error
                        return
                    }
                    
                    
                    let streams = self.camera?.getStreams()
                    guard let stream = streams?.first else {
                        NSLog("No streams found on camera!")
                        self.error = error
                        return
                    }
                    self.stream = stream
                    let thermalStreamer = FLIRThermalStreamer(stream: stream)
                    self.thermalStreamer = thermalStreamer
                    thermalStreamer.autoScale = true
                    thermalStreamer.renderScale = true
                    stream.delegate = self
                    
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.isCameraConnected = true
                    }
                    
                    do {
                        try stream.start()
                    } catch {
                        NSLog("stream.start error \(error)")
                        self.error = error
                    }
                    
                }
            case .generic:
                print(".generic")
            case .earhart:
                print("earhart")
            case .unknown:
                print("unknown")
            @unknown default:
                print("unknown cameraType")
                self.error = error
        }
    }
    
    func discoveryError(_ error: String, netServiceError nsnetserviceserror: Int32, on iface: FLIRCommunicationInterface) {
        print("Discovery error: \(error), NetServiceError: \(nsnetserviceserror), Interface: \(iface)")

        NSLog("\(#function)")
        self.error = error as? any Error
    }
    
    func discoveryFinished(_ iface: FLIRCommunicationInterface) {
        print("Discovery finished on interface: \(iface)")

        NSLog("\(#function)")
    }
    
    func cameraLost(_ cameraIdentity: FLIRIdentity) {
        print("Camera lost: \(cameraIdentity)")

        NSLog("\(#function)")
        self.error = error
    }
}

extension FLIRCameraManager: FLIRDataReceivedDelegate {
    
    func onDisconnected(_ camera: FLIRCamera, withError error: Error?) {
        NSLog("\(#function) \(String(describing: error))")
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.thermalStreamer = nil
            self.stream = nil
            self.error = error
                //            let alert = UIAlertController(title: "Disconnected",
                //                                          message: "Flir One disconnected",
                //                                          preferredStyle: .alert)
                //            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                //            self.present(alert, animated: true, completion: nil)
        }
    }
    
}

extension FLIRCameraManager: FLIRStreamDelegate {
    
    func onError(_ error: Error) {
        NSLog("\(#function) \(error)")
        self.error = error
    }
    
    func onImageReceived() {
        renderQueue.async { [weak self] in
            guard let self = self else { return }
            do {
                try self.thermalStreamer?.update()
            } catch {
                NSLog("update error \(error)")
                self.error = error
            }
            let image = self.thermalStreamer?.getImage()
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                print(image)
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

extension FLIRCameraManager {
    func handleError(_ error: Error) {
        NSLog("Error occurred: \(error.localizedDescription)")

        DispatchQueue.main.async { [weak self] in
            self?.error = error
        }
    }
}
