import Foundation

struct SharedContent: Codable {

    enum ContentType: String, Codable {
        case image
        case url
        case text
    }

    let id: UUID
    let type: ContentType

    let text: String?
    let url: String?
    let imageFilename: String?

    let createdAt: Date
}
