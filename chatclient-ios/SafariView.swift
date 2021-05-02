//
//  SafariView.swift
//  chatclient-ios
//
//  Created by blair on 5/1/21.
//

import SwiftUI
import SafariServices

final class CustomSafariViewController: UIViewController {
    var url: URL? {
        didSet {
            configure()
        }
    }
    
    private var safariViewController: SFSafariViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    private func configure() {
        if let viewController = safariViewController {
            viewController.willMove(toParent: self)
            viewController.view.removeFromSuperview()
            viewController.removeFromParent()
            self.safariViewController = nil
        }
        
        guard let url = url else { return }
        
        let newViewController = SFSafariViewController(url: url)
        addChild(newViewController)
        newViewController.view.frame = view.frame
        view.addSubview(newViewController.view)
        newViewController.didMove(toParent: self)
        self.safariViewController = newViewController
    }
}

struct SafariView: UIViewControllerRepresentable {
    @Binding var url: URL?
    
    func makeUIViewController(context: Context) -> CustomSafariViewController {
        CustomSafariViewController()
    }
    
    func updateUIViewController(_ uiViewController: CustomSafariViewController, context: Context) {
        uiViewController.url = url
    }
}
