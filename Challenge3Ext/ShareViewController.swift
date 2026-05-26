import SwiftUI
import Social

class ShareViewController: SLComposeServiceViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let rootView = ShareRootView {
            self.extensionContext?.completeRequest(
                returningItems: [],
                completionHandler: nil
            )
        }

        let hosting = UIHostingController(rootView: rootView)

        addChild(hosting)
        hosting.view.frame = view.bounds
        view.addSubview(hosting.view)
        hosting.didMove(toParent: self)
    }

    override func isContentValid() -> Bool {
        true
    }

    override func didSelectPost() {
        extensionContext?.completeRequest(
            returningItems: [],
            completionHandler: nil
        )
    }

    override func configurationItems() -> [Any]! {
        []
    }
}
