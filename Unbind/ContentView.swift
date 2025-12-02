//
//  ContentView.swift
//  Unbind
//
//  Main content view - handles onboarding vs main app
//

import SwiftUI

struct ContentView: View {
    @StateObject private var userState = UserState()
    @State private var isLoading = true
    @State private var showSplash = true
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
                    .transition(.opacity)
            } else if !userState.hasCompletedOnboarding {
                OnboardingView()
                    .environmentObject(userState)
                    .transition(.opacity)
            } else {
                HomeView()
                    .environmentObject(userState)
                    .transition(.opacity)
            }
        }
        .animation(.unbindSlow, value: showSplash)
        .animation(.unbindSlow, value: userState.hasCompletedOnboarding)
        .onAppear {
            // Show splash for a moment
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    showSplash = false
                }
            }
        }
    }
}

// MARK: - Splash View
struct SplashView: View {
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.95
    
    var body: some View {
        ZStack {
            AmbientBackground(style: .day)
            
            VStack(spacing: 16) {
                Text("Unbind")
                    .font(.system(size: 42, weight: .medium, design: .rounded))
                    .foregroundColor(.unbindInk)
                
                Text("Let go of inner pressure")
                    .font(UnbindTypography.bodySystem)
                    .foregroundColor(.unbindInk.opacity(0.6))
            }
            .opacity(opacity)
            .scaleEffect(scale)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                opacity = 1
                scale = 1
            }
        }
    }
}

#Preview {
    ContentView()
}
