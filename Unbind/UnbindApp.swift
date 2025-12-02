//
//  UnbindApp.swift
//  Unbind
//
//  Created by Jacob Hartmann on 02/12/2025.
//

import SwiftUI

@main
struct UnbindApp: App {
    init() {
        // Register custom fonts
        FontLoader.shared.registerFonts()
        
        // Configure app appearance
        configureAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light) // Unbind uses light mode only
        }
    }
    
    private func configureAppearance() {
        // Navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor(Color.unbindInk)
        ]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}
