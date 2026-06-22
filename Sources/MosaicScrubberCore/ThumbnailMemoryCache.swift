import Foundation

public actor ThumbnailMemoryCache<Value: Sendable> {
    private let maximumItems: Int
    private var values: [String: Value] = [:]
    private var order: [String] = []

    public init(maximumItems: Int) {
        self.maximumItems = max(1, maximumItems)
    }

    public func value(forKey key: String) -> Value? {
        guard let value = values[key] else { return nil }
        order.removeAll { $0 == key }
        order.append(key)
        return value
    }

    public func store(_ value: Value, forKey key: String) {
        if values[key] == nil {
            order.append(key)
        } else {
            order.removeAll { $0 == key }
            order.append(key)
        }

        values[key] = value
        evictIfNeeded()
    }

    public func removeAll() {
        values.removeAll()
        order.removeAll()
    }

    private func evictIfNeeded() {
        while values.count > maximumItems, let first = order.first {
            order.removeFirst()
            values.removeValue(forKey: first)
        }
    }
}
