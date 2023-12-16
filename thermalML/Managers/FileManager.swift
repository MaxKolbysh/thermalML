//
//  FileManager.swift
//  thermalML
//
//  Created by Ildar Khabibullin on 14.12.2023.
//

import Foundation

class PhotoFileManager {
    static let shared = PhotoFileManager()

    private init() {
        createPhotosRootDirectory()
    }
    
    private var photosRootDirectory: URL {
        return documentsDirectory.appendingPathComponent("Photos")
    }
    
    private var documentsDirectory: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    private func createPhotosRootDirectory() {
        let directoryURL = photosRootDirectory
        if !Foundation.FileManager.default.fileExists(atPath: directoryURL.path) {
            do {
                try Foundation.FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating Photos root directory: \(error)")
            }
        }
    }
    
    private func createDirectory(for date: Date) -> URL? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        let directoryURL = photosRootDirectory.appendingPathComponent(dateString)
        print("===============================directory: \(directoryURL)")
        if !FileManager.default.fileExists(atPath: directoryURL.path) {
            do {
                try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
                return directoryURL
            } catch {
                print("Error creating directory: \(error)")
                return nil
            }
        }
        return directoryURL
    }
    
    // MARK: - Save Photo
    func savePhoto(isOriginal: Bool, _ photoData: Data) -> String? {
        let fileName = generateUniqueFileName(isOriginal: isOriginal)
        guard let directoryURL = createDirectory(for: Date()) else {
            return nil
        }
        let fileURL = directoryURL.appendingPathComponent(fileName)
        do {
            try photoData.write(to: fileURL)
            let imageNameAndPath = fileURL.path.replacingOccurrences(of: photosRootDirectory.path + "/", with: "")
            return imageNameAndPath
        } catch {
            print("Error saving photo: \(error)")
            return nil
        }
    }
    
    // MARK: - Fetch Photo
    func fetchPhoto(withPath relativePath: String) -> Data? {
        let fileURL = photosRootDirectory.appendingPathComponent(relativePath)
        do {
            return try Data(contentsOf: fileURL)
        } catch {
            print("Error fetching photo: \(error)")
            return nil
        }
    }
    
    // MARK: - Get Photo Info
    func fetchPhotoInfo(withPath relativePath: String) -> [String: String] {
        let fileURL = photosRootDirectory.appendingPathComponent(relativePath)
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            guard let fileSize = attributes[.size] as? NSNumber,
                  let creationDate = attributes[.creationDate] as? Date else {
                return [:]
            }

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yy HH-mm"
            let formattedDate = dateFormatter.string(from: creationDate)

            let sizeInMB = Double(truncating: fileSize) / (1024 * 1024)
            
            return ["name": fileURL.lastPathComponent,
                    "size": String(format: "%.2f MB", sizeInMB),
                    "creationDate": formattedDate]
        } catch {
            print("Error fetching photo info: \(error)")
            return [:]
        }
    }
    
    // MARK: - Delete Photo
    func deletePhoto(withPath path: String) {
        let fileURL = URL(fileURLWithPath: path)
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            print("Error deleting photo: \(error)")
        }
    }
    
    // MARK: - Generate name of file
    private func generateUniqueFileName(isOriginal: Bool) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmssSSS"
        return isOriginal 
        ? dateFormatter.string(from: Date()) + "_or" + ".jpg"
        : dateFormatter.string(from: Date()) + "_th" + ".jpg"
    }
}
