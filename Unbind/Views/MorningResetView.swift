//
//  MorningResetView.swift
//  Unbind
//
//  Morning Reset Flow - ~1 minute
//

import SwiftUI

struct MorningResetView: View {
    @EnvironmentObject var userState: UserState
    @Environment(\.dismiss) var dismiss
    
    @State private var currentStep: MorningStep = .weather
    @State private var selectedWeather: InnerWeather?
    @State private var showContent = false
    
    enum MorningStep: Int, CaseIterable {
        case weather = 0
        case grounding = 1
        case seed = 2
    }
    
    var body: some View {
        ZStack {
            AmbientBackground(style: .morning)
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.unbindInk.opacity(0.5))
                            .frame(width: 44, height: 44)
                    }
                    
                    Spacer()
                    
                    Text("Morning Reset")
                        .font(UnbindTypography.bodySystem)
                        .foregroundColor(.unbindInk.opacity(0.7))
                    
                    Spacer()
                    
                    // Balance the close button
                    Spacer().frame(width: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // Progress indicator
                HStack(spacing: 8) {
                    ForEach(0..<MorningStep.allCases.count, id: \.self) { index in
                        Capsule()
                            .fill(index <= currentStep.rawValue ? Color.unbindSage : Color.unbindSage.opacity(0.2))
                            .frame(height: 4)
                            .animation(.unbindSoft, value: currentStep)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.top, 24)
                
                Spacer()
                
                // Content
                Group {
                    switch currentStep {
                    case .weather:
                        WeatherSelectionStep(selected: $selectedWeather, showContent: showContent) {
                            advanceStep()
                        }
                    case .grounding:
                        GroundingStep(weather: selectedWeather, showContent: showContent) {
                            advanceStep()
                        }
                    case .seed:
                        MorningSeedStep(seed: userState.todaysSeed, showContent: showContent) {
                            completeFlow()
                        }
                    }
                }
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .trailing)),
                    removal: .opacity.combined(with: .move(edge: .leading))
                ))
                
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.unbindSoft.delay(0.2)) {
                showContent = true
            }
        }
    }
    
    private func advanceStep() {
        withAnimation(.unbindSoft) {
            showContent = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.unbindSoft) {
                if let nextStep = MorningStep(rawValue: currentStep.rawValue + 1) {
                    currentStep = nextStep
                }
                showContent = true
            }
        }
    }
    
    private func completeFlow() {
        userState.completeMorning(weather: selectedWeather)
        dismiss()
    }
}

// MARK: - Weather Selection Step
struct WeatherSelectionStep: View {
    @Binding var selected: InnerWeather?
    let showContent: Bool
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            // Title
            VStack(spacing: 8) {
                Text("Good morning")
                    .font(UnbindTypography.headlineSystem)
                    .foregroundColor(.unbindInk.opacity(0.6))
                
                Text("How's your inner weather?")
                    .font(UnbindTypography.titleSystem)
                    .foregroundColor(.unbindInk)
            }
            .opacity(showContent ? 1 : 0)
            .animation(.unbindSoft, value: showContent)
            
            // Weather options
            VStack(spacing: 12) {
                ForEach(Array(InnerWeather.allCases.enumerated()), id: \.element.id) { index, weather in
                    Button(action: {
                        withAnimation(.unbindSpring) {
                            selected = weather
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            onNext()
                        }
                    }) {
                        HStack(spacing: 16) {
                            Text(weather.emoji)
                                .font(.system(size: 24))
                            
                            Text(weather.rawValue)
                                .font(UnbindTypography.bodySystem)
                            
                            Spacer()
                        }
                        .foregroundColor(selected == weather ? .white : .unbindInk)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 18)
                        .background(selected == weather ? Color.unbindSage : Color.white.opacity(0.6))
                        .cornerRadius(14)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .opacity(showContent ? 1 : 0)
                    .animation(.unbindStagger(index: index), value: showContent)
                }
            }
            .padding(.horizontal, 32)
        }
    }
}

// MARK: - Grounding Step
struct GroundingStep: View {
    let weather: InnerWeather?
    let showContent: Bool
    let onNext: () -> Void
    
    @State private var showMessage = false
    @State private var showGrounding = false
    @State private var showButton = false
    
    var body: some View {
        VStack(spacing: 40) {
            // Weather acknowledgment
            if let weather = weather {
                Text(weather.message)
                    .font(UnbindTypography.bodySystem)
                    .foregroundColor(.unbindInk.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .opacity(showMessage ? 1 : 0)
                    .animation(.unbindSoft, value: showMessage)
            }
            
            // Grounding text
            Text(SeedContent.randomMorningGrounding())
                .font(UnbindTypography.seedSystem)
                .foregroundColor(.unbindInk)
                .multilineTextAlignment(.center)
                .lineSpacing(10)
                .padding(.horizontal, 32)
                .opacity(showGrounding ? 1 : 0)
                .animation(.unbindSlow, value: showGrounding)
            
            // Continue button
            Button(action: onNext) {
                Text("Continue")
                    .font(UnbindTypography.bodySystem)
                    .fontWeight(.medium)
                    .foregroundColor(.unbindSage)
            }
            .opacity(showButton ? 1 : 0)
            .animation(.unbindSoft, value: showButton)
        }
        .onAppear {
            withAnimation(.unbindSoft.delay(0.3)) {
                showMessage = true
            }
            withAnimation(.unbindSlow.delay(1)) {
                showGrounding = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.unbindSoft) {
                    showButton = true
                }
            }
        }
    }
}

// MARK: - Morning Seed Step
struct MorningSeedStep: View {
    let seed: Seed
    let showContent: Bool
    let onComplete: () -> Void
    
    @State private var showSeed = false
    @State private var showButton = false
    
    var body: some View {
        VStack(spacing: 48) {
            // Intro
            Text("Your seed for today")
                .font(UnbindTypography.bodySystem)
                .foregroundColor(.unbindInk.opacity(0.6))
                .opacity(showSeed ? 1 : 0)
            
            // Seed text
            Text(seed.text)
                .font(UnbindTypography.seedSystem)
                .foregroundColor(.unbindInk)
                .multilineTextAlignment(.center)
                .lineSpacing(10)
                .padding(.horizontal, 32)
                .opacity(showSeed ? 1 : 0)
                .animation(.unbindSlow.delay(0.3), value: showSeed)
            
            // Done button
            Button(action: onComplete) {
                Text("Begin my day")
                    .font(UnbindTypography.bodySystem)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(width: 180)
                    .padding(.vertical, 18)
                    .background(Color.unbindSage)
                    .cornerRadius(16)
            }
            .opacity(showButton ? 1 : 0)
            .animation(.unbindSoft, value: showButton)
        }
        .onAppear {
            withAnimation(.unbindSlow.delay(0.5)) {
                showSeed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                withAnimation(.unbindSoft) {
                    showButton = true
                }
            }
        }
    }
}

#Preview {
    MorningResetView()
        .environmentObject(UserState())
}

