//
//  ImageMetadata.swift
//  ImageMetaDataReader
//
//  Created by Jean-Nicolas on 15.12.21.
//

import Foundation
import LocationKit
import MapKit

public struct ImageMetadata {
    typealias PropertiesDict = [CFString:Any]
    
    var properties : PropertiesDict
    
    init?(url: URL) {
        guard let data = try? Data(contentsOf: url) else {
                return nil
        }
        self.init(data: data)
    }
    
    
    init?(data: Data) {
        let options = [kCGImageSourceShouldCache: kCFBooleanFalse]
        if let imageSource = CGImageSourceCreateWithData(data as CFData, options as CFDictionary),
           let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? PropertiesDict {
            self.properties = imageProperties
        } else {
            return nil
        }
    }
    
    var coordinate: CLLocationCoordinate2D? {
        guard let gpsMetadata = self.properties[kCGImagePropertyGPSDictionary] as? PropertiesDict else {
            return nil
        }
        guard let lat = gpsMetadata[kCGImagePropertyGPSLatitude] as? Double,
              let latRef = gpsMetadata[kCGImagePropertyGPSLatitudeRef] as? String,
              let lng = gpsMetadata[kCGImagePropertyGPSLongitude] as? Double,
              let lngRef = gpsMetadata[kCGImagePropertyGPSLongitudeRef] as? String else {
            print("FotoProperties - coordinate \(Properties.noCoordinate)")
            return nil
        }
        let wgs84 =  "\(lat)\(CoordinateAccents.degreeAccent.rawValue)\(latRef) \(lng)\(CoordinateAccents.degreeAccent.rawValue)\(lngRef)"
        guard let parsedCoordinate = wgs84.parseToCoordinate2D else {
            print("FotoProperties - parsedCoordinate == nil: \(Properties.noCoordinate)")
            return nil
        }
        return parsedCoordinate
    }
    
    var mapURL: URL? {
        guard let mapCoordinate = self.coordinate else {
            print("Invalid or missing coordinate (GPS-Tag)")
            return nil
        }
        var swissTopoComponent = URLComponents(string: "https://map.geo.admin.ch/")
        let coordinateString = "\(mapCoordinate.latitude),\(mapCoordinate.longitude)"
        swissTopoComponent?.queryItems = [URLQueryItem(name: "swisssearch", value: coordinateString)]
        
        return swissTopoComponent?.url
    }
    
}

/// Error Codes for Property Parser
enum Properties: String {
    case noTIFF = "No TIFF"
    case noCamera = "No Camera"
    case noModel = "No Model"
    case noExif = "No Exif"
    case noDate = "No DateTimeOriginal"
    case noDateOffset = "No OffsetTimeOriginal"
    case noCoordinate = "No Coordinate"
    case noGPSAltitude = "No Stored GPS-Altitude"
}
