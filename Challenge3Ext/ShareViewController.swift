import UIKit
import UniformTypeIdentifiers
import SwiftUI

class ShareViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        processSharedContent()

        let rootView = ShareRootView {

            self.extensionContext?.completeRequest(
                returningItems: [],
                completionHandler: nil
            )
        }

        let hosting = UIHostingController(
            rootView: rootView
        )

        addChild(hosting)

        hosting.view.frame = view.bounds

        view.addSubview(hosting.view)

        hosting.didMove(toParent: self)
    }

    private func processSharedContent() {

        guard
            let item = extensionContext?.inputItems.first
                as? NSExtensionItem,

            let attachments = item.attachments
        else {
            return
        }

        for provider in attachments {

            // IMAGE

            if provider.hasItemConformingToTypeIdentifier(
                UTType.image.identifier
            ) {

                provider.loadObject(ofClass: UIImage.self) {
                    image, error in

                    guard let image = image as? UIImage
                    else { return }

                    if let filename =
                        SharedContentManager.shared
                            .saveImage(image)
                    {

                        let content = SharedContent(
                            id: UUID(),
                            type: .image,
                            text: nil,
                            url: nil,
                            imageFilename: filename,
                            createdAt: .now
                        )

                        SharedContentManager.shared
                            .add(content)
                    }
                }
            }

            // URL

            if provider.hasItemConformingToTypeIdentifier(
                UTType.url.identifier
            ) {

                provider.loadObject(ofClass: URL.self) {
                    url, error in

                    guard let url = url else { return }

                    let content = SharedContent(
                        id: UUID(),
                        type: .url,
                        text: nil,
                        url: url.absoluteString,
                        imageFilename: nil,
                        createdAt: .now
                    )

                    SharedContentManager.shared
                        .add(content)
                }
            }

            // TEXT

            if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {

                provider.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { item, error in

                    if let error = error {
                        print("❌ TEXT LOAD ERROR:")
                        print(error)
                        return
                    }

                    if let text = item as? String {

                        let content = SharedContent(
                            id: UUID(),
                            type: .text,
                            text: text,
                            url: nil,
                            imageFilename: nil,
                            createdAt: .now
                        )

                        SharedContentManager.shared.add(content)
                    } else if let data = item as? Data,
                              let text = String(data: data, encoding: .utf8) {

                        let content = SharedContent(
                            id: UUID(),
                            type: .text,
                            text: text,
                            url: nil,
                            imageFilename: nil,
                            createdAt: .now
                        )

                        SharedContentManager.shared.add(content)
                    }
                }
            }
        }
    }
}

//import SwiftUI
//import Social
//import UniformTypeIdentifiers
//import UIKit
//
//class ShareViewController: UIViewController {
//    @IBOutlet weak var imageView: UIImageView!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        print("viewDidLoad")
//        if let item = extensionContext?.inputItems.first as? NSExtensionItem {
//            print(item)
//        }
//        
//        if let item = extensionContext?.inputItems.first as? NSExtensionItem,
//           let provider = item.attachments?.first {
//            
//            if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
//                
//                provider.loadObject(ofClass: UIImage.self) { image, error in
//                    DispatchQueue.main.async {
//                        
//                        if let image = image as? UIImage {
//                            
//                            // preview image
//                            self.imageView.image = image
//                        }
//                    }
//                }
//            }
//        }
//        
//        let rootView = ShareRootView {
//            self.extensionContext?.completeRequest(
//                returningItems: [],
//                completionHandler: nil
//            )
//        }
//        
//        let hosting = UIHostingController(rootView: rootView)
//        
//        addChild(hosting)
//        hosting.view.frame = view.bounds
//        hosting.view.alpha = 0.5
//        view.backgroundColor = .white
//        //        hosting.view.frame = CGRect(
//        //            x: 50,
//        //            y: 50,
//        //            width: 200,
//        //            height: 200
//        //        )
//        //        view.backgroundColor = .red
//        view.addSubview(hosting.view)
//        hosting.didMove(toParent: self)
//    }
//    @IBAction func doneButtonTapped(_ sender: UIButton) {
//        
//        extensionContext?.completeRequest(
//            returningItems: [],
//            completionHandler: nil
//        )
//    }
//}





//    override func isContentValid() -> Bool {
//        true
//    }
//
//    override func didSelectPost() {
//        extensionContext?.completeRequest(
//            returningItems: [],
//            completionHandler: nil
//        )
//    }
//
//    override func configurationItems() -> [Any]! {
//        []
//    }
//}




//
//import UIKit
//import UniformTypeIdentifiers
//
//class ShareViewController: UIViewController {
//
//    @IBOutlet weak var imageView: UIImageView!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        print("viewDidLoad")
//
//        loadSharedImage()
//    }
//
//    private func loadSharedImage() {
//
//        guard
//            let item = extensionContext?.inputItems.first as? NSExtensionItem,
//            let provider = item.attachments?.first
//        else {
//            print("No attachment found")
//            return
//        }
//
//        print(provider)
//
//        guard provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) else {
//            print("Not an image")
//            return
//        }
//
//        provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
//
//            DispatchQueue.main.async {
//
//                if let error = error {
//                    print("Error loading image:", error)
//                    return
//                }
//
//                guard let self = self else { return }
//
//                guard let image = image as? UIImage else {
//                    print("Failed to convert to UIImage")
//                    return
//                }
//
//                self.imageView.image = image
//            }
//        }
//    }
//
//    @IBAction func doneButtonTapped(_ sender: UIButton) {
//
//        extensionContext?.completeRequest(
//            returningItems: [],
//            completionHandler: nil
//        )
//    }
//}
