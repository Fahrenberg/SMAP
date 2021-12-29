//
//  ImageMetadata.swift
//  ImageMetaDataReader
//
//  Created by Jean-Nicolas on 15.12.21.
//

import Foundation
import LocationKit
import MapKit

extension CLLocationCoordinate2D {
    var swissTopoCoordinateString: String {
        self.googleAPICoordinateString
    }
}

public struct ImageMetadata {
    typealias MetaData = [CFString:Any]
    typealias GeoPosition = String
    
    var metaData : MetaData
    
    init(url: URL) throws {
        let data = try Data(contentsOf: url)
        try self.init(data: data)
    }
    
    
    init(data: Data) throws {
        let options = [kCGImageSourceShouldCache: kCFBooleanFalse]
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, options as CFDictionary),
              let imageMetaData = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? MetaData
        else { throw MetaDataError.NoMetaData }
        self.metaData = imageMetaData
    }
    
    var coordinate: CLLocationCoordinate2D { get throws {
        guard let gpsMetaData = self.metaData[kCGImagePropertyGPSDictionary] as? MetaData
        else { throw MetaDataError.NoGPSTag }
        
        guard let lat = gpsMetaData[kCGImagePropertyGPSLatitude] as? CLLocationDegrees,
              let latRef = gpsMetaData[kCGImagePropertyGPSLatitudeRef] as? GeoPosition,
              let lng = gpsMetaData[kCGImagePropertyGPSLongitude] as? CLLocationDegrees,
              let lngRef = gpsMetaData[kCGImagePropertyGPSLongitudeRef] as? GeoPosition
        else { throw MetaDataError.noCoordinate }
        
        let wgs84 =  "\(lat)\(CoordinateAccents.degreeAccent.rawValue)\(latRef) \(lng)\(CoordinateAccents.degreeAccent.rawValue)\(lngRef)"
        guard let parsedCoordinate = wgs84.parseToCoordinate2D
        else { throw MetaDataError.noCoordinate }
        return parsedCoordinate
    } }
    
    var mapURL: URL { get throws {
        let mapCoordinate =  try self.coordinate
        var swissTopoComponent = URLComponents(string: "https://map.geo.admin.ch/")
        let coordinateString = mapCoordinate.swissTopoCoordinateString
        swissTopoComponent?.queryItems = [URLQueryItem(name: "swisssearch", value: coordinateString)]
        guard let url = swissTopoComponent?.url else {
            throw MetaDataError.InvalidURL
        }
        return url
    } }
    
}

/// Error Codes for Meta Data Parser

enum MetaDataError: Error {
    case NoExifTag
    case NoGPSTag
    case InvalidURL
    case NoMetaData
    case noCoordinate
}
