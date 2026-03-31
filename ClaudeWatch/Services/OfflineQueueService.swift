import Foundation
import Network

actor OfflineQueueService {
    private var queue: [QueuedAction] = []
    private let fileURL: URL
    private let monitor = NWPathMonitor()
    private var isOnline = true

    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        fileURL = docs.appendingPathComponent("offline_queue.json")
        // Load and start monitoring after actor is initialized
        Task { await self.setup() }
    }

    private func setup() {
        loadQueue()
        startMonitoring()
    }

    var isConnected: Bool { isOnline }
    var pendingCount: Int { queue.count }

    func enqueue(_ action: QueuedAction) {
        queue.append(action)
        saveQueue()
    }

    func dequeue() -> QueuedAction? {
        guard !queue.isEmpty else { return nil }
        let action = queue.removeFirst()
        saveQueue()
        return action
    }

    func clearAll() {
        queue.removeAll()
        saveQueue()
    }

    // MARK: - Persistence

    private func saveQueue() {
        if let data = try? JSONEncoder().encode(queue) {
            try? data.write(to: fileURL)
        }
    }

    private func loadQueue() {
        guard let data = try? Data(contentsOf: fileURL),
              let loaded = try? JSONDecoder().decode([QueuedAction].self, from: data)
        else { return }
        queue = loaded
    }

    // MARK: - Network Monitoring

    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            Task { await self.updateConnectivity(path.status == .satisfied) }
        }
        monitor.start(queue: DispatchQueue.global(qos: .utility))
    }

    private func updateConnectivity(_ online: Bool) {
        isOnline = online
    }

    deinit {
        monitor.cancel()
    }
}
