//
//  UnbindTheme.swift
//  Unbind
//
//  Design System: Colors, Typography, Animations
//

import SwiftUI
import UIKit

// MARK: - Font Registration
class FontLoader {
    static let shared = FontLoader()
    private var fontsRegistered = false
    
    func registerFonts() {
        guard !fontsRegistered else { return }
        fontsRegistered = true
        
        let fontNames = [
            "Nunito-Regular",
            "Nunito-Medium", 
            "Nunito-SemiBold",
            "Nunito-Bold"
        ]
        
        for fontName in fontNames {
            registerFont(named: fontName)
        }
    }
    
    private func registerFont(named name: String) {
        guard let fontURL = Bundle.main.url(forResource: name, withExtension: "ttf"),
              let fontDataProvider = CGDataProvider(url: fontURL as CFURL),
              let font = CGFont(fontDataProvider) else {
            return
        }
        
        var error: Unmanaged<CFError>?
        CTFontManagerRegisterGraphicsFont(font, &error)
    }
}

// MARK: - Color Palette
extension Color {
    // Primary naturfarver
    static let unbindSand = Color(red: 0.96, green: 0.93, blue: 0.88)
    static let unbindClay = Color(red: 0.78, green: 0.65, blue: 0.54)
    static let unbindRose = Color(red: 0.91, green: 0.78, blue: 0.76)
    static let unbindSage = Color(red: 0.72, green: 0.78, blue: 0.71)
    static let unbindInk = Color(red: 0.22, green: 0.21, blue: 0.20)
    
    // Background gradients
    static let unbindWarmWhite = Color(red: 0.98, green: 0.96, blue: 0.93)
    static let unbindSoftCream = Color(red: 0.97, green: 0.94, blue: 0.90)
    
    // Accents
    static let unbindMist = Color(red: 0.88, green: 0.90, blue: 0.91).opacity(0.6)
    static let unbindSoftShadow = Color.black.opacity(0.04)
    
    // Evening palette
    static let unbindDusk = Color(red: 0.28, green: 0.27, blue: 0.35)
    static let unbindNightRose = Color(red: 0.65, green: 0.52, blue: 0.55)
    static let unbindDeepSage = Color(red: 0.45, green: 0.52, blue: 0.48)
    
    // Morning palette
    static let unbindDawn = Color(red: 0.98, green: 0.92, blue: 0.85)
    static let unbindMorningSage = Color(red: 0.82, green: 0.86, blue: 0.80)
}

// MARK: - Gradients
extension LinearGradient {
    static let unbindBackground = LinearGradient(
        colors: [Color.unbindWarmWhite, Color.unbindSoftCream],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let unbindMorning = LinearGradient(
        colors: [Color.unbindDawn, Color.unbindMorningSage.opacity(0.3)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let unbindEvening = LinearGradient(
        colors: [Color.unbindDusk, Color.unbindNightRose.opacity(0.4)],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let unbindRelease = LinearGradient(
        colors: [Color.unbindSand, Color.unbindRose.opacity(0.3)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Typography
struct UnbindTypography {
    // Check if Nunito is available, otherwise use system rounded
    private static var nunitoAvailable: Bool {
        UIFont(name: "Nunito-Regular", size: 12) != nil
    }
    
    // Font helpers with fallback
    private static func nunitoFont(weight: Font.Weight, size: CGFloat) -> Font {
        let fontName: String
        switch weight {
        case .bold:
            fontName = "Nunito-Bold"
        case .semibold:
            fontName = "Nunito-SemiBold"
        case .medium:
            fontName = "Nunito-Medium"
        default:
            fontName = "Nunito-Regular"
        }
        
        if UIFont(name: fontName, size: size) != nil {
            return Font.custom(fontName, size: size)
        } else {
            return Font.system(size: size, weight: weight, design: .rounded)
        }
    }
    
    // Headlines
    static var largeTitleSystem: Font {
        nunitoFont(weight: .semibold, size: 32)
    }
    
    static var titleSystem: Font {
        nunitoFont(weight: .semibold, size: 28)
    }
    
    static var headlineSystem: Font {
        nunitoFont(weight: .medium, size: 24)
    }
    
    // Body
    static var bodySystem: Font {
        nunitoFont(weight: .regular, size: 18)
    }
    
    static var bodyMediumSystem: Font {
        nunitoFont(weight: .medium, size: 18)
    }
    
    static var captionSystem: Font {
        nunitoFont(weight: .regular, size: 16)
    }
    
    static var smallSystem: Font {
        nunitoFont(weight: .regular, size: 14)
    }
    
    // Seed text - slightly larger for emphasis
    static var seedSystem: Font {
        nunitoFont(weight: .regular, size: 20)
    }
}

// MARK: - Animation Curves
extension Animation {
    static let unbindSoft = Animation.easeInOut(duration: 0.35)
    static let unbindFade = Animation.easeInOut(duration: 0.25)
    static let unbindSlow = Animation.easeInOut(duration: 0.45)
    static let unbindSpring = Animation.spring(response: 0.4, dampingFraction: 0.75)
    static let unbindBreath = Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true)
    
    // Staggered animations
    static func unbindStagger(index: Int) -> Animation {
        Animation.easeOut(duration: 0.3).delay(Double(index) * 0.12)
    }
}

// MARK: - View Modifiers
struct UnbindCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(24)
            .background(Color.white.opacity(0.7))
            .cornerRadius(20)
            .shadow(color: Color.unbindSoftShadow, radius: 12, x: 0, y: 4)
    }
}

struct UnbindButtonStyle: ButtonStyle {
    var isPrimary: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(UnbindTypography.bodySystem)
            .foregroundColor(isPrimary ? .white : .unbindInk)
            .padding(.horizontal, 32)
            .padding(.vertical, 18)
            .background(
                isPrimary ? Color.unbindClay : Color.white.opacity(0.8)
            )
            .cornerRadius(16)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.unbindFade, value: configuration.isPressed)
            .shadow(color: Color.unbindSoftShadow, radius: 8, x: 0, y: 4)
    }
}

struct UnbindSelectionStyle: ViewModifier {
    var isSelected: Bool
    
    func body(content: Content) -> some View {
        content
            .font(UnbindTypography.bodySystem)
            .foregroundColor(isSelected ? .white : .unbindInk)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(isSelected ? Color.unbindClay : Color.white.opacity(0.6))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.clear : Color.unbindClay.opacity(0.3), lineWidth: 1)
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.unbindSpring, value: isSelected)
    }
}

// MARK: - View Extensions
extension View {
    func unbindCard() -> some View {
        modifier(UnbindCardStyle())
    }
    
    func unbindSelection(isSelected: Bool) -> some View {
        modifier(UnbindSelectionStyle(isSelected: isSelected))
    }
    
    func fadeInUp(delay: Double = 0) -> some View {
        self
            .transition(.asymmetric(
                insertion: .opacity.combined(with: .move(edge: .bottom)),
                removal: .opacity
            ))
            .animation(.unbindSoft.delay(delay), value: UUID())
    }
}

// MARK: - Ambient Background
struct AmbientBackground: View {
    @State private var animateGradient = false
    var style: BackgroundStyle = .day
    
    enum BackgroundStyle {
        case day, morning, evening
    }
    
    var body: some View {
        ZStack {
            // Base gradient
            gradient
                .ignoresSafeArea()
            
            // Soft mist overlay
            Circle()
                .fill(Color.unbindMist)
                .frame(width: 400, height: 400)
                .blur(radius: 100)
                .offset(x: animateGradient ? 50 : -50, y: animateGradient ? -100 : -150)
                .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: animateGradient)
            
            Circle()
                .fill(Color.unbindRose.opacity(0.1))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: animateGradient ? -80 : 80, y: animateGradient ? 200 : 150)
                .animation(.easeInOut(duration: 10).repeatForever(autoreverses: true), value: animateGradient)
        }
        .onAppear {
            animateGradient = true
        }
    }
    
    var gradient: LinearGradient {
        switch style {
        case .day:
            return .unbindBackground
        case .morning:
            return .unbindMorning
        case .evening:
            return .unbindEvening
        }
    }
}

#Preview {
    ZStack {
        AmbientBackground(style: .day)
        
        VStack(spacing: 24) {
            Text("Unbind")
                .font(UnbindTypography.largeTitleSystem)
                .foregroundColor(.unbindInk)
            
            Text("Let go of inner pressure")
                .font(UnbindTypography.bodySystem)
                .foregroundColor(.unbindInk.opacity(0.7))
            
            Button("Release Now") {}
                .buttonStyle(UnbindButtonStyle())
        }
    }
}
