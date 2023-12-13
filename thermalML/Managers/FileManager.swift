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
    func savePhoto(_ photoData: Data) -> (fileName: String, relativePath: String)? {
        let fileName = generateUniqueFileName()
        guard let directoryURL = createDirectory(for: Date()) else {
            return nil
        }
        let fileURL = directoryURL.appendingPathComponent(fileName)
        do {
            try photoData.write(to: fileURL)
            let relativePath = fileURL.path.replacingOccurrences(of: photosRootDirectory.path + "/", with: "")
            return (fileName, relativePath)
        } catch {
            print("Error saving photo: \(error)")
            return nil
        }
    }
    
    // MARK: - Fetch Photo
    func fetchPhoto(withPath path: String) -> Data? {
        let fileURL = URL(fileURLWithPath: path)
        do {
            return try Data(contentsOf: fileURL)
        } catch {
            print("Error fetching photo: \(error)")
            return nil
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
    private func generateUniqueFileName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmssSSS"
        return dateFormatter.string(from: Date()) + ".jpg"
    }
}
