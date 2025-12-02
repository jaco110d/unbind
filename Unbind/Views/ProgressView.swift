//
//  ProgressView.swift
//  Unbind
//
//  Your Journey - Progress over time
//

import SwiftUI

struct JourneyProgressView: View {
    @EnvironmentObject var userState: UserState
    @Environment(\.dismiss) var dismiss
    @State private var showContent = false
    
    var body: some View {
        ZStack {
            // Soft gradient background
            LinearGradient(
                colors: [Color.unbindWarmWhite, Color.unbindSand.opacity(0.3)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Subtle organic shapes
            Circle()
                .fill(Color.unbindSage.opacity(0.08))
                .frame(width: 300, height: 300)
                .blur(radius: 60)
                .offset(x: -100, y: -200)
                .ignoresSafeArea()
            
            Circle()
                .fill(Color.unbindRose.opacity(0.06))
                .frame(width: 250, height: 250)
                .blur(radius: 50)
                .offset(x: 120, y: 300)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Fixed Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.unbindInk.opacity(0.5))
                            .frame(width: 40, height: 40)
                            .background(Color.white.opacity(0.5))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("Your Journey")
                        .font(UnbindTypography.headlineSystem)
                        .foregroundColor(.unbindInk)
                    
                    Spacer()
                    
                    // Balance spacer
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 16)
                .opacity(showContent ? 1 : 0)
                
                // Scrollable content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Main stats summary
                        StatsOverviewCard(userState: userState)
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                            .animation(.unbindSoft.delay(0.1), value: showContent)
                        
                        // Weekly mood visualization
                        WeeklyMoodChart(checkIns: userState.getRecentCheckIns(days: 7))
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                            .animation(.unbindSoft.delay(0.2), value: showContent)
                        
                        // Check-in calendar view
                        CheckInCalendarCard(checkIns: userState.getRecentCheckIns(days: 14))
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                            .animation(.unbindSoft.delay(0.3), value: showContent)
                        
                        // Encouragement message
                        EncouragementCard(userState: userState)
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                            .animation(.unbindSoft.delay(0.4), value: showContent)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            withAnimation(.unbindSoft.delay(0.1)) {
                showContent = true
            }
        }
    }
}

// MARK: - Stats Overview Card
struct StatsOverviewCard: View {
    @ObservedObject var userState: UserState
    
    var body: some View {
        HStack(spacing: 0) {
            // Current streak
            StatItem(
                value: "\(userState.currentStreak)",
                label: "Day\nStreak",
                color: Color.unbindSage
            )
            
            Spacer()
            
            // Divider
            Rectangle()
                .fill(Color.unbindInk.opacity(0.08))
                .frame(width: 1, height: 50)
            
            Spacer()
            
            // Total check-ins
            StatItem(
                value: "\(userState.totalCheckIns)",
                label: "Check-\nins",
                color: Color.unbindClay
            )
            
            Spacer()
            
            // Divider
            Rectangle()
                .fill(Color.unbindInk.opacity(0.08))
                .frame(width: 1, height: 50)
            
            Spacer()
            
            // Release sessions
            StatItem(
                value: "\(userState.totalReleaseSessions)",
                label: "Releases",
                color: Color.unbindNightRose
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .background(Color.white.opacity(0.7))
        .cornerRadius(20)
        .shadow(color: Color.unbindSoftShadow, radius: 12, x: 0, y: 4)
    }
}

struct StatItem: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 52, height: 52)
                
                Text(value)
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundColor(color)
            }
            
            Text(label)
                .font(UnbindTypography.smallSystem)
                .foregroundColor(.unbindInk.opacity(0.6))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Weekly Mood Chart
struct WeeklyMoodChart: View {
    let checkIns: [DailyCheckIn]
    
    var reversedCheckIns: [DailyCheckIn] {
        Array(checkIns.reversed())
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Inner Weather")
                .font(UnbindTypography.bodyMediumSystem)
                .foregroundColor(.unbindInk)
            
            // Weather visualization
            HStack(spacing: 4) {
                ForEach(Array(reversedCheckIns.enumerated()), id: \.offset) { index, checkIn in
                    WeatherDayColumn(checkIn: checkIn, index: index)
                }
            }
            
            // Legend - wrap to two lines on small screens
            FlowLayout(spacing: 12) {
                LegendItem(emoji: "☀️", label: "Open")
                LegendItem(emoji: "☁️", label: "Soft")
                LegendItem(emoji: "🌤", label: "Neutral")
                LegendItem(emoji: "🌧", label: "Heavy")
                LegendItem(emoji: "⛈", label: "Tight")
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.7))
        .cornerRadius(20)
        .shadow(color: Color.unbindSoftShadow, radius: 12, x: 0, y: 4)
    }
}

// Simple flow layout for legend
struct FlowLayout: View {
    let spacing: CGFloat
    let content: [LegendItem]
    
    init(spacing: CGFloat = 8, @ViewBuilder content: () -> TupleView<(LegendItem, LegendItem, LegendItem, LegendItem, LegendItem)>) {
        self.spacing = spacing
        let tuple = content().value
        self.content = [tuple.0, tuple.1, tuple.2, tuple.3, tuple.4]
    }
    
    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<content.count, id: \.self) { index in
                content[index]
            }
        }
        .font(UnbindTypography.smallSystem)
        .foregroundColor(.unbindInk.opacity(0.5))
    }
}

struct WeatherDayColumn: View {
    let checkIn: DailyCheckIn
    let index: Int
    
    var dayLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return String(formatter.string(from: checkIn.date).prefix(1))
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(checkIn.date)
    }
    
    func weatherEmoji(_ weather: String?) -> String {
        guard let w = weather else { return "·" }
        switch w {
        case "Open": return "☀️"
        case "Soft": return "☁️"
        case "Neutral": return "🌤"
        case "Heavy": return "🌧"
        case "Tight": return "⛈"
        default: return "·"
        }
    }
    
    var body: some View {
        VStack(spacing: 6) {
            // Morning weather
            Text(weatherEmoji(checkIn.morningWeather))
                .font(.system(size: 14))
                .frame(height: 20)
            
            // Day divider
            Rectangle()
                .fill(Color.unbindInk.opacity(0.08))
                .frame(width: 20, height: 1)
            
            // Evening weather
            Text(weatherEmoji(checkIn.eveningWeather))
                .font(.system(size: 14))
                .frame(height: 20)
            
            // Day label
            Text(dayLabel)
                .font(.system(size: 11, weight: isToday ? .semibold : .regular))
                .foregroundColor(isToday ? .unbindSage : .unbindInk.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(isToday ? Color.unbindSage.opacity(0.1) : Color.clear)
        .cornerRadius(10)
    }
}

struct LegendItem: View {
    let emoji: String
    let label: String
    
    var body: some View {
        HStack(spacing: 3) {
            Text(emoji)
                .font(.system(size: 10))
            Text(label)
                .font(.system(size: 11))
        }
    }
}

// MARK: - Check-in Calendar Card
struct CheckInCalendarCard: View {
    let checkIns: [DailyCheckIn]
    
    var reversedCheckIns: [DailyCheckIn] {
        Array(checkIns.reversed())
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Check-in History")
                .font(UnbindTypography.bodyMediumSystem)
                .foregroundColor(.unbindInk)
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7), spacing: 6) {
                ForEach(reversedCheckIns, id: \.dateString) { checkIn in
                    CheckInDayCell(checkIn: checkIn)
                }
            }
            
            // Legend
            HStack(spacing: 16) {
                HStack(spacing: 5) {
                    Circle()
                        .fill(Color.unbindSage)
                        .frame(width: 8, height: 8)
                    Text("Both")
                        .font(.system(size: 11))
                }
                
                HStack(spacing: 5) {
                    Circle()
                        .fill(Color.unbindSage.opacity(0.4))
                        .frame(width: 8, height: 8)
                    Text("One")
                        .font(.system(size: 11))
                }
                
                HStack(spacing: 5) {
                    Circle()
                        .stroke(Color.unbindInk.opacity(0.2), lineWidth: 1)
                        .frame(width: 8, height: 8)
                    Text("None")
                        .font(.system(size: 11))
                }
            }
            .foregroundColor(.unbindInk.opacity(0.5))
        }
        .padding(20)
        .background(Color.white.opacity(0.7))
        .cornerRadius(20)
        .shadow(color: Color.unbindSoftShadow, radius: 12, x: 0, y: 4)
    }
}

struct CheckInDayCell: View {
    let checkIn: DailyCheckIn
    
    var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: checkIn.date)
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(checkIn.date)
    }
    
    var fillColor: Color {
        if checkIn.morningCompleted && checkIn.eveningCompleted {
            return Color.unbindSage
        } else if checkIn.morningCompleted || checkIn.eveningCompleted {
            return Color.unbindSage.opacity(0.4)
        }
        return Color.clear
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(fillColor)
                .frame(width: 32, height: 32)
            
            if !checkIn.morningCompleted && !checkIn.eveningCompleted {
                Circle()
                    .stroke(Color.unbindInk.opacity(0.1), lineWidth: 1)
                    .frame(width: 32, height: 32)
            }
            
            Text(dayNumber)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(
                    (checkIn.morningCompleted || checkIn.eveningCompleted) 
                        ? .white 
                        : .unbindInk.opacity(0.4)
                )
            
            // Today indicator
            if isToday {
                Circle()
                    .stroke(Color.unbindClay, lineWidth: 2)
                    .frame(width: 36, height: 36)
            }
        }
    }
}

// MARK: - Encouragement Card
struct EncouragementCard: View {
    @ObservedObject var userState: UserState
    
    var message: (title: String, body: String) {
        let streak = userState.currentStreak
        let checkIns = userState.totalCheckIns
        
        if streak == 0 && checkIns == 0 {
            return (
                "Your journey begins",
                "Every moment of awareness is a step toward freedom. Start with your first check-in."
            )
        } else if streak == 0 {
            return (
                "Welcome back",
                "Streaks come and go — what matters is that you're here now."
            )
        } else if streak == 1 {
            return (
                "A fresh start",
                "Today is day one. Each check-in plants a seed of awareness."
            )
        } else if streak < 7 {
            return (
                "Building momentum",
                "\(streak) days of showing up for yourself. Keep going."
            )
        } else if streak < 14 {
            return (
                "A week of presence",
                "Seven days of gentle attention. Your practice is growing."
            )
        } else if streak < 30 {
            return (
                "Deepening roots",
                "\(streak) days. What started as practice is becoming part of you."
            )
        } else {
            return (
                "A month of growth",
                "\(streak) days of learning to let go. You're transforming."
            )
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 24))
                .foregroundColor(.unbindSage.opacity(0.6))
            
            Text(message.title)
                .font(UnbindTypography.bodyMediumSystem)
                .foregroundColor(.unbindInk)
            
            Text(message.body)
                .font(UnbindTypography.captionSystem)
                .foregroundColor(.unbindInk.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [Color.unbindMorningSage.opacity(0.3), Color.unbindSage.opacity(0.15)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
    }
}

#Preview {
    JourneyProgressView()
        .environmentObject(UserState())
}
