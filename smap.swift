//
//  main.swift
//  smap
//
//  Created by Jean-Nicolas on 17.12.21.
//

import Foundation
import ArgumentParser
import AppKit



@main
struct smap: ParsableCommand {
    enum smapError: Error {
        case FileDoesNotExists(_: String)
        case CannotReadData(fromFile: String)
        case CannotCreateLink
    }
    
    
    @Flag(name: .shortAndLong, help: "Show Location as Map in Browser")
    var browser = false
    
    @Argument(help: "Image file path")
    var imageFilePath: String
    
    mutating func run() throws  {
        let manager = FileManager.default

        guard manager.fileExists(atPath: imageFilePath) else {
            throw smapError.FileDoesNotExists(imageFilePath)
        }

        let imageFileURL = URL(fileURLWithPath: imageFilePath)
        guard let data = try? Data(contentsOf: imageFileURL) else {
            throw smapError.CannotReadData(fromFile: imageFilePath)
        }

        guard let mapLink = ImageMetadata(data: data)?.mapURL else {
            throw smapError.CannotCreateLink
            
        }
        
        if browser {
            NSWorkspace.shared.open(mapLink)
        } else {
            print("\"" + mapLink.absoluteString + "\"")
        }
        

        
       
        
    }
    
}





