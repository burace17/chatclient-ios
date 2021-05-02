//
//  ContentView.swift
//  chatclient-ios
//
//  Created by blair on 5/1/21.
//

import SwiftUI

struct ContentView: View {
    @State var showingPopoverBrowser = false
    @State var popoverURL: URL?
    var body: some View {
        ChatWebView(presentSafariCallback: { (url: URL?) in
            popoverURL = url
            showingPopoverBrowser = popoverURL != nil
        })
        .preferredColorScheme(.dark)
        .popover(isPresented: $showingPopoverBrowser) {
            SafariView(url: $popoverURL)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
