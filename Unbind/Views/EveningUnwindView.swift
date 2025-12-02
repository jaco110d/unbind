//
//  EveningUnwindView.swift
//  Unbind
//
//  Evening Unwind Flow - 1-2 minutes
//

import SwiftUI

struct EveningUnwindView: View {
    @EnvironmentObject var userState: UserState
    @Environment(\.dismiss) var dismiss
    
    @State private var currentStep: EveningStep = .weather
    @State private var selectedWeather: InnerWeather?
    @State private var showContent = false
    
    enum EveningStep: Int, CaseIterable {
        case weather = 0
        case release = 1
        case seed = 2
    }
    
    var body: some View {
        ZStack {
            AmbientBackground(style: .evening)
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                            .frame(width: 44, height: 44)
                    }
                    
                    Spacer()
                    
                    Text("Evening Unwind")
                        .font(UnbindTypography.bodySystem)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Spacer().frame(width: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // Progress
                HStack(spacing: 8) {
                    ForEach(0..<EveningStep.allCases.count, id: \.self) { index in
                        Capsule()
                            .fill(index <= currentStep.rawValue ? Color.unbindNightRose : Color.unbindNightRose.opacity(0.3))
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
                        EveningWeatherStep(selected: $selectedWeather, showContent: showContent) {
                            advanceStep()
                        }
                    case .release:
                        EveningReleaseStep(weather: selectedWeather, showContent: showContent) {
                            advanceStep()
                        }
                    case .seed:
                        EveningSeedStep(seed: userState.todaysSeed, showContent: showContent) {
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
                if let nextStep = EveningStep(rawValue: currentStep.rawValue + 1) {
                    currentStep = nextStep
                }
                showContent = true
            }
        }
    }
    
    private func completeFlow() {
        userState.completeEvening(weather: selectedWeather)
        dismiss()
    }
}

// MARK: - Evening Weather Step
struct EveningWeatherStep: View {
    @Binding var selected: InnerWeather?
    let showContent: Bool
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            VStack(spacing: 8) {
                Text("Good evening")
                    .font(UnbindTypography.headlineSystem)
                    .foregroundColor(.white.opacity(0.7))
                
                Text("How did the day feel?")
                    .font(UnbindTypography.titleSystem)
                    .foregroundColor(.white)
            }
            .opacity(showContent ? 1 : 0)
            
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
                        .foregroundColor(selected == weather ? .unbindDusk : .white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 18)
                        .background(selected == weather ? Color.unbindNightRose : Color.white.opacity(0.1))
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

// MARK: - Evening Release Step
struct EveningReleaseStep: View {
    let weather: InnerWeather?
    let showContent: Bool
    let onNext: () -> Void
    
    @State private var showText = false
    @State private var showButton = false
    @State private var breatheScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 48) {
            // Breathing circle
            ZStack {
                Circle()
                    .fill(Color.unbindNightRose.opacity(0.2))
                    .frame(width: 100, height: 100)
                    .scaleEffect(breatheScale)
                
                Circle()
                    .fill(Color.unbindNightRose.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .scaleEffect(breatheScale * 0.9)
            }
            .opacity(showContent ? 1 : 0)
            
            // Release text
            Text(SeedContent.randomEveningReflection())
                .font(UnbindTypography.seedSystem)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(10)
                .padding(.horizontal, 32)
                .opacity(showText ? 1 : 0)
            
            // Mini softening
            Text("Let your shoulders drop.\nLet your jaw soften.\nLet the day go.")
                .font(UnbindTypography.bodySystem)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .opacity(showText ? 1 : 0)
                .animation(.unbindSlow.delay(1), value: showText)
            
            Button(action: onNext) {
                Text("Continue")
                    .font(UnbindTypography.bodySystem)
                    .fontWeight(.medium)
                    .foregroundColor(.unbindNightRose)
            }
            .opacity(showButton ? 1 : 0)
        }
        .onAppear {
            startBreathing()
            withAnimation(.unbindSlow.delay(0.5)) {
                showText = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                withAnimation(.unbindSoft) {
                    showButton = true
                }
            }
        }
    }
    
    private func startBreathing() {
        withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
            breatheScale = 1.15
        }
    }
}

// MARK: - Evening Seed Step
struct EveningSeedStep: View {
    let seed: Seed
    let showContent: Bool
    let onComplete: () -> Void
    
    @State private var showSeed = false
    @State private var showButton = false
    
    var body: some View {
        VStack(spacing: 48) {
            Text("A thought for rest")
                .font(UnbindTypography.bodySystem)
                .foregroundColor(.white.opacity(0.6))
                .opacity(showSeed ? 1 : 0)
            
            Text(seed.text)
                .font(UnbindTypography.seedSystem)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(10)
                .padding(.horizontal, 32)
                .opacity(showSeed ? 1 : 0)
                .animation(.unbindSlow.delay(0.3), value: showSeed)
            
            Button(action: onComplete) {
                Text("Rest well")
                    .font(UnbindTypography.bodySystem)
                    .fontWeight(.medium)
                    .foregroundColor(.unbindDusk)
                    .frame(width: 160)
                    .padding(.vertical, 18)
                    .background(Color.unbindNightRose)
                    .cornerRadius(16)
            }
            .opacity(showButton ? 1 : 0)
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
    EveningUnwindView()
        .environmentObject(UserState())
}

