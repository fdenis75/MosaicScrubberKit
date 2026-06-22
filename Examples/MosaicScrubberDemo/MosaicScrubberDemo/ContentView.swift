import AVFoundation
import MosaicScrubberKit
import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var session: VideoSession?
    @State private var isImporterPresented = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let scrubberConfiguration = ScrubberConfiguration(
        thumbnailCount: 56,
        trackHeight: 72,
        previewSize: CGSize(width: 360, height: 203),
        maximumPreviewDuration: 1.5,
        seekTolerance: 0.08,
        hoverDebounce: 0.03,
        transitionDuration: 0.10,
        showsTimecode: true,
        commitsSeekOnDragEnd: true,
        prefetchWindow: 4,
        cachePolicy: .memory(maxItems: 128)
    )

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()

            Group {
                if let session {
                    playerSurface(for: session)
                } else {
                    emptyState
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 900, minHeight: 640)
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

    private func playerSurface(for session: VideoSession) -> some View {
        ScrubbingVideoPlayer(
            source: session.source,
            player: session.player,
            configuration: scrubberConfiguration
        )
        .padding(24)
        .onAppear {
            session.player.play()
        }
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
