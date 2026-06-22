import Testing
@testable import MosaicScrubberCore

@Suite("Thumbnail memory cache tests")
struct ThumbnailMemoryCacheTests {
    @Test("Cache evicts least recently used values")
    func cacheEvictsLeastRecentlyUsed() async {
        let cache = ThumbnailMemoryCache<Int>(maximumItems: 2)
        await cache.store(1, forKey: "one")
        await cache.store(2, forKey: "two")
        _ = await cache.value(forKey: "one")
        await cache.store(3, forKey: "three")

        let one = await cache.value(forKey: "one")
        let two = await cache.value(forKey: "two")
        let three = await cache.value(forKey: "three")

        #expect(one == 1)
        #expect(two == nil)
        #expect(three == 3)
    }
}
