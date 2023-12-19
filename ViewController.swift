//
//  ViewController.swift
//  FLIROneCameraSwift
//
//  Created by FLIR on 2020-08-13.
//  Copyright © 2020 FLIR Systems AB. All rights reserved.
//

import UIKit
import ThermalSDK

class ViewController: UIViewController {
    var discovery: FLIRDiscovery?
    var camera: FLIRCamera?
    var ironPalette: Bool = false

    @IBOutlet weak var centerSpotLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scaleImageView: UIImageView!

    var thermalStreamer: FLIRThermalStreamer?
    var stream: FLIRStream?

    let renderQueue = DispatchQueue(label: "render")

    override func viewDidLoad() {
        super.viewDidLoad()

        discovery = FLIRDiscovery()
        discovery?.delegate = self
    }

    func requireCamera() {
        guard camera == nil else {
            return
        }
        let camera = FLIRCamera()
        self.camera = camera
        camera.delegate = self
    }

    @IBAction func connectDeviceClicked(_ sender: Any) {
          
        discovery?.start([.lightning, .flirOneWireless])
    }

    @IBAction func disconnectClicked(_ sender: Any) {
        camera?.disconnect()
    }

    @IBAction func connectEmulatorClicked(_ sender: Any) {
        discovery?.start(.emulator)
    }

    @IBAction func ironPaletteClicked(_ sender: Any) {
        ironPalette = !ironPalette
    }

    @IBAction func distanceSliderValueChanged(_ sender: Any) {
        if let remoteControl = self.camera?.getRemoteControl(),
           let fusionController = remoteControl.getFusionController() {
            let newDistance = distanceSlider.value
            try? fusionController.setFusionDistance(Double(newDistance))
        }
    }
}

extension ViewController: FLIRDiscoveryEventDelegate {

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
}

extension ViewController : FLIRDataReceivedDelegate {
    func onDisconnected(_ camera: FLIRCamera, withError error: Error?) {
        NSLog("\(#function) \(String(describing: error))")
        DispatchQueue.main.async {
            self.thermalStreamer = nil
            self.stream = nil
            let alert = UIAlertController(title: "Disconnected",
                                          message: "Flir One disconnected",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension ViewController : FLIRStreamDelegate {
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
                self.imageView.image = image
                if let scaleImage = self.thermalStreamer?.getScaleImage() {
                    self.scaleImageView.image = scaleImage.resizableImage(withCapInsets: .zero, resizingMode: .stretch)
                }
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
                            self.centerSpotLabel.text = spot.getValue().description()
                        }
                    }
                    if let remoteControl = self.camera?.getRemoteControl(),
                       let fusionController = remoteControl.getFusionController() {
                        let distance = fusionController.getFusionDistance()
                        self.distanceLabel.text = "\((distance * 1000).rounded() / 1000)"
                        self.distanceSlider.value = Float(distance)
                    }
                }
            }
        }
    }
}
