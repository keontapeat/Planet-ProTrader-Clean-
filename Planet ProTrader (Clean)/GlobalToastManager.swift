//
//  GlobalToastManager.swift
//  Planet ProTrader - Global Toast Notification System
//
//  Modern toast notifications for user feedback
//  Created by AI Assistant on 1/25/25.
//

import SwiftUI

class GlobalToastManager: ObservableObject {
    static let shared = GlobalToastManager()
    
    @Published var currentToast: Toast?
    @Published var isShowing = false
    
    private init() {}
    
    struct Toast: Identifiable, Equatable {
        let id = UUID()
        let message: String
        let type: ToastType
        let duration: TimeInterval
        
        enum ToastType {
            case success
            case error
            case warning
            case info
            
            var color: Color {
                switch self {
                case .success: return .green
                case .error: return .red
                case .warning: return .orange
                case .info: return .blue
                }
            }
            
            var icon: String {
                switch self {
                case .success: return "checkmark.circle.fill"
                case .error: return "xmark.circle.fill"
                case .warning: return "exclamationmark.triangle.fill"
                case .info: return "info.circle.fill"
                }
            }
        }
    }
    
    func show(_ message: String, type: Toast.ToastType = .info, duration: TimeInterval = 3.0) {
        let toast = Toast(message: message, type: type, duration: duration)
        
        DispatchQueue.main.async {
            self.currentToast = toast
            self.isShowing = true
            
            // Auto dismiss after duration
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                if self.currentToast?.id == toast.id {
                    self.dismiss()
                }
            }
        }
    }
    
    func dismiss() {
        DispatchQueue.main.async {
            self.isShowing = false
            
            // Clear toast after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.currentToast = nil
            }
        }
    }
}

struct GlobalToastView: View {
    let toast: GlobalToastManager.Toast
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: toast.type.icon)
                .font(.title3)
                .foregroundColor(toast.type.color)
            
            Text(toast.message)
                .font(DesignSystem.Typography.asteroid)
                .foregroundColor(DesignSystem.starWhite)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(toast.type.color.opacity(0.5), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct GlobalToastModifier: ViewModifier {
    @ObservedObject var toastManager = GlobalToastManager.shared
    
    func body(content: Content) -> some View {
        content
            .overlay(
                VStack {
                    Spacer()
                    
                    if toastManager.isShowing, let toast = toastManager.currentToast {
                        GlobalToastView(toast: toast)
                            .padding(.horizontal)
                            .padding(.bottom, 100)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: toastManager.isShowing)
                            .onTapGesture {
                                toastManager.dismiss()
                            }
                    }
                }
                .ignoresSafeArea(.keyboard)
            )
    }
}

extension View {
    func withGlobalToast() -> some View {
        self.modifier(GlobalToastModifier())
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("🍞 Global Toast Manager")
            .font(DesignSystem.Typography.largeTitle)
            .goldText()
        
        VStack(spacing: 12) {
            Button("Success Toast") {
                GlobalToastManager.shared.show("Trade executed successfully!", type: .success)
            }
            .buttonStyle(.primary)
            
            Button("Error Toast") {
                GlobalToastManager.shared.show("Connection failed", type: .error)
            }
            .buttonStyle(.primary)
            
            Button("Warning Toast") {
                GlobalToastManager.shared.show("High risk detected", type: .warning)
            }
            .buttonStyle(.primary)
            
            Button("Info Toast") {
                GlobalToastManager.shared.show("Bot deployment started", type: .info)
            }
            .buttonStyle(.primary)
        }
    }
    .padding()
    .withGlobalToast()
}