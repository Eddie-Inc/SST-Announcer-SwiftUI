//
//  FileManager.swift
//  Announcer
//
//  Created by Kai Quan Tay on 11/1/23.
//

import Foundation

/// Reads a type from a file
func read<T: Decodable>(_ type: T.Type, from file: String) -> T? {
    let filename = getDocumentsDirectory().appendingPathComponent(file)
    if let data = try? Data(contentsOf: filename) {
        if let values = try? JSONDecoder().decode(T.self, from: data) {
            return values
        }
    }

    return nil
}

/// Writes a type to a file
func write<T: Encodable>(_ value: T, to file: String, error onError: @escaping (Error) -> Void = { _ in }) {
    var encoded: Data

    do {
        encoded = try JSONEncoder().encode(value)
    } catch {
        onError(error)
        return
    }

    let filename = getDocumentsDirectory().appendingPathComponent(file)
    do {
        try encoded.write(to: filename)
        return
    } catch {
        // failed to write file – bad permissions, bad filename,
        // missing permissions, or more likely it can't be converted to the encoding
        onError(error)
    }
}

/// Checks if a file exists at a path
func exists(file: String) -> Bool {
    let path = getDocumentsDirectory().appendingPathComponent(file)
    return FileManager.default.fileExists(atPath: path.relativePath)
}

func makeDirectory(name: String,
                   onError: (Error) -> Void = { _ in }) {
    let path = getDocumentsDirectory().appendingPathComponent(name)
    do {
        try FileManager.default.createDirectory(at: path, withIntermediateDirectories: true)
    } catch {
        onError(error)
    }
}

/// Gets the documents directory
public func getDocumentsDirectory() -> URL {
    let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.kaitay.Announcer")!
    print("Documents live at \(url.description)")
    return url
}

public extension URL {
    /// The attributes of a url
    var attributes: [FileAttributeKey: Any]? {
        do {
            return try FileManager.default.attributesOfItem(atPath: path)
        } catch let error as NSError {
            print("FileAttribute error: \(error)")
        }
        return nil
    }

    /// The file size of the url
    var fileSize: UInt64 {
        return attributes?[.size] as? UInt64 ?? UInt64(0)
    }

    /// The file size of the url as a string
    var fileSizeString: String {
        return ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file)
    }

    /// The date of creation of the file
    var creationDate: Date? {
        return attributes?[.creationDate] as? Date
    }
}
