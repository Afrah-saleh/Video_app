//
//  VideoInfo.swift
//  video_Test
//
//  Created by Afrah Saleh on 06/07/1446 AH.
//
import Foundation

struct Video: Codable {
    
    let localName: String
    let link: String
    let additionalName: String // Added additionalName
}

struct VideoLinks: Codable {
    let videos: [Video]
}
func loadVideoLinks() -> [Video] {
    if let url = Bundle.main.url(forResource: "videoLinks", withExtension: "json") {
        do {
            let data = try Data(contentsOf: url)
            let videoLinks = try JSONDecoder().decode(VideoLinks.self, from: data)
            return videoLinks.videos
        } catch {
            print("Error loading video links: \(error)")
        }
    }
    return []
}

