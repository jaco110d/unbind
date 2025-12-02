//
//  ReleaseFlowView.swift
//  Unbind
//
//  The main Release Flow - 5 steps, 1-2 minutes
//

import SwiftUI

struct ReleaseFlowView: View {
    @EnvironmentObject var userState: UserState
    @Environment(\.dismiss) var dismiss
    
    @State private var currentStep: ReleaseStep = .bodyLocation
    @State private var selectedBodyLocation: BodyLocation?
    @State private var selectedFeeling: FeelingQuality?
    @State private var selectedProtection: ProtectionLayer?
    @State private var softeningIndex = 0
    @State private var showContent = false
    
    enum ReleaseStep: Int, CaseIterable {
        case bodyLocation = 0
        case feelingQuality = 1
        case protection = 2
        case softening = 3
        case seed = 4
        
        var title: String {
            switch self {
            case .bodyLocation: return "Where in your body?"
            case .feelingQuality: return "How does it feel?"
            case .protection: return "What is it protecting you from?"
            case .softening: return ""
            case .seed: return ""
            }
        }
        
        var subtitle: String {
            switch self {
            case .bodyLocation: return "Locate the sensation"
            case .feelingQuality: return "Name the feeling"
            case .protection: return "Acknowledge the layer"
            case .softening: return ""
            case .seed: return ""
            }
        }
    }
    
    var body: some View {
        ZStack {
            AmbientBackground(style: .day)
            
            VStack(spacing: 0) {
                // Close button
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.unbindInk.opacity(0.5))
                            .frame(width: 44, height: 44)
                    }
                    Spacer()
                    
                    // Progress dots
                    HStack(spacing: 8) {
                        ForEach(0..<ReleaseStep.allCases.count, id: \.self) { index in
                            Circle()
                                .fill(index <= currentStep.rawValue ? Color.unbindClay : Color.unbindClay.opacity(0.2))
                                .frame(width: 8, height: 8)
                                .animation(.unbindSoft, value: currentStep)
                        }
                    }
                    
                    Spacer()
                    Spacer().frame(width: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                Spacer()
                
                // Content area
                Group {
                    switch currentStep {
                    case .bodyLocation:
                        BodyLocationStep(selected: $selectedBodyLocation, showContent: showContent) {
                            advanceStep()
                        }
                    case .feelingQuality:
                        FeelingQualityStep(selected: $selectedFeeling, showContent: showContent) {
                            advanceStep()
                        }
                    case .protection:
                        ProtectionStep(selected: $selectedProtection, showContent: showContent) {
                            advanceStep()
                        }
                    case .softening:
                        SofteningStep(
                            bodyLocation: selectedBodyLocation,
                            protection: selectedProtection,
                            showContent: showContent
                        ) {
                            advanceStep()
                        }
                    case .seed:
                        SeedStep(seed: userState.todaysSeed, showContent: showContent) {
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
                if let nextStep = ReleaseStep(rawValue: currentStep.rawValue + 1) {
                    currentStep = nextStep
                }
                showContent = true
            }
        }
    }
    
    private func completeFlow() {
        userState.completeRelease()
        dismiss()
    }
}

// MARK: - Body Location Step
struct BodyLocationStep: View {
    @Binding var selected: BodyLocation?
    let showContent: Bool
    let onNext: () -> Void
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(spacing: 32) {
            // Title
            VStack(spacing: 8) {
                Text("Where in your body?")
                    .font(UnbindTypography.titleSystem)
                    .foregroundColor(.unbindInk)
                
                Text("Locate the sensation")
                    .font(UnbindTypography.bodySystem)
                    .foregroundColor(.unbindInk.opacity(0.6))
            }
            .opacity(showContent ? 1 : 0)
            .animation(.unbindSoft, value: showContent)
            
            // Options grid
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(Array(BodyLocation.allCases.enumerated()), id: \.element.id) { index, location in
                    SelectionCard(
                        title: location.rawValue,
                        icon: location.icon,
                        isSelected: selected == location
                    ) {
                        withAnimation(.unbindSpring) {
                            selected = location
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onNext()
                        }
                    }
                    .opacity(showContent ? 1 : 0)
                    .animation(.unbindStagger(index: index), value: showContent)
                }
            }
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - Feeling Quality Step
struct FeelingQualityStep: View {
    @Binding var selected: FeelingQuality?
    let showContent: Bool
    let onNext: () -> Void
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 8) {
                Text("How does it feel?")
                    .font(UnbindTypography.titleSystem)
                    .foregroundColor(.unbindInk)
                
                Text("Name the feeling")
                    .font(UnbindTypography.bodySystem)
                    .foregroundColor(.unbindInk.opacity(0.6))
            }
            .opacity(showContent ? 1 : 0)
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(Array(FeelingQuality.allCases.enumerated()), id: \.element.id) { index, feeling in
                    SelectionCard(
                        title: feeling.rawValue,
                        subtitle: feeling.description,
                        isSelected: selected == feeling
                    ) {
                        withAnimation(.unbindSpring) {
                            selected = feeling
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onNext()
                        }
                    }
                    .opacity(showContent ? 1 : 0)
                    .animation(.unbindStagger(index: index), value: showContent)
                }
            }
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - Protection Step
struct ProtectionStep: View {
    @Binding var selected: ProtectionLayer?
    let showContent: Bool
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 8) {
                Text("What is it protecting")
                    .font(UnbindTypography.titleSystem)
                    .foregroundColor(.unbindInk)
                Text("you from?")
                    .font(UnbindTypography.titleSystem)
                    .foregroundColor(.unbindInk)
                
                Text("Acknowledge the layer")
                    .font(UnbindTypography.bodySystem)
                    .foregroundColor(.unbindInk.opacity(0.6))
            }
            .opacity(showContent ? 1 : 0)
            
            VStack(spacing: 12) {
                ForEach(Array(ProtectionLayer.allCases.enumerated()), id: \.element.id) { index, protection in
                    Button(action: {
                        withAnimation(.unbindSpring) {
                            selected = protection
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onNext()
                        }
                    }) {
                        Text(protection.rawValue)
                            .unbindSelection(isSelected: selected == protection)
                    }
                    .opacity(showContent ? 1 : 0)
                    .animation(.unbindStagger(index: index), value: showContent)
                }
            }
            .padding(.horizontal, 32)
        }
    }
}

// MARK: - Softening Step
struct SofteningStep: View {
    let bodyLocation: BodyLocation?
    let protection: ProtectionLayer?
    let showContent: Bool
    let onNext: () -> Void
    
    @State private var instructionIndex = 0
    @State private var showInstruction = false
    @State private var breatheScale: CGFloat = 1.0
    
    let instructions: [String]
    
    init(bodyLocation: BodyLocation?, protection: ProtectionLayer?, showContent: Bool, onNext: @escaping () -> Void) {
        self.bodyLocation = bodyLocation
        self.protection = protection
        self.showContent = showContent
        self.onNext = onNext
        
        // Create personalized instructions
        var customInstructions: [String] = []
        
        if let location = bodyLocation {
            customInstructions.append("Bring your attention to your \(location.rawValue.lowercased()).\nJust notice. Don't change anything.")
        }
        
        customInstructions.append(SeedContent.randomSoftening())
        
        if let prot = protection {
            customInstructions.append(prot.softening)
        }
        
        customInstructions.append("Let it soften by 5%.\nJust 5%. That's enough.")
        customInstructions.append("Take one more breath.\nYou're doing beautifully.")
        
        self.instructions = customInstructions
    }
    
    var body: some View {
        VStack(spacing: 40) {
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
            .opacity(showContent ? 1 : 0)
            
            // Instruction text
            Text(instructions[instructionIndex])
                .font(UnbindTypography.seedSystem)
                .foregroundColor(.unbindInk)
                .multilineTextAlignment(.center)
                .lineSpacing(8)
                .padding(.horizontal, 40)
                .opacity(showInstruction ? 1 : 0)
                .animation(.unbindSlow, value: showInstruction)
            
            // Continue button (shows after reading)
            if instructionIndex < instructions.count - 1 {
                Button(action: nextInstruction) {
                    Text("Continue")
                        .font(UnbindTypography.bodySystem)
                        .foregroundColor(.unbindClay)
                }
                .opacity(showInstruction ? 1 : 0)
                .animation(.unbindSoft.delay(2), value: showInstruction)
            } else {
                Button(action: onNext) {
                    Text("I'm ready")
                        .font(UnbindTypography.bodySystem)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                        .background(Color.unbindClay)
                        .cornerRadius(16)
                }
                .opacity(showInstruction ? 1 : 0)
                .animation(.unbindSoft.delay(2), value: showInstruction)
            }
        }
        .onAppear {
            startBreathing()
            withAnimation(.unbindSlow.delay(0.5)) {
                showInstruction = true
            }
        }
    }
    
    private func startBreathing() {
        withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
            breatheScale = 1.2
        }
    }
    
    private func nextInstruction() {
        withAnimation(.unbindFade) {
            showInstruction = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            instructionIndex += 1
            withAnimation(.unbindSlow) {
                showInstruction = true
            }
        }
    }
}

// MARK: - Seed Step
struct SeedStep: View {
    let seed: Seed
    let showContent: Bool
    let onComplete: () -> Void
    
    @State private var showSeed = false
    @State private var showButton = false
    
    var body: some View {
        VStack(spacing: 48) {
            // Category label
            Text(seed.category.rawValue.uppercased())
                .font(.system(size: 12, weight: .medium))
                .tracking(2)
                .foregroundColor(.unbindClay.opacity(0.7))
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
                Text("Done")
                    .font(UnbindTypography.bodySystem)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(width: 160)
                    .padding(.vertical, 18)
                    .background(Color.unbindClay)
                    .cornerRadius(16)
            }
            .opacity(showButton ? 1 : 0)
            .animation(.unbindSoft.delay(5), value: showButton) // 5 second delay
        }
        .onAppear {
            withAnimation(.unbindSlow.delay(0.5)) {
                showSeed = true
            }
            // Button appears after 5 seconds (non-skippable seed)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showButton = true
            }
        }
    }
}

// MARK: - Selection Card
struct SelectionCard: View {
    let title: String
    var icon: String? = nil
    var subtitle: String? = nil
    var isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? .white : .unbindClay)
                }
                
                Text(title)
                    .font(UnbindTypography.bodySystem)
                    .fontWeight(.medium)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 12))
                        .opacity(0.7)
                }
            }
            .foregroundColor(isSelected ? .white : .unbindInk)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(isSelected ? Color.unbindClay : Color.white.opacity(0.6))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.unbindClay.opacity(isSelected ? 0 : 0.2), lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview {
    ReleaseFlowView()
        .environmentObject(UserState())
}

