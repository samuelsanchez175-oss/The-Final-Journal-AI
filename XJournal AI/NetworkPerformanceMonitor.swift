import Foundation
import Network

// MARK: - Network Performance Monitor

class NetworkPerformanceMonitor {
    static let shared = NetworkPerformanceMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkPerformanceMonitor")
    private var currentNetworkType: NetworkType = .unknown
    
    private init() {
        startMonitoring()
    }
    
    enum NetworkType: String, Codable {
        case wifi = "WiFi"
        case cellular = "Cellular"
        case ethernet = "Ethernet"
        case unknown = "Unknown"
    }
    
    // MARK: - Network Request Metrics
    
    struct NetworkRequestMetrics: Codable {
        let id: UUID
        let timestamp: Date
        let url: String
        let method: String
        let statusCode: Int?
        let duration: TimeInterval // milliseconds
        let requestSize: Int // bytes
        let responseSize: Int // bytes
        let networkType: NetworkType
        let retryCount: Int
        let success: Bool
        let errorMessage: String?
        let requestHeaders: [String: String]?
        let responseHeaders: [String: String]?
        
        init(
            id: UUID = UUID(),
            timestamp: Date = Date(),
            url: String,
            method: String,
            statusCode: Int? = nil,
            duration: TimeInterval,
            requestSize: Int,
            responseSize: Int,
            networkType: NetworkType,
            retryCount: Int = 0,
            success: Bool,
            errorMessage: String? = nil,
            requestHeaders: [String: String]? = nil,
            responseHeaders: [String: String]? = nil
        ) {
            self.id = id
            self.timestamp = timestamp
            self.url = url
            self.method = method
            self.statusCode = statusCode
            self.duration = duration
            self.requestSize = requestSize
            self.responseSize = responseSize
            self.networkType = networkType
            self.retryCount = retryCount
            self.success = success
            self.errorMessage = errorMessage
            self.requestHeaders = requestHeaders
            self.responseHeaders = responseHeaders
        }
    }
    
    // MARK: - Storage
    
    private let maxMetrics = 1000
    private let metricsStorageKey = "network_performance_metrics"
    
    // MARK: - Network Monitoring
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            if path.status == .satisfied {
                if path.usesInterfaceType(.wifi) {
                    self?.currentNetworkType = .wifi
                } else if path.usesInterfaceType(.cellular) {
                    self?.currentNetworkType = .cellular
                } else if path.usesInterfaceType(.wiredEthernet) {
                    self?.currentNetworkType = .ethernet
                } else {
                    self?.currentNetworkType = .unknown
                }
            } else {
                self?.currentNetworkType = .unknown
            }
        }
        monitor.start(queue: queue)
    }
    
    // MARK: - Track Request
    
    func trackRequest(
        url: String,
        method: String,
        requestSize: Int,
        responseSize: Int,
        statusCode: Int?,
        duration: TimeInterval,
        success: Bool,
        errorMessage: String? = nil,
        retryCount: Int = 0,
        requestHeaders: [String: String]? = nil,
        responseHeaders: [String: String]? = nil
    ) {
        let metrics = NetworkRequestMetrics(
            url: url,
            method: method,
            statusCode: statusCode,
            duration: duration * 1000, // Convert to milliseconds
            requestSize: requestSize,
            responseSize: responseSize,
            networkType: currentNetworkType,
            retryCount: retryCount,
            success: success,
            errorMessage: errorMessage,
            requestHeaders: requestHeaders,
            responseHeaders: responseHeaders
        )
        
        storeMetrics(metrics)
        
        // Log to console for immediate debugging
        if !success {
            print("⚠️ Network Request Failed: \(method) \(url)")
            print("   Status: \(statusCode?.description ?? "Unknown")")
            print("   Duration: \(String(format: "%.2f", duration * 1000))ms")
            print("   Error: \(errorMessage ?? "Unknown error")")
        }
    }
    
    // MARK: - Storage Management
    
    private func storeMetrics(_ metrics: NetworkRequestMetrics) {
        var allMetrics = getAllMetrics()
        allMetrics.insert(metrics, at: 0)
        
        // Limit to maxMetrics
        if allMetrics.count > maxMetrics {
            allMetrics = Array(allMetrics.prefix(maxMetrics))
        }
        
        if let encoded = try? JSONEncoder().encode(allMetrics) {
            UserDefaults.standard.set(encoded, forKey: metricsStorageKey)
        }
    }
    
    func getAllMetrics() -> [NetworkRequestMetrics] {
        guard let data = UserDefaults.standard.data(forKey: metricsStorageKey),
              let metrics = try? JSONDecoder().decode([NetworkRequestMetrics].self, from: data) else {
            return []
        }
        return metrics
    }
    
    func getRecentMetrics(limit: Int = 100) -> [NetworkRequestMetrics] {
        return Array(getAllMetrics().prefix(limit))
    }
    
    func clearAllMetrics() {
        UserDefaults.standard.removeObject(forKey: metricsStorageKey)
    }
    
    func clearOldMetrics(olderThanDays days: Int) {
        let cutoffDate = Date().addingTimeInterval(-Double(days * 24 * 60 * 60))
        let metrics = getAllMetrics().filter { $0.timestamp > cutoffDate }
        
        if let encoded = try? JSONEncoder().encode(metrics) {
            UserDefaults.standard.set(encoded, forKey: metricsStorageKey)
        }
    }
    
    // MARK: - Statistics
    
    struct NetworkStats {
        let totalRequests: Int
        let successRate: Double
        let averageLatency: Double // milliseconds
        let p95Latency: Double
        let p99Latency: Double
        let medianLatency: Double
        let averageRequestSize: Double
        let averageResponseSize: Double
        let requestsByStatusCode: [Int: Int]
        let requestsByNetworkType: [NetworkType: Int]
        let errorRate: Double
        let retryRate: Double
    }
    
    func getStats(timeRange: TimeInterval? = nil) -> NetworkStats {
        var metrics = getAllMetrics()
        
        if let timeRange = timeRange {
            let cutoffDate = Date().addingTimeInterval(-timeRange)
            metrics = metrics.filter { $0.timestamp > cutoffDate }
        }
        
        guard !metrics.isEmpty else {
            return NetworkStats(
                totalRequests: 0,
                successRate: 0,
                averageLatency: 0,
                p95Latency: 0,
                p99Latency: 0,
                medianLatency: 0,
                averageRequestSize: 0,
                averageResponseSize: 0,
                requestsByStatusCode: [:],
                requestsByNetworkType: [:],
                errorRate: 0,
                retryRate: 0
            )
        }
        
        let successful = metrics.filter { $0.success }
        let successRate = Double(successful.count) / Double(metrics.count)
        
        let latencies = metrics.map { $0.duration }.sorted()
        let averageLatency = latencies.reduce(0, +) / Double(latencies.count)
        let medianLatency = latencies[latencies.count / 2]
        let p95Index = Int(Double(latencies.count) * 0.95)
        let p99Index = Int(Double(latencies.count) * 0.99)
        let p95Latency = p95Index < latencies.count ? latencies[p95Index] : latencies.last ?? 0
        let p99Latency = p99Index < latencies.count ? latencies[p99Index] : latencies.last ?? 0
        
        let averageRequestSize = metrics.map { Double($0.requestSize) }.reduce(0, +) / Double(metrics.count)
        let averageResponseSize = metrics.map { Double($0.responseSize) }.reduce(0, +) / Double(metrics.count)
        
        var requestsByStatusCode: [Int: Int] = [:]
        for metric in metrics {
            if let statusCode = metric.statusCode {
                requestsByStatusCode[statusCode, default: 0] += 1
            }
        }
        
        var requestsByNetworkType: [NetworkType: Int] = [:]
        for metric in metrics {
            requestsByNetworkType[metric.networkType, default: 0] += 1
        }
        
        let errorRate = 1.0 - successRate
        let retryCount = metrics.filter { $0.retryCount > 0 }.count
        let retryRate = Double(retryCount) / Double(metrics.count)
        
        return NetworkStats(
            totalRequests: metrics.count,
            successRate: successRate,
            averageLatency: averageLatency,
            p95Latency: p95Latency,
            p99Latency: p99Latency,
            medianLatency: medianLatency,
            averageRequestSize: averageRequestSize,
            averageResponseSize: averageResponseSize,
            requestsByStatusCode: requestsByStatusCode,
            requestsByNetworkType: requestsByNetworkType,
            errorRate: errorRate,
            retryRate: retryRate
        )
    }
}
