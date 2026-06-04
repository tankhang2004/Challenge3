//  Color+Hex.swift
//  Challenge3

import SwiftUI


// MARK: - Calendar Extension

extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }
}
//extension Color {
//    init(_ hex : String) {
//        let hexString = hex.trimmingCharacters(in: .alphanumerics.inverted)
//        var rgb: UInt64 = 0
//        Scanner(string: hexString).scanHexInt64(&rgb)
//        self.init(
//            red:   Double((rgb >> 16) & 0xFF) / 255,
//            green: Double((rgb >> 8)  & 0xFF) / 255,
//            blue:  Double( rgb        & 0xFF) / 255
//        )
//    }
//}
// MARK: - Colors (unchanged)

extension Color {
    static let brandBlue   = Color(red: 89/255,  green: 193/255, blue: 253/255)
    static let brandOrange = Color(red: 253/255, green: 144/255, blue: 89/255)
    static let pageBg      = Color(red: 246/255, green: 249/255, blue: 254/255)
    
}
extension Color {
//    static let brandBlue             = Color("BrandBlue")
//    static let brandOrange           = Color("BrandOrange")
    static let secondaryBlue         = Color("SecondaryBlue")
    static let secondaryOrange       = Color("SecondaryOrange")
    static let pageBackground        = Color("PageBackground")
    static let cardSurface           = Color("CardSurface")
    static let musicSectionBackground = Color("MusicSectionBackground")
}

//  SharedContentManager+Images.swift
//  Challenge3
//These are for save and load from file system instead of containerID from AppGroup
import UIKit

extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}

extension UIImage: @retroactive Identifiable {
    public var id: ObjectIdentifier { ObjectIdentifier(self) }
}

extension SharedContentManager {

    /// Saves a UIImage to the app's documents directory and returns the filename.
    func saveImage(_ image: UIImage, filename: String? = nil) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.85) else { return nil }
        let name = filename ?? "\(UUID().uuidString).jpg"
        let url = documentsURL.appendingPathComponent(name)
        do {
            try data.write(to: url)
            return name
        } catch {
            print("❌ Failed to save image: \(error)")
            return nil
        }
    }

    /// Deletes an image file by filename.
    func deleteImage(filename: String) {
        let url = documentsURL.appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: url)
    }

    private var documentsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func loadImageFileSystem(filename: String) -> UIImage? {
        let url = documentsURL.appendingPathComponent(filename)

        guard let data = try? Data(contentsOf: url) else {
            return nil
        }

        return UIImage(data: data)
    }
}
