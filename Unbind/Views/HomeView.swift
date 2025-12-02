//
//  HomeView.swift
//  Unbind
//
//  Main Home Screen - "I'm Feeling Something"
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var userState: UserState
    @State private var showReleaseFlow = false
    @State private var showMorningReset = false
    @State private var showEveningUnwind = false
    @State private var showProgress = false
    @State private var textOpacity: Double = 0
    @State private var buttonScale: CGFloat = 0.9
    @State private var breatheAnimation = false
    
    var body: some View {
        ZStack {
            // Ambient background
            AmbientBackground(style: .day)
            
            VStack(spacing: 0) {
                // Top area with subtle streak indicator (now tappable)
                HStack {
                    Spacer()
                    Button(action: { showProgress = true }) {
                        StreakLight(streak: userState.currentStreak)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .padding(.trailing, 24)
                    .padding(.top, 16)
                }
                
                Spacer()
                
                // Main content
                VStack(spacing: 40) {
                    // Main message
                    VStack(spacing: 16) {
                        Text("I'm feeling")
                            .font(UnbindTypography.headlineSystem)
                            .foregroundColor(.unbindInk.opacity(0.5))
                            .opacity(textOpacity)
                        
                        Text("something")
                            .font(UnbindTypography.largeTitleSystem)
                            .foregroundColor(.unbindInk)
                            .opacity(textOpacity)
                    }
                    .animation(.unbindSoft.delay(0.2), value: textOpacity)
                    
                    // Breathing indicator
                    Circle()
                        .fill(Color.unbindRose.opacity(0.3))
                        .frame(width: 80, height: 80)
                        .scaleEffect(breatheAnimation ? 1.15 : 1.0)
                        .opacity(breatheAnimation ? 0.6 : 0.4)
                        .animation(.unbindBreath, value: breatheAnimation)
                    
                    // Release button
                    Button(action: {
                        showReleaseFlow = true
                    }) {
                        Text("Release Now")
                            .font(UnbindTypography.bodySystem)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(width: 200)
                            .padding(.vertical, 20)
                            .background(Color.unbindClay)
                            .cornerRadius(20)
                            .shadow(color: Color.unbindClay.opacity(0.3), radius: 12, x: 0, y: 6)
                    }
                    .scaleEffect(buttonScale)
                    .animation(.unbindSpring.delay(0.4), value: buttonScale)
                }
                
                Spacer()
                
                // Bottom navigation to Morning/Evening
                HStack(spacing: 24) {
                    // Morning Reset
                    FlowEntryButton(
                        title: "Morning",
                        subtitle: "Reset",
                        isCompleted: userState.morningCompletedToday,
                        style: .morning
                    ) {
                        showMorningReset = true
                    }
                    
                    // Evening Unwind
                    FlowEntryButton(
                        title: "Evening",
                        subtitle: "Unwind",
                        isCompleted: userState.eveningCompletedToday,
                        style: .evening
                    ) {
                        showEveningUnwind = true
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation {
                textOpacity = 1
                buttonScale = 1
                breatheAnimation = true
            }
        }
        .fullScreenCover(isPresented: $showReleaseFlow) {
            ReleaseFlowView()
                .environmentObject(userState)
        }
        .fullScreenCover(isPresented: $showMorningReset) {
            MorningResetView()
                .environmentObject(userState)
        }
        .fullScreenCover(isPresented: $showEveningUnwind) {
            EveningUnwindView()
                .environmentObject(userState)
        }
        .fullScreenCover(isPresented: $showProgress) {
            JourneyProgressView()
                .environmentObject(userState)
        }
    }
}

// MARK: - Flow Entry Button
struct FlowEntryButton: View {
    let title: String
    let subtitle: String
    let isCompleted: Bool
    let style: FlowStyle
    let action: () -> Void
    
    enum FlowStyle {
        case morning, evening
        
        var gradient: LinearGradient {
            switch self {
            case .morning:
                return LinearGradient(
                    colors: [Color.unbindDawn, Color.unbindMorningSage.opacity(0.5)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .evening:
                return LinearGradient(
                    colors: [Color.unbindDusk.opacity(0.8), Color.unbindNightRose.opacity(0.4)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
        
        var textColor: Color {
            switch self {
            case .morning: return .unbindInk
            case .evening: return .white
            }
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                HStack {
                    Text(title)
                        .font(UnbindTypography.bodySystem)
                        .fontWeight(.medium)
                    
                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(style == .morning ? .unbindSage : .unbindRose)
                    }
                }
                
                Text(subtitle)
                    .font(UnbindTypography.seedSystem)
                    .fontWeight(.regular)
                    .opacity(0.7)
            }
            .foregroundColor(style.textColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(style.gradient)
            .cornerRadius(16)
            .shadow(color: Color.unbindSoftShadow, radius: 8, x: 0, y: 4)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Streak Light (Progress Button)
struct StreakLight: View {
    let streak: Int
    
    var glowIntensity: Double {
        min(Double(streak) * 0.1, 1.0)
    }
    
    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(Color.unbindSage.opacity(glowIntensity * 0.3))
                .frame(width: 48, height: 48)
                .blur(radius: 8)
            
            // Inner circle
            Circle()
                .fill(streak > 0 ? Color.unbindSage : Color.unbindMist)
                .frame(width: 36, height: 36)
            
            // Subtle shine
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.3), Color.clear],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: 18
                    )
                )
                .frame(width: 36, height: 36)
            
            // Progress icon
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(streak > 0 ? .white : .unbindInk.opacity(0.5))
        }
    }
}

// MARK: - Scale Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.unbindFade, value: configuration.isPressed)
    }
}

#Preview {
    HomeView()
        .environmentObject(UserState())
}

