import UIKit

final class SharedContentManager {

    static let shared = SharedContentManager()

    private let groupID = "group.Lumio"

    // MARK: - Container URL

    private var containerURL: URL? {
        let url = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: groupID
        )

        print("📦 APP GROUP CONTAINER URL:")
        print(url?.path ?? "❌ NIL - App Group not configured")

        return url
    }

    // MARK: - JSON URL

    private var jsonURL: URL? {
        let url = containerURL?.appendingPathComponent("sharedContent.json")

        print("🧾 JSON FILE PATH:")
        print(url?.path ?? "❌ NIL")

        return url
    }

    // MARK: Save

    func save(contents: [SharedContent]) {

        guard let jsonURL else {
            print("❌ save failed: jsonURL is nil")
            return
        }

        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted

            let data = try encoder.encode(contents)

            try data.write(to: jsonURL)

            print("✅ JSON SAVED SUCCESSFULLY")
            print("📍 Location: \(jsonURL.path)")

            if let jsonString = String(data: data, encoding: .utf8) {
                print("📄 JSON CONTENT:")
                print(jsonString)
            }

        } catch {
            print("❌ SAVE ERROR:")
            print(error)
        }
    }

    // MARK: Load

    func load() -> [SharedContent] {

        guard let jsonURL else {
            print("❌ load failed: jsonURL is nil")
            return []
        }

        do {
            let data = try Data(contentsOf: jsonURL)

            print("📥 JSON LOADED FROM:")
            print(jsonURL.path)

            if let jsonString = String(data: data, encoding: .utf8) {
                print("📄 RAW JSON:")
                print(jsonString)
            }

            return try JSONDecoder().decode([SharedContent].self, from: data)

        } catch {
            print("⚠️ LOAD ERROR (returning empty array):")
            print(error)
            return []
        }
    }

    // MARK: Add

    func add(_ content: SharedContent) {

        var contents = load()
        contents.insert(content, at: 0)

        print("➕ ADDING CONTENT:")
        print("Type:", content.type)
        print("ID:", content.id)

        save(contents: contents)
    }

    // MARK: Save Image

    func saveImage(_ image: UIImage) -> String? {

        guard let containerURL else {
            print("❌ saveImage failed: containerURL is nil")
            return nil
        }

        let filename = UUID().uuidString + ".jpg"
        let fileURL = containerURL.appendingPathComponent(filename)

        guard let data = image.jpegData(compressionQuality: 0.9) else {
            print("❌ Failed to convert UIImage to JPEG")
            return nil
        }

        do {
            try data.write(to: fileURL)

            print("🖼 IMAGE SAVED:")
            print(fileURL.path)

            return filename

        } catch {
            print("❌ IMAGE SAVE ERROR:")
            print(error)
            return nil
        }
    }

    // MARK: Load Image

    func loadImage(filename: String) -> UIImage? {

        guard let containerURL else {
            print("❌ loadImage failed: containerURL is nil")
            return nil
        }

        let fileURL = containerURL.appendingPathComponent(filename)

        do {
            let data = try Data(contentsOf: fileURL)

            print("🖼 IMAGE LOADED:")
            print(fileURL.path)

            return UIImage(data: data)

        } catch {
            print("❌ IMAGE LOAD ERROR:")
            print(error)
            return nil
        }
    }
}

//import UIKit
//
//final class SharedContentManager {
//
//    static let shared = SharedContentManager()
//
//    private let groupID = "group.Lumio"
//
//    private var containerURL: URL? {
//        FileManager.default.containerURL(
//            forSecurityApplicationGroupIdentifier: groupID
//        )
//    }
//
//    private var jsonURL: URL? {
//        containerURL?.appendingPathComponent(
//            "sharedContent.json"
//        )
//    }
//
//    // MARK: Save
//
//    func save(contents: [SharedContent]) {
//
//        guard let jsonURL else { return }
//
//        do {
//
//            let data = try JSONEncoder().encode(contents)
//
//            try data.write(to: jsonURL)
//
//        } catch {
//
//            print(error)
//        }
//    }
//
//    // MARK: Load
//
//    func load() -> [SharedContent] {
//
//        guard let jsonURL else { return [] }
//
//        guard
//            let data = try? Data(contentsOf: jsonURL)
//        else {
//            return []
//        }
//
//        return (
//            try? JSONDecoder()
//                .decode([SharedContent].self, from: data)
//        ) ?? []
//    }
//
//    // MARK: Add
//
//    func add(_ content: SharedContent) {
//
//        var contents = load()
//
//        contents.insert(content, at: 0)
//
//        save(contents: contents)
//    }
//
//    // MARK: Save Image
//
//    func saveImage(_ image: UIImage) -> String? {
//
//        guard let containerURL else { return nil }
//
//        let filename = UUID().uuidString + ".jpg"
//
//        let fileURL = containerURL.appendingPathComponent(
//            filename
//        )
//
//        guard
//            let data = image.jpegData(
//                compressionQuality: 0.9
//            )
//        else {
//            return nil
//        }
//
//        do {
//
//            try data.write(to: fileURL)
//
//            return filename
//
//        } catch {
//
//            print(error)
//
//            return nil
//        }
//    }
//
//    func loadImage(filename: String) -> UIImage? {
//
//        guard let containerURL else { return nil }
//
//        let fileURL = containerURL.appendingPathComponent(
//            filename
//        )
//
//        guard
//            let data = try? Data(contentsOf: fileURL)
//        else {
//            return nil
//        }
//
//        return UIImage(data: data)
//    }
//}
