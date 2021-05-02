//
//  WebView.swift
//  chatclient-ios
//
//  Created by blair on 5/1/21.
//

import SwiftUI
import WebKit

struct ChatWebView : UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        guard let scriptPath = Bundle.main.path(forResource: "credentialManager", ofType: "js"),
              let scriptSource = try? String(contentsOfFile: scriptPath) else
        {
            print("Couldn't load bundle")
            return WKWebView()
        }
        
        let userScript = WKUserScript(source: scriptSource, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        let config = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        userContentController.addUserScript(userScript)
        userContentController.addScriptMessageHandler(context.coordinator, contentWorld: .page, name: "getStoredServers")
        userContentController.addScriptMessageHandler(context.coordinator, contentWorld: .page, name: "storeServerInfo")
        userContentController.addScriptMessageHandler(context.coordinator, contentWorld: .page, name: "removeServerInfo")
        config.userContentController = userContentController
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.uiDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let url = URL(string: "https://192.168.0.145:3000")!
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandlerWithReply, WKUIDelegate {
        let parent: ChatWebView
        init(parent: ChatWebView) {
            self.parent = parent
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage, replyHandler: @escaping (Any?, String?) -> Void) {
            print("got a message from JS. name: " + message.name)
            var response: Any? = nil;

            if message.name == "getStoredServers" {
                response = Keychain.readCredentials()
            }
            else if message.name == "storeServerInfo" {
                if let info = message.body as? Array<String> {
                    response = Keychain.addServer(info[0], withUsername: info[1], andPassword: info[2])
                }
                else {
                    response = false
                }
            }
            else if message.name == "removeServerInfo" {
                if let info = message.body as? Array<String> {
                    response = Keychain.removeConnection(from: info[0], withUsername: info[1])
                }
                else {
                    response = false
                }
            }

            replyHandler(response, nil)
        }
        
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            print("JS alert: " + message)
            completionHandler()
        }
    }
}
