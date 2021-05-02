//
//  WebView.swift
//  chatclient-ios
//
//  Created by blair on 5/1/21.
//

import SwiftUI
import WebKit

class WKWebViewNoAccessory: WKWebView {
    var accessoryView: UIView?
    override var inputAccessoryView: UIView? {
        return accessoryView
    }
}

struct ChatWebView : UIViewRepresentable {
    typealias PresentSafariCallback = ((_ url: URL?) -> Void)
    var presentSafariCallback: PresentSafariCallback
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, presentSafariCallback: self.presentSafariCallback)
    }
    
    func makeUIView(context: Context) -> WKWebViewNoAccessory {
        guard let scriptPath = Bundle.main.path(forResource: "credentialManager", ofType: "js"),
              let scriptSource = try? String(contentsOfFile: scriptPath) else
        {
            print("Couldn't load bundle")
            return WKWebViewNoAccessory()
        }
        
        let userScript = WKUserScript(source: scriptSource, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        let config = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        userContentController.addUserScript(userScript)
        userContentController.addScriptMessageHandler(context.coordinator, contentWorld: .page, name: "getStoredServers")
        userContentController.addScriptMessageHandler(context.coordinator, contentWorld: .page, name: "storeServerInfo")
        userContentController.addScriptMessageHandler(context.coordinator, contentWorld: .page, name: "removeServerInfo")
        config.userContentController = userContentController
        
        let webView = WKWebViewNoAccessory(frame: .zero, configuration: config)
        webView.uiDelegate = context.coordinator
        
        let url = URL(string: "https://192.168.0.145:3000")!
        let request = URLRequest(url: url)
        webView.load(request)
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebViewNoAccessory, context: Context) {
        
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandlerWithReply, WKUIDelegate {
        var presentSafariCallback: PresentSafariCallback
        
        let parent: ChatWebView
        init(parent: ChatWebView, presentSafariCallback: @escaping PresentSafariCallback) {
            self.parent = parent
            self.presentSafariCallback = presentSafariCallback
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage, replyHandler: @escaping (Any?, String?) -> Void) {
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
        
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            self.presentSafariCallback(navigationAction.request.url)
            return nil
        }
    }
}
