//
//  OnboardingView.swift
//  Unbind
//
//  Complete Onboarding Flow - 14 steps
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var userState: UserState
    @State private var currentStep: OnboardingStep = .welcome
    @State private var showContent = false
    
    // User selections during onboarding
    @State private var selectedFeelings: Set<String> = []
    @State private var selectedBodyAreas: Set<BodyLocation> = []
    @State private var selectedQualities: Set<FeelingQuality> = []
    
    enum OnboardingStep: Int, CaseIterable {
        case welcome = 0
        case notMeditation = 1
        case feelingCheck = 2
        case normalization = 3
        case tensionTruth = 4
        case bodyMapping = 5
        case feelingQualities = 6
        case protectionIntro = 7
        case microRelease = 8
        case whyBodyReacts = 9
        case weGuideYou = 10
        case whyThisWorks = 11
        case personalizedPlan = 12
        case ready = 13
    }
    
    var progress: CGFloat {
        CGFloat(currentStep.rawValue + 1) / CGFloat(OnboardingStep.allCases.count)
    }
    
    var body: some View {
        ZStack {
            AmbientBackground(style: .day)
            
            VStack(spacing: 0) {
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.unbindClay.opacity(0.15))
                            .frame(height: 3)
                        
                        Rectangle()
                            .fill(Color.unbindClay)
                            .frame(width: geometry.size.width * progress, height: 3)
                            .animation(.unbindSoft, value: progress)
                    }
                }
                .frame(height: 3)
                .padding(.horizontal, 40)
                .padding(.top, 60)
                
                Spacer()
                
                // Content
                Group {
                    switch currentStep {
                    case .welcome:
                        WelcomeStep(showContent: showContent, onNext: advanceStep)
                    case .notMeditation:
                        NotMeditationStep(showContent: showContent, onNext: advanceStep)
                    case .feelingCheck:
                        FeelingCheckStep(selected: $selectedFeelings, showContent: showContent, onNext: advanceStep)
                    case .normalization:
                        NormalizationStep(showContent: showContent, onNext: advanceStep)
                    case .tensionTruth:
                        TensionTruthStep(showContent: showContent, onNext: advanceStep)
                    case .bodyMapping:
                        BodyMappingStep(selected: $selectedBodyAreas, showContent: showContent, onNext: advanceStep)
                    case .feelingQualities:
                        FeelingQualitiesStep(selected: $selectedQualities, showContent: showContent, onNext: advanceStep)
                    case .protectionIntro:
                        ProtectionIntroStep(showContent: showContent, onNext: advanceStep)
                    case .microRelease:
                        MicroReleaseStep(showContent: showContent, onNext: advanceStep)
                    case .whyBodyReacts:
                        WhyBodyReactsStep(showContent: showContent, onNext: advanceStep)
                    case .weGuideYou:
                        WeGuideYouStep(showContent: showContent, onNext: advanceStep)
                    case .whyThisWorks:
                        WhyThisWorksStep(showContent: showContent, onNext: advanceStep)
                    case .personalizedPlan:
                        PersonalizedPlanStep(bodyAreas: selectedBodyAreas, showContent: showContent, onNext: advanceStep)
                    case .ready:
                        ReadyStep(showContent: showContent, onComplete: completeOnboarding)
                    }
                }
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .offset(x: 50)),
                    removal: .opacity.combined(with: .offset(x: -50))
                ))
                
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.unbindSoft.delay(0.3)) {
                showContent = true
            }
        }
    }
    
    private func advanceStep() {
        withAnimation(.unbindFade) {
            showContent = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation(.unbindSoft) {
                if let nextStep = OnboardingStep(rawValue: currentStep.rawValue + 1) {
                    currentStep = nextStep
                }
                showContent = true
            }
        }
    }
    
    private func completeOnboarding() {
        userState.hasCompletedOnboarding = true
    }
}

// MARK: - Step 1: Welcome
struct WelcomeStep: View {
    let showContent: Bool
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            VStack(spacing: 16) {
                Text("Welcome to")
                    .font(UnbindTypography.headlineSystem)
                    .foregroundColor(.unbindInk.opacity(0.6))
                
                Text("Unbind")
                    .font(.system(size: 48, weight: .medium, design: .rounded))
                    .foregroundColor(.unbindInk)
                
                Text("Let go of inner pressure —\ngently, quickly, in under two minutes.")
                    .font(UnbindTypography.bodySystem)
                    .foregroundColor(.unbindInk.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
            }
            .opacity(showContent ? 1 : 0)
            
            OnboardingButton(title: "Begin", action: onNext)
                .opacity(showContent ? 1 : 0)
                .animation(.unbindSoft.delay(0.3), value: showContent)
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Step 2: Not Meditation
struct NotMeditationStep: View {
    let showContent: Bool
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            VStack(spacing: 24) {
                Text("This is not meditation.")
                    .font(UnbindTypography.titleSystem)
                    .foregroundColor(.unbindInk)
                
                VStack(spacing: 16) {
                    CrossOutText("No clearing your mind")
                    CrossOutText("No sitting for 20 minutes")
                    CrossOutText("No journaling")
                    CrossOutText("No analyzing your thoughts")
                }
                
                Text("Just your body.\nJust 2 minutes.\nJust relief.")
                    .font(UnbindTypography.bodySystem)
                    .foregroundColor(.unbindInk.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.top, 8)
            }
            .opacity(showContent ? 1 : 0)
            
            OnboardingButton(title: "I'm curious", action: onNext)
                .opacity(showContent ? 1 : 0)
                .animation(.unbindSoft.delay(0.3), value: showContent)
        }
        .padding(.horizontal, 32)
    }
}

struct CrossOutText: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "xmark")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.unbindClay.opacity(0.6))
            
            Text(text)
                .font(UnbindTypography.bodySystem)
                .foregroundColor(.unbindInk.opacity(0.6))
        }
    }
}

// MARK: - Step 3: Feeling Check
struct FeelingCheckStep: View {
    @Binding var selected: Set<String>
    let showContent: Bool
    let onNext: () -> Void
    
    let feelings = [
        "Anxious or on edge",
        "A knot in my chest",
        "Overwhelmed by thoughts",
        "Stressed without knowing why",
        "Tension I can't shake",
        "Emotionally heavy"
    ]
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 8) {
                Text("Do you ever feel like this?")
                    .font(UnbindTypography.titleSystem)
                    .foregroundColor(.unbindInk)
                
                Text("Select all that apply")
                    .font(UnbindTypography.bodySystem)
                    .foregroundColor(.unbindInk.opacity(0.6))
            }
            .opacity(showContent ? 1 : 0)
            
            VStack(spacing: 10) {
                ForEach(Array(feelings.enumerated()), id: \.element) { index, feeling in
                    Button(action: {
                        withAnimation(.unbindSpring) {
                            if selected.contains(feeling) {
                                selected.remove(feeling)
                            } else {
                                selected.insert(feeling)
                            }
                        }
                    }) {
                        HStack {
                            Text(feeling)
                                .font(UnbindTypography.bodySystem)
                            Spacer()
                            if selected.contains(feeling) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .medium))
                            }
                        }
                        .foregroundColor(selected.contains(feeling) ? .white : .unbindInk)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .background(selected.contains(feeling) ? Color.unbindClay : Color.white.opacity(0.6))
                        .cornerRadius(12)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .opacity(showContent ? 1 : 0)
                    .animation(.unbindStagger(index: index), value: showContent)
                }
            }
            .padding(.horizontal, 24)
            
            if !selected.isEmpty {
                OnboardingButton(title: "Continue", action: onNext)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
    }
}

// MARK: - Step 4: Normalization
struct NormalizationStep: View {
    let showContent: Bool
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            VStack(spacing: 24) {
                Text("You're not broken.")
                    .font(UnbindTypography.titleSystem)
                    .foregroundColor(.unbindInk)
                
                Text("These feelings are signals.\nYour body is trying to tell you something.\n\nMost people try to think their way out.\nBut the answer isn't in your head —\nit's in your body.")
                    .font(UnbindTypography.bodySystem)
                    .foregroundColor(.unbindInk.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
            }
            .opacity(showContent ? 1 : 0)
            
            OnboardingButton(title: "Tell me more", action: onNext)
                .opacity(showContent ? 1 : 0)
                .animation(.unbindSoft.delay(0.3), value: showContent)
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Step 5: Tension Truth
struct TensionTruthStep: View {
    let showContent: Bool
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            VStack(spacing: 24) {
                Text("The truth about tension")
                    .font(UnbindTypography.titleSystem)
                    .foregroundColor(.unbindInk)
                
                Text("Every feeling you suppress\ngets stored in your body.\n\nThat tightness in your chest?\nThat knot in your stomach?\n\nIt's not random.\nIt's accumulated emotional pressure.")
                    .font(UnbindTypography.bodySystem)
                    .foregroundColor(.unbindInk.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
            }
            .opacity(showContent ? 1 : 0)
            
            OnboardingButton(title: "I feel this", action: onNext)
                .opacity(showContent ? 1 : 0)
                .animation(.unbindSoft.delay(0.3), value: showContent)
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Step 6: Body Mapping
struct BodyMappingStep: View {
    @Binding var selected: Set<BodyLocation>
    let showContent: Bool
    let onNext: () -> Void
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 8) {
                Text("Where do you feel it most?")
                    .font(UnbindTypography.titleSystem)
                    .foregroundColor(.unbindInk)
                
                Text("Select all that apply")
                    .font(UnbindTypography.bodySystem)
                    .foregroundColor(.unbindInk.opacity(0.6))
            }
            .opacity(showContent ? 1 : 0)
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(Array(BodyLocation.allCases.enumerated()), id: \.element.id) { index, location in
                    Button(action: {
                        withAnimation(.unbindSpring) {
                            if selected.contains(location) {
                                selected.remove(location)
                            } else {
                                selected.insert(location)
                            }
                        }
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: location.icon)
                                .font(.system(size: 24))
                            Text(location.rawValue)
                                .font(UnbindTypography.bodySystem)
                        }
                        .foregroundColor(selected.contains(location) ? .white : .unbindInk)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(selected.contains(location) ? Color.unbindClay : Color.white.opacity(0.6))
                        .cornerRadius(14)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .opacity(showContent ? 1 : 0)
                    .animation(.unbindStagger(index: index), value: showContent)
                }
            }
            .padding(.horizontal, 24)
            
            if !selected.isEmpty {
                OnboardingButton(title: "Continue", action: onNext)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
    }
}

// MARK: - Step 7: Feeling Qualities
struct FeelingQualitiesStep: View {
    @Binding var selected: Set<FeelingQuality>
    let showContent: Bool
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 8) {
                Text("How does it usually feel?")
                    .font(UnbindTypography.titleSystem)
                    .foregroundColor(.unbindInk)
                
                Text("Select all that apply")
                    .font(UnbindTypography.bodySystem)
                    .foregroundColor(.unbindInk.opacity(0.6))
            }
            .opacity(showContent ? 1 : 0)
            
            VStack(spacing: 10) {
                ForEach(Array(FeelingQuality.allCases.enumerated()), id: \.element.id) { index, quality in
                    Button(action: {
                        withAnimation(.unbindSpring) {
                            if selected.contains(quality) {
                                selected.remove(quality)
                            } else {
                                selected.insert(quality)
                            }
                        }
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(quality.rawValue)
                                    .font(UnbindTypography.bodySystem)
                                Text(quality.description)
                                    .font(.system(size: 14))
                                    .opacity(0.7)
                            }
                            Spacer()
                            if selected.contains(quality) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .medium))
                            }
                        }
                        .foregroundColor(selected.contains(quality) ? .white : .unbindInk)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .background(selected.contains(quality) ? Color.unbindClay : Color.white.opacity(0.6))
                        .cornerRadius(12)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .opacity(showContent ? 1 : 0)
                    .animation(.unbindStagger(index: index), value: showContent)
                }
            }
            .padding(.horizontal, 24)
            
            if !selected.isEmpty {
                OnboardingButton(title: "Continue", action: onNext)
            }
        }
    }
}

// MARK: - Step 8: Protection Intro
struct ProtectionIntroStep: View {
    let showContent: Bool
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            VStack(spacing: 24) {
                Text("These feelings are\nprotecting you")
                    .font(UnbindTypography.titleSystem)
                    .foregroundColor(.unbindInk)
                    .multilineTextAlignment(.center)
                
                Text("Every tension has a purpose.\n\nFear of rejection.\nFear of failure.\nFear of not being enough.\n\nYour body holds these to keep you safe.\nBut you don't have to carry them forever.")
                    .font(UnbindTypography.bodySystem)
                    .foregroundColor(.unbindInk.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
            }
            .opacity(showContent ? 1 : 0)
            
            OnboardingButton(title: "Show me how to release", action: onNext)
                .opacity(showContent ? 1 : 0)
                .animation(.unbindSoft.delay(0.3), value: showContent)
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Step 9: Micro Release Demo
struct MicroReleaseStep: View {
    let showContent: Bool
    let onNext: () -> Void
    
    @State private var showBreath = false
    @State private var showInstruction = false
    @State private var breatheScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 40) {
            Text("Let's try it right now")
                .font(UnbindTypography.titleSystem)
                .foregroundColor(.unbindInk)
                .opacity(showContent ? 1 : 0)
            
            // Breathing circle
            ZStack {
                Circle()
                    .fill(Color.unbindRose.opacity(0.2))
                    .frame(width: 120, height: 120)
                    .scaleEffect(breatheScale)
                
                Circle()
                    .fill(Color.unbindRose.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .scaleEffect(breatheScale * 0.9)
            }
            .opacity(showBreath ? 1 : 0)
            
            VStack(spacing: 16) {
                Text("Take a breath.\n\nNotice any tension in your body.\n\nNow let it soften — just 5%.\n\nThat's it. You're already releasing.")
                    .font(UnbindTypography.bodySystem)
                    .foregroundColor(.unbindInk.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
            }
            .opacity(showInstruction ? 1 : 0)
            
            OnboardingButton(title: "I felt that", action: onNext)
                .opacity(showInstruction ? 1 : 0)
                .animation(.unbindSoft.delay(3), value: showInstruction)
        }
        .padding(.horizontal, 32)
        .onAppear {
            withAnimation(.unbindSoft.delay(0.5)) {
                showBreath = true
            }
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true).delay(0.5)) {
                breatheScale = 1.2
            }
            withAnimation(.unbindSlow.delay(1)) {
                showInstruction = true
            }
        }
    }
}

// MARK: - Step 10: Why Body Reacts
struct WhyBodyReactsStep: View {
    let showContent: Bool
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            VStack(spacing: 24) {
                Text("Why your body reacts")
                    .font(UnbindTypography.titleSystem)
                    .foregroundColor(.unbindInk)
                
                Text("Your nervous system doesn't know\nthe difference between a tiger\nand an email from your boss.\n\nIt just knows: threat.\n\nAnd it tightens. Braces. Protects.\n\nUnbind teaches your body\nit's safe to let go.")
                    .font(UnbindTypography.bodySystem)
                    .foregroundColor(.unbindInk.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
            }
            .opacity(showContent ? 1 : 0)
            
            OnboardingButton(title: "Continue", action: onNext)
                .opacity(showContent ? 1 : 0)
                .animation(.unbindSoft.delay(0.3), value: showContent)
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Step 11: We Guide You
struct WeGuideYouStep: View {
    let showContent: Bool
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            VStack(spacing: 24) {
                Text("We guide you. Daily.")
                    .font(UnbindTypography.titleSystem)
                    .foregroundColor(.unbindInk)
                
                VStack(spacing: 20) {
                    TimeBlock(time: "Morning", title: "Reset", description: "Start your day grounded")
                    TimeBlock(time: "Anytime", title: "Release", description: "When you feel something arise")
                    TimeBlock(time: "Evening", title: "Unwind", description: "Let the day go")
                }
                .padding(.top, 8)
            }
            .opacity(showContent ? 1 : 0)
            
            OnboardingButton(title: "Continue", action: onNext)
                .opacity(showContent ? 1 : 0)
                .animation(.unbindSoft.delay(0.3), value: showContent)
        }
        .padding(.horizontal, 32)
    }
}

struct TimeBlock: View {
    let time: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Text(time)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.unbindClay)
                .frame(width: 70, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(UnbindTypography.bodySystem)
                    .fontWeight(.medium)
                    .foregroundColor(.unbindInk)
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.unbindInk.opacity(0.6))
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.white.opacity(0.6))
        .cornerRadius(12)
    }
}

// MARK: - Step 12: Why This Works
struct WhyThisWorksStep: View {
    let showContent: Bool
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            VStack(spacing: 24) {
                Text("Why this works")
                    .font(UnbindTypography.titleSystem)
                    .foregroundColor(.unbindInk)
                
                Text("When you stop fighting a feeling\nand simply allow it to exist —\nit starts to dissolve.\n\nThis is the science of somatic release.\n\nNo willpower needed.\nNo positive thinking.\nJust presence and permission.")
                    .font(UnbindTypography.bodySystem)
                    .foregroundColor(.unbindInk.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
            }
            .opacity(showContent ? 1 : 0)
            
            OnboardingButton(title: "Continue", action: onNext)
                .opacity(showContent ? 1 : 0)
                .animation(.unbindSoft.delay(0.3), value: showContent)
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Step 13: Personalized Plan
struct PersonalizedPlanStep: View {
    let bodyAreas: Set<BodyLocation>
    let showContent: Bool
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            VStack(spacing: 24) {
                Text("Your personalized path")
                    .font(UnbindTypography.titleSystem)
                    .foregroundColor(.unbindInk)
                
                VStack(spacing: 16) {
                    Text("Based on what you shared, Unbind will focus on helping you release tension in your:")
                        .font(UnbindTypography.bodySystem)
                        .foregroundColor(.unbindInk.opacity(0.7))
                        .multilineTextAlignment(.center)
                    
                    if !bodyAreas.isEmpty {
                        HStack(spacing: 12) {
                            ForEach(Array(bodyAreas).prefix(3), id: \.id) { area in
                                VStack(spacing: 6) {
                                    Image(systemName: area.icon)
                                        .font(.system(size: 20))
                                    Text(area.rawValue)
                                        .font(.system(size: 14))
                                }
                                .foregroundColor(.unbindClay)
                                .padding(12)
                                .background(Color.unbindClay.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                    }
                    
                    Text("In just 2 minutes a day,\nyou'll start feeling lighter.")
                        .font(UnbindTypography.bodySystem)
                        .foregroundColor(.unbindInk.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }
            }
            .opacity(showContent ? 1 : 0)
            
            OnboardingButton(title: "I'm ready", action: onNext)
                .opacity(showContent ? 1 : 0)
                .animation(.unbindSoft.delay(0.3), value: showContent)
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Step 14: Ready
struct ReadyStep: View {
    let showContent: Bool
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 48) {
            VStack(spacing: 24) {
                Text("You're ready to")
                    .font(UnbindTypography.headlineSystem)
                    .foregroundColor(.unbindInk.opacity(0.6))
                
                Text("Unbind")
                    .font(.system(size: 48, weight: .medium, design: .rounded))
                    .foregroundColor(.unbindInk)
                
                Text("Feel the difference in days —\nnot weeks.")
                    .font(UnbindTypography.bodySystem)
                    .foregroundColor(.unbindInk.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .opacity(showContent ? 1 : 0)
            
            OnboardingButton(title: "Start my journey", isPrimary: true, action: onComplete)
                .opacity(showContent ? 1 : 0)
                .animation(.unbindSoft.delay(0.3), value: showContent)
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Onboarding Button
struct OnboardingButton: View {
    let title: String
    var isPrimary: Bool = true
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(UnbindTypography.bodySystem)
                .fontWeight(.medium)
                .foregroundColor(isPrimary ? .white : .unbindClay)
                .padding(.horizontal, 48)
                .padding(.vertical, 18)
                .background(isPrimary ? Color.unbindClay : Color.clear)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isPrimary ? Color.clear : Color.unbindClay, lineWidth: 1.5)
                )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview {
    OnboardingView()
        .environmentObject(UserState())
}

