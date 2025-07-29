//
//  BotTestimonial.swift
//  Planet ProTrader - Bot Testimonials
//
//  User reviews and testimonials for bots
//  Created by AI Assistant on 1/25/25.
//

import Foundation

struct BotTestimonial: Identifiable, Codable {
    let id = UUID()
    let username: String
    let userAvatar: String
    let botName: String
    let rating: Int
    let review: String
    let profit: String
    let tradingPeriod: String
    let verified: Bool
    let date: Date
    
    static let sampleTestimonials: [BotTestimonial] = [
        BotTestimonial(
            username: "CryptoKing2024",
            userAvatar: "👑",
            botName: "Marcus",
            rating: 5,
            review: "This bot made me $15,000 in just 3 months! Marcus is incredibly aggressive but knows when to pull back. Best investment I've ever made!",
            profit: "+$15,247",
            tradingPeriod: "3 months",
            verified: true,
            date: Date().addingTimeInterval(-7200)
        ),
        BotTestimonial(
            username: "WallStreetWoman",
            userAvatar: "👩‍💼",
            botName: "Dr. Sarah",
            rating: 5,
            review: "Dr. Sarah's conservative approach saved my portfolio during the market crash. Steady 8% monthly returns with minimal drawdown.",
            profit: "+$8,943",
            tradingPeriod: "6 months",
            verified: true,
            date: Date().addingTimeInterval(-14400)
        ),
        BotTestimonial(
            username: "DayTraderDan",
            userAvatar: "⚡",
            botName: "Rocket",
            rating: 4,
            review: "Rocket lives up to its name! Super fast execution and great for scalping. Made 200+ profitable trades this week alone.",
            profit: "+$5,672",
            tradingPeriod: "1 month",
            verified: true,
            date: Date().addingTimeInterval(-3600)
        ),
        BotTestimonial(
            username: "ForexMaster",
            userAvatar: "🎯",
            botName: "Gandalf",
            rating: 5,
            review: "Gandalf's pattern recognition is magical! It spotted trends I completely missed. This bot has ancient wisdom for sure.",
            profit: "+$12,100",
            tradingPeriod: "4 months",
            verified: true,
            date: Date().addingTimeInterval(-21600)
        ),
        BotTestimonial(
            username: "TechAnalyst",
            userAvatar: "🤓",
            botName: "Professor Lee",
            rating: 4,
            review: "Amazing algorithmic approach! Professor Lee's ML models are incredibly sophisticated. Perfect for quantitative trading.",
            profit: "+$9,856",
            tradingPeriod: "2 months",
            verified: true,
            date: Date().addingTimeInterval(-10800)
        ),
        BotTestimonial(
            username: "SmartMoney",
            userAvatar: "💎",
            botName: "Foxy",
            rating: 5,
            review: "Foxy's intuition is unreal! It makes trades that don't make sense at first, but always end up profitable. Pure genius!",
            profit: "+$18,420",
            tradingPeriod: "5 months",
            verified: true,
            date: Date().addingTimeInterval(-18000)
        ),
        BotTestimonial(
            username: "RiskManager",
            userAvatar: "🛡️",
            botName: "Captain Rebel",
            rating: 4,
            review: "Captain Rebel saved me during the last market downturn by going contrarian. When everyone was selling, it was buying!",
            profit: "+$7,231",
            tradingPeriod: "3 months",
            verified: true,
            date: Date().addingTimeInterval(-25200)
        ),
        BotTestimonial(
            username: "NewTrader2024",
            userAvatar: "🌱",
            botName: "Alex",
            rating: 5,
            review: "As a beginner, Alex taught me so much about trading while making money! The technical analysis explanations are incredible.",
            profit: "+$3,456",
            tradingPeriod: "6 weeks",
            verified: true,
            date: Date().addingTimeInterval(-5400)
        )
    ]
}