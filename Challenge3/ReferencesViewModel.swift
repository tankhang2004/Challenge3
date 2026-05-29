import Foundation
import Observation

@Observable
final class ReferencesViewModel {

    var items: [SharedContent] = []

    private let manager = SharedContentManager.shared

    init() {
        load()
    }

    func load() {
        items = manager.load()
    }

    func refresh() {
        load()
    }
}
