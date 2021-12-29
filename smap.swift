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
    
    @Flag(name: .shortAndLong, help: "Show Location as Map in Browser")
    var browser = false
    
    @Argument(help: "Image file path")
    var imageFilePath: String
    
    mutating func run() throws  {

        let imageFileURL = URL(fileURLWithPath: imageFilePath)
        
        let imageData = try Data(contentsOf: imageFileURL)
        
        let mapLink = try ImageMetadata(data: imageData).mapURL
        
        if browser {
            NSWorkspace.shared.open(mapLink)
        } else {
            print("\"" + mapLink.absoluteString + "\"")
        }
        
    }
    
}





