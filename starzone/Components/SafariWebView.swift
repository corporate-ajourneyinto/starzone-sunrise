import SafariServices
import SwiftUI
import UIKit
import WebKit

struct EmbeddedWebView: UIViewRepresentable {
    let url: URL
    let reloadToken: Int

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.allowsBackForwardNavigationGestures = true
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if uiView.url?.absoluteString != url.absoluteString || context.coordinator.lastReloadToken != reloadToken {
            context.coordinator.lastReloadToken = reloadToken
            uiView.load(URLRequest(url: url))
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(lastReloadToken: reloadToken)
    }

    final class Coordinator {
        var lastReloadToken: Int
        init(lastReloadToken: Int) {
            self.lastReloadToken = lastReloadToken
        }
    }
}

struct SafariSheetView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let vc = SFSafariViewController(url: url)
        vc.preferredControlTintColor = UIColor(red: 218/255, green: 41/255, blue: 28/255, alpha: 1)
        return vc
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
