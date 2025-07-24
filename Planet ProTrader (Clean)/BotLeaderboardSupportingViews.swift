//
//  BotLeaderboardSupportingViews.swift
//  Planet ProTrader (Clean)
//
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

// MARK: - Competition Detail View

struct CompetitionDetailView: View {
    let competition: BotCompetition
    let leaderboardManager: BotLeaderboardManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingJoinAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Competition header
                    competitionHeader
                    
                    // Competition stats
                    competitionStats
                    
                    // Rules section
                    rulesSection
                    
                    // Leaderboard section
                    leaderboardSection
                    
                    // Join button
                    if competition.status != .finished {
                        joinButton
                    }
                }
                .padding()
            }
            .navigationTitle(competition.name)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(DesignSystem.primaryGold)
                }
            }
        }
        .alert("Join Competition", isPresented: $showingJoinAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Join for \(String(format: "$%.0f", competition.entryFee))") {
                leaderboardManager.joinCompetition(competition.id, botId: UUID())
                HapticFeedbackManager.shared.competitionJoined()
                dismiss()
            }
        } message: {
            Text("Are you sure you want to join \(competition.name)?")
        }
    }
    
    private var competitionHeader: some View {
        VStack(spacing: 16) {
            // Competition type and status
            HStack {
                HStack(spacing: 8) {
                    Text(competition.competitionType.emoji)
                        .font(.title2)
                    
                    Text(competition.competitionType.displayName)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(competition.competitionType.color)
                }
                
                Spacer()
                
                Text(competition.status.displayName)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(competition.status.color)
                    .cornerRadius(12)
            }
            
            // Description
            Text(competition.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            // Time remaining
            if competition.status != .finished {
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.orange)
                    
                    Text(competition.timeRemaining)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
        .solarCard()
    }
    
    private var competitionStats: some View {
        HStack(spacing: 20) {
            statCard(
                title: "Prize Pool",
                value: "$\(Int(competition.prizePool))",
                icon: "dollarsign.circle.fill",
                color: DesignSystem.primaryGold
            )
            
            statCard(
                title: "Participants",
                value: "\(competition.currentParticipants)/\(competition.maxParticipants)",
                icon: "person.3.fill",
                color: .blue
            )
            
            statCard(
                title: "Entry Fee",
                value: "$\(Int(competition.entryFee))",
                icon: "creditcard.fill",
                color: .green
            )
        }
    }
    
    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var rulesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📋 Competition Rules")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(competition.rules.enumerated()), id: \.offset) { index, rule in
                    HStack(alignment: .top, spacing: 8) {
                        Text("\(index + 1).")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(DesignSystem.primaryGold)
                        
                        Text(rule)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .solarCard()
    }
    
    private var leaderboardSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🏆 Live Leaderboard")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            if competition.leaderboard.isEmpty {
                Text("Competition hasn't started yet")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                VStack(spacing: 8) {
                    ForEach(Array(competition.leaderboard.prefix(10).enumerated()), id: \.element.id) { index, entry in
                        leaderboardRow(entry, position: index + 1)
                    }
                }
            }
        }
        .solarCard()
    }
    
    private func leaderboardRow(_ entry: BotCompetitionEntry, position: Int) -> some View {
        HStack {
            // Rank
            Text("#\(position)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .frame(width: 30, alignment: .leading)
            
            // Bot name
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.botName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text("by \(entry.ownerName)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Performance
            VStack(alignment: .trailing, spacing: 2) {
                Text(entry.formattedProfitPercentage)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(entry.performanceColor)
                
                Text("\(Int(entry.winRate))% WR")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
    }
    
    private var joinButton: some View {
        Button(action: {
            showingJoinAlert = true
            HapticFeedbackManager.shared.impact(.medium)
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                
                Text("Join Competition")
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("$\(Int(competition.entryFee))")
                    .fontWeight(.bold)
            }
            .foregroundColor(.white)
            .padding()
            .background(
                LinearGradient(
                    colors: [DesignSystem.primaryGold, DesignSystem.primaryGold.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Join Competition View

struct JoinCompetitionView: View {
    let competitions: [BotCompetition]
    let leaderboardManager: BotLeaderboardManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCompetition: BotCompetition?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 12) {
                    Text("🚀 Join Competition")
                        .font(DesignSystem.Typography.largeTitle)
                        .goldText()
                    
                    Text("Choose a competition to participate in")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                // Available competitions
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(competitions) { competition in
                            competitionOption(competition)
                        }
                    }
                    .padding()
                }
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(DesignSystem.primaryGold)
                }
            }
        }
    }
    
    private func competitionOption(_ competition: BotCompetition) -> some View {
        Button(action: {
            selectedCompetition = competition
            leaderboardManager.joinCompetition(competition.id, botId: UUID())
            HapticFeedbackManager.shared.competitionJoined()
            dismiss()
        }) {
            HStack(spacing: 16) {
                // Competition icon
                ZStack {
                    Circle()
                        .fill(competition.competitionType.color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Text(competition.competitionType.emoji)
                        .font(.title2)
                }
                
                // Competition info
                VStack(alignment: .leading, spacing: 4) {
                    Text(competition.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(competition.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack {
                        Text("Prize: $\(Int(competition.prizePool))")
                            .font(.caption)
                            .foregroundColor(DesignSystem.primaryGold)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text("Fee: $\(Int(competition.entryFee))")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                
                Spacer()
                
                // Join indicator
                Image(systemName: "arrow.right.circle.fill")
                    .foregroundColor(competition.competitionType.color)
                    .font(.title2)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Scale Button Style

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview("Competition Detail") {
    CompetitionDetailView(
        competition: BotCompetition(
            name: "Flash Challenge",
            description: "Quick 1-hour trading competition",
            startDate: Date(),
            endDate: Date().addingTimeInterval(3600),
            prizePool: 5000,
            entryFee: 100,
            maxParticipants: 50,
            currentParticipants: 23,
            competitionType: .flash,
            status: .active,
            leaderboard: [],
            rules: ["Rule 1", "Rule 2", "Rule 3"]
        ),
        leaderboardManager: BotLeaderboardManager()
    )
}

#Preview("Join Competition") {
    JoinCompetitionView(
        competitions: [
            BotCompetition(
                name: "Flash Challenge",
                description: "Quick 1-hour trading competition",
                startDate: Date(),
                endDate: Date().addingTimeInterval(3600),
                prizePool: 5000,
                entryFee: 100,
                maxParticipants: 50,
                currentParticipants: 23,
                competitionType: .flash,
                status: .upcoming,
                leaderboard: [],
                rules: []
            )
        ],
        leaderboardManager: BotLeaderboardManager()
    )
}