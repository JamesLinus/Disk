//
//  Disk+UIImage.swift
//  Disk
//
//  Created by Saoud Rizwan on 7/22/17.
//  Copyright © 2017 Saoud Rizwan. All rights reserved.
//

import Foundation

public extension Disk {
    /// Store image to disk
    ///
    /// - Parameters:
    ///   - image: image to store to disk
    ///   - directory: directory to store image in
    ///   - name: name to give to image file (don't need to include .png or .jpg extension)
    static func store(_ image: UIImage, to directory: Directory, as name: String) {
        var imageData: Data!
        var imageFileExtension: FileExtension!
        if let data = UIImagePNGRepresentation(image) {
            imageData = data
            imageFileExtension = .png
        } else if let data = UIImageJPEGRepresentation(image, 1) {
            imageData = data
            imageFileExtension = .jpg
        } else {
            printError("Could not convert image to PNG or JPEG")
            return
        }
        let fileName = validateFileName(name)
        let url = createURL(for: directory, name: fileName, extension: imageFileExtension)
        do {
            if FileManager.default.fileExists(atPath: url.path) {
                printError("File with name \"\(name)\" already exists in \(directory.rawValue). Removing and replacing with contents of new data...")
                try FileManager.default.removeItem(at: url)
            }
            FileManager.default.createFile(atPath: url.path, contents: imageData, attributes: nil)
        } catch {
            printError(error.localizedDescription)
        }
    }
    
    /// Retrive image from disk
    ///
    /// - Parameters:
    ///   - name: name of image on disk
    ///   - directory: directory where image is stored
    ///   - type: here for Swifty generics magic, use UIImage.self
    /// - Returns: UIImage from disk
    static func retrieve(_ name: String, from directory: Directory, as type: UIImage.Type) -> UIImage? {
        let fileName = validateFileName(name)
        guard let url = getExistingFileURL(for: fileName, with: [.png, .jpg, .none], in: directory) else {
            printError("Image with name \"\(name)\" does not exist in \(directory.rawValue)")
            return nil
        }
        if let data = FileManager.default.contents(atPath: url.path) {
            if let image = UIImage(data: data) {
                return image
            } else {
                printError("Could not convert image from data at \(url.path) to UIImage")
                return nil
            }
        } else {
            printError("No data at \(url.path)")
            return nil
        }
    }
}


