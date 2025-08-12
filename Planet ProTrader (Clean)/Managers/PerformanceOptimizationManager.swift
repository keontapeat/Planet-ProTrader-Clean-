import SwiftUI
import Combine

@MainActor
final class PerformanceOptimizationManager: ObservableObject {
    static let shared = PerformanceOptimizationManager()

    @Published var currentMemoryUsage: Double = 0.32
    @Published var currentCPUUsage: Double = 0.28
    @Published var framerate: Double = 60.0
    @Published var isThrottlingActive: Bool = false
    @Published var optimizationLevel: OptimizationLevel = .balanced

    private var timer: Timer?

    private init() {
        startMonitoring()
    }

    func getPerformanceReport() -> PerformanceReport {
        let grade = gradeFor(memory: currentMemoryUsage, cpu: currentCPUUsage, fps: framerate)
        return PerformanceReport(
            memoryUsage: currentMemoryUsage,
            cpuUsage: currentCPUUsage,
            framerate: framerate,
            performanceGrade: grade
        )
    }

    func optimizeForMassDeployment(botCount: Int) async {
        if botCount >= 5000 {
            optimizationLevel = .eco
            isThrottlingActive = true
            currentCPUUsage = min(0.65, currentCPUUsage + 0.1)
            framerate = max(45, framerate - 8)
        } else if botCount >= 1000 {
            optimizationLevel = .balanced
            isThrottlingActive = true
            currentCPUUsage = min(0.55, currentCPUUsage + 0.05)
            framerate = max(50, framerate - 4)
        } else {
            optimizationLevel = .turbo
            isThrottlingActive = false
            framerate = 60
        }
    }

    private func startMonitoring() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                let memNoise = Double.random(in: -0.01...0.01)
                let cpuNoise = Double.random(in: -0.015...0.015)
                let fpsNoise = Double.random(in: -1.5...1.5)

                self.currentMemoryUsage = self.clamp(self.currentMemoryUsage + memNoise, 0.2, 0.9)
                self.currentCPUUsage = self.clamp(self.currentCPUUsage + cpuNoise, 0.2, 0.9)
                self.framerate = self.clamp(self.framerate + fpsNoise, 25, 60)
            }
        }
    }

    private func clamp(_ value: Double, _ minVal: Double, _ maxVal: Double) -> Double {
        return min(maxVal, max(minVal, value))
    }

    private func gradeFor(memory: Double, cpu: Double, fps: Double) -> String {
        let memScore = 1.0 - memory
        let cpuScore = 1.0 - cpu
        let fpsScore = fps / 60.0
        let score = (memScore * 0.35) + (cpuScore * 0.35) + (fpsScore * 0.30)

        switch score {
        case 0.90...: return "A+"
        case 0.80..<0.90: return "A"
        case 0.70..<0.80: return "B+"
        case 0.60..<0.70: return "B"
        case 0.50..<0.60: return "C+"
        default: return "C"
        }
    }

    enum OptimizationLevel {
        case eco, balanced, turbo

        var emoji: String {
            switch self {
            case .eco: return "🌿"
            case .balanced: return "⚖️"
            case .turbo: return "🚀"
            }
        }

        var color: Color {
            switch self {
            case .eco: return .green
            case .balanced: return .blue
            case .turbo: return .orange
            }
        }
    }
}

struct PerformanceReport {
    let memoryUsage: Double
    let cpuUsage: Double
    let framerate: Double
    let performanceGrade: String

    var memoryUsageFormatted: String {
        "\(Int(memoryUsage * 100))%"
    }

    var cpuUsageFormatted: String {
        "\(Int(cpuUsage * 100))%"
    }

    var framerateFormatted: String {
        "\(Int(framerate))"
    }
}

struct PerformanceOptimizationPreviewView: View {
    @StateObject private var perf = PerformanceOptimizationManager.shared

    var body: some View {
        VStack(spacing: 16) {
            let report = perf.getPerformanceReport()

            HStack(spacing: 16) {
                metric("Memory", report.memoryUsageFormatted, .green)
                metric("CPU", report.cpuUsageFormatted, .blue)
                metric("FPS", report.framerateFormatted, .orange)
                VStack {
                    Text("Mode")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(perf.optimizationLevel.emoji)
                        .font(.title2)
                        .foregroundColor(perf.optimizationLevel.color)
                }
                .frame(maxWidth: .infinity)
            }

            Text("Grade: \(report.performanceGrade)")
                .font(.headline)
                .foregroundStyle(LinearGradient(colors: [.green, .mint], startPoint: .leading, endPoint: .trailing))

            Button("Simulate 5000-bot Optimize") {
                Task { await perf.optimizeForMassDeployment(botCount: 5000) }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .padding()
        .background(DesignSystem.AnimatedStarField().ignoresSafeArea())
    }

    private func metric(_ title: String, _ value: String, _ color: Color) -> some View {
        VStack {
            Text(value)
                .font(.headline)
                .foregroundStyle(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(RoundedRectangle(cornerRadius: 8).fill(color.opacity(0.1)))
    }
}

#Preview {
    PerformanceOptimizationPreviewView()
        .preferredColorScheme(.dark)
}