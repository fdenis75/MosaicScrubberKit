import AVFoundation
import CoreGraphics
import MosaicScrubberKit
import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var session: VideoSession?
    @State private var isImporterPresented = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var settings = DemoScrubberSettings.recommended
    @State private var playerAvailableSize = CGSize(width: 760, height: 420)

    private var scrubberConfiguration: ScrubberConfiguration {
        settings.configuration
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()

            HStack(spacing: 0) {
                Group {
                    if let session {
                        playerSurface(for: session)
                    } else {
                        emptyState
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                Divider()

                settingsPanel
                    .frame(width: 340)
            }
        }
        .frame(minWidth: 1120, minHeight: 720)
        .fileImporter(
            isPresented: $isImporterPresented,
            allowedContentTypes: [.movie, .mpeg4Movie, .quickTimeMovie],
            allowsMultipleSelection: false,
            onCompletion: handleImport
        )
        .alert(
            "Unable to Open Video",
            isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Label("Mosaic Scrubber Demo", systemImage: "film.stack")
                .font(.headline)

            if let session {
                Text(session.source.title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .accessibilityLabel("Current video \(session.source.title)")
            }

            Spacer()

            if isLoading {
                ProgressView()
                    .controlSize(.small)
            }

            Button {
                isImporterPresented = true
            } label: {
                Label(session == nil ? "Open Video" : "Open Another", systemImage: "folder")
            }
            .disabled(isLoading)
            .keyboardShortcut("o", modifiers: .command)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("Open a Video", systemImage: "film")
        } description: {
            Text("Choose a local movie file.")
        } actions: {
            Button {
                isImporterPresented = true
            } label: {
                Label("Open Video", systemImage: "folder")
            }
            .disabled(isLoading)
        }
    }

    private var settingsPanel: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                settingsHeader
                sourceSummary
                layoutControls
                previewControls
                interactionControls
                visualControls
                cacheControls
            }
            .padding(18)
        }
        .background(.regularMaterial)
    }

    private var settingsHeader: some View {
        HStack {
            Label("Settings", systemImage: "slider.horizontal.3")
                .font(.headline)

            Spacer()

            Button {
                settings = .recommended
            } label: {
                Image(systemName: "arrow.counterclockwise")
            }
            .buttonStyle(.borderless)
            .help("Reset")
        }
    }

    @ViewBuilder
    private var sourceSummary: some View {
        if let session {
            let source = session.source
            let naturalSize = source.naturalSize ?? .zero
            let preview = settings.previewSize.resolvedDimensions(
                videoSize: source.naturalSize,
                availablePlayerSize: playerAvailableSize
            )

            VStack(alignment: .leading, spacing: 8) {
                readoutRow("Duration", value: source.duration.map(TimecodeFormatter.string(from:)) ?? "-")
                readoutRow("Source", value: dimensionText(naturalSize))
                readoutRow("Aspect", value: aspectText(naturalSize))
                readoutRow("Preview", value: dimensionText(preview))
            }
            .font(.caption)
            .padding(12)
            .background(.thinMaterial, in: .rect(cornerRadius: 8))
        }
    }

    private var layoutControls: some View {
        SettingsSection(title: "Layout") {
            valueSlider(
                title: "Thumbnails",
                value: Binding(
                    get: { Double(settings.thumbnailCount) },
                    set: { settings.thumbnailCount = Int($0.rounded()) }
                ),
                range: 12...240,
                step: 4,
                display: "\(settings.thumbnailCount)"
            )

            valueSlider(
                title: "Track height",
                value: $settings.trackHeight,
                range: 44...120,
                step: 2,
                display: "\(Int(settings.trackHeight.rounded())) px"
            )

            Picker("Preview size", selection: $settings.previewSize) {
                Text("Small").tag(ScrubberPreviewSize.small)
                Text("Medium").tag(ScrubberPreviewSize.medium)
                Text("Large").tag(ScrubberPreviewSize.large)
            }
            .pickerStyle(.segmented)
        }
    }

    private var previewControls: some View {
        SettingsSection(title: "Preview") {
            valueSlider(
                title: "Max duration",
                value: $settings.maximumPreviewDuration,
                range: 0.2...1.5,
                step: 0.1,
                display: String(format: "%.1f s", settings.maximumPreviewDuration)
            )

            valueSlider(
                title: "Transition",
                value: $settings.transitionDuration,
                range: 0...0.35,
                step: 0.01,
                display: String(format: "%.2f s", settings.transitionDuration)
            )

            valueSlider(
                title: "Seek tolerance",
                value: $settings.seekTolerance,
                range: 0...0.5,
                step: 0.01,
                display: String(format: "%.2f s", settings.seekTolerance)
            )
        }
    }

    private var interactionControls: some View {
        SettingsSection(title: "Interaction") {
            valueSlider(
                title: "Hover debounce",
                value: $settings.hoverDebounce,
                range: 0...0.2,
                step: 0.01,
                display: String(format: "%.2f s", settings.hoverDebounce)
            )

            Toggle("Commit seek on drag end", isOn: $settings.commitsSeekOnDragEnd)
        }
    }

    private var visualControls: some View {
        SettingsSection(title: "Visuals") {
            Picker("Theme", selection: $settings.visualTheme) {
                Text("Automatic").tag(ScrubberVisualTheme.automatic)
                Text("Dark").tag(ScrubberVisualTheme.obsidianFlux)
                Text("Light").tag(ScrubberVisualTheme.obsidianFluxLight)
            }

            Toggle("Timecode", isOn: $settings.showsTimecode)
            Toggle("Temporal delta", isOn: $settings.showsTemporalDelta)
            Toggle("Live indicator", isOn: $settings.showsLiveIndicator)
            Toggle("Film perforations", isOn: $settings.showsFilmPerforations)
            Toggle("Hover spotlight", isOn: $settings.usesHoverSpotlight)
        }
    }

    private var cacheControls: some View {
        SettingsSection(title: "Cache") {
            Picker("Policy", selection: $settings.cacheMode) {
                Text("Memory").tag(DemoCacheMode.memory)
                Text("None").tag(DemoCacheMode.none)
            }
            .pickerStyle(.segmented)

            valueSlider(
                title: "Memory items",
                value: Binding(
                    get: { Double(settings.cacheMaxItems) },
                    set: { settings.cacheMaxItems = Int($0.rounded()) }
                ),
                range: 16...256,
                step: 16,
                display: "\(settings.cacheMaxItems)"
            )
            .disabled(settings.cacheMode == .none)

            valueSlider(
                title: "Prefetch window",
                value: Binding(
                    get: { Double(settings.prefetchWindow) },
                    set: { settings.prefetchWindow = Int($0.rounded()) }
                ),
                range: 0...8,
                step: 1,
                display: "\(settings.prefetchWindow)"
            )
        }
    }

    private func playerSurface(for session: VideoSession) -> some View {
        ScrubbingVideoPlayer(
            source: session.source,
            player: session.player,
            configuration: scrubberConfiguration
        )
        .id(settings)
        .padding(24)
        .onGeometryChange(for: CGSize.self) { proxy in
            proxy.size
        } action: { newSize in
            playerAvailableSize = newSize
        }
        .onAppear {
            session.player.play()
        }
    }

    private func valueSlider(
        title: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double,
        display: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                Spacer()
                Text(display)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            .font(.caption)

            Slider(value: value, in: range, step: step)
        }
    }

    private func readoutRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .monospacedDigit()
        }
    }

    private func dimensionText(_ size: CGSize) -> String {
        guard size.width > 0, size.height > 0 else { return "-" }
        return "\(Int(size.width.rounded())) x \(Int(size.height.rounded()))"
    }

    private func aspectText(_ size: CGSize) -> String {
        guard size.width > 0, size.height > 0 else { return "-" }
        let aspect = size.width / size.height
        return String(format: "%.2f:1", aspect)
    }

    private func handleImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            Task {
                await open(url)
            }

        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func open(_ url: URL) async {
        isLoading = true
        errorMessage = nil

        let didStartScope = url.startAccessingSecurityScopedResource()
        do {
            let source = try await ScrubberVideoSource.load(from: url)
            let nextSession = VideoSession(url: url, source: source, didStartScope: didStartScope)
            session?.player.pause()
            session = nextSession
        } catch {
            if didStartScope {
                url.stopAccessingSecurityScopedResource()
            }
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

private struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            VStack(alignment: .leading, spacing: 12) {
                content
            }
        }
    }
}

private struct DemoScrubberSettings: Hashable {
    var thumbnailCount: Int
    var trackHeight: Double
    var previewSize: ScrubberPreviewSize
    var maximumPreviewDuration: TimeInterval
    var seekTolerance: TimeInterval
    var hoverDebounce: TimeInterval
    var transitionDuration: TimeInterval
    var showsTimecode: Bool
    var showsTemporalDelta: Bool
    var showsLiveIndicator: Bool
    var showsFilmPerforations: Bool
    var usesHoverSpotlight: Bool
    var visualTheme: ScrubberVisualTheme
    var commitsSeekOnDragEnd: Bool
    var prefetchWindow: Int
    var cacheMode: DemoCacheMode
    var cacheMaxItems: Int

    static let recommended = DemoScrubberSettings(
        thumbnailCount: 56,
        trackHeight: 72,
        previewSize: .large,
        maximumPreviewDuration: 1.5,
        seekTolerance: 0.08,
        hoverDebounce: 0.03,
        transitionDuration: 0.10,
        showsTimecode: true,
        showsTemporalDelta: true,
        showsLiveIndicator: true,
        showsFilmPerforations: true,
        usesHoverSpotlight: true,
        visualTheme: .automatic,
        commitsSeekOnDragEnd: true,
        prefetchWindow: 4,
        cacheMode: .memory,
        cacheMaxItems: 128
    )

    var configuration: ScrubberConfiguration {
        ScrubberConfiguration(
            thumbnailCount: thumbnailCount,
            trackHeight: trackHeight,
            previewSize: previewSize,
            maximumPreviewDuration: maximumPreviewDuration,
            seekTolerance: seekTolerance,
            hoverDebounce: hoverDebounce,
            transitionDuration: transitionDuration,
            showsTimecode: showsTimecode,
            showsTemporalDelta: showsTemporalDelta,
            showsLiveIndicator: showsLiveIndicator,
            showsFilmPerforations: showsFilmPerforations,
            usesHoverSpotlight: usesHoverSpotlight,
            visualTheme: visualTheme,
            commitsSeekOnDragEnd: commitsSeekOnDragEnd,
            prefetchWindow: prefetchWindow,
            cachePolicy: cachePolicy
        )
    }

    private var cachePolicy: ScrubberCachePolicy {
        switch cacheMode {
        case .none:
            return .none
        case .memory:
            return .memory(maxItems: cacheMaxItems)
        }
    }
}

private enum DemoCacheMode: Hashable {
    case memory
    case none
}

@MainActor
private final class VideoSession: Identifiable {
    let id = UUID()
    let source: ScrubberVideoSource
    let player: AVPlayer

    private let url: URL
    private let didStartScope: Bool

    init(url: URL, source: ScrubberVideoSource, didStartScope: Bool) {
        self.url = url
        self.source = source
        self.didStartScope = didStartScope
        self.player = AVPlayer(url: url)
    }

    deinit {
        player.pause()
        if didStartScope {
            url.stopAccessingSecurityScopedResource()
        }
    }
}
