//  URLPreviewView.swift
//  Challenge3

import SwiftUI
import LinkPresentation

struct URLPreviewView: UIViewRepresentable {

    let url: URL

    final class Coordinator {
        var metadataProvider: LPMetadataProvider?
        var currentURL: URL?
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> LPLinkView {
        let view = LPLinkView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .clear
        
        let provider = LPMetadataProvider()
        context.coordinator.metadataProvider = provider

        provider.startFetchingMetadata(for: url) { metadata, _ in
            guard let metadata else { return }
            DispatchQueue.main.async {
                view.metadata = metadata
                view.invalidateIntrinsicContentSize()
                view.setNeedsLayout()
                view.layoutIfNeeded()
            }
        }

        return view
    }

    func updateUIView(_ uiView: LPLinkView, context: Context) {
        guard context.coordinator.currentURL != url else { return }

        context.coordinator.currentURL = url
        context.coordinator.metadataProvider?.cancel()

        let provider = LPMetadataProvider()
        context.coordinator.metadataProvider = provider

        provider.startFetchingMetadata(for: url) { metadata, _ in
            guard let metadata else { return }
            DispatchQueue.main.async {
                uiView.metadata = metadata
                uiView.invalidateIntrinsicContentSize()
                uiView.setNeedsLayout()
                uiView.layoutIfNeeded()
            }
        }
    }
}
