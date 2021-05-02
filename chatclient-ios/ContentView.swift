//
//  ContentView.swift
//  chatclient-ios
//
//  Created by blair on 5/1/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ChatWebView().preferredColorScheme(.dark)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
