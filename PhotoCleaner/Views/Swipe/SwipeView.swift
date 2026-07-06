//
//  SwipeView.swift
//  PhotoCleaner
//
//  Created by Alexey Kurto on 25.09.25.
//

import SwiftUI
import Lottie
import Photos

struct SwipeView: View {
    
    /*
     MARK: - Properties
     */
    
    @StateObject
    private var viewModel = SwipeViewModel()
    
    @AppStorage("photoCleanerAskBeforeDeletingMarkedPhotos")
    private var askBeforeDeletingMarkedPhotos: Bool = true
    
    @Environment(\.accessibilityReduceMotion)
    private var accessibilityReduceMotion
    
    @State
    private var dragOffset: CGSize = .zero
    
    @State
    private var isAnimatingSwipe: Bool = false
    
    @State
    private var particleBurst: SwipeParticleBurst?
    
    @State
    private var isFinishConfirmationPresented: Bool = false
    
    /*
     MARK: - Body
     */
    
    var body: some View {
        VStack(spacing: 14.0.scaled) {
            headerView
            
            contentView
            
            Spacer(minLength: 0.0)
        }
        .task {
            await viewModel.updateUI()
        }
        .padding(.top, 8.0.scaled)
        .padding(.bottom, 8.0.scaled)
        .padding(.horizontal, 16.0.scaled)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background {
            PhotoCleanerBackground()
        }
        .overlay(alignment: .top) {
            HStack {
                Spacer()
                
                finishButton
            }
            .frame(height: 48.0.scaled, alignment: .center)
            .padding(.horizontal, 16.0.scaled)
            .padding(.top, 8.0.scaled)
        }
        .confirmationDialog(
            "Delete marked photos?",
            isPresented: $isFinishConfirmationPresented,
            titleVisibility: .visible
        ) {
            Button(
                "Delete \(viewModel.markedForDeletionCount) Photos",
                role: .destructive
            ) {
                Task {
                    await viewModel.deleteMarkedPhotos()
                }
            }
            
            Button("Keep in Library", role: .cancel) {
                viewModel.finishSessionKeepingMarkedPhotos()
            }
        } message: {
            Text("Photos marked during this swipe session will be removed from your library.")
        }
        .alert(
            "Swipe Session",
            isPresented: sessionResultBinding
        ) {
            Button("OK", role: .cancel) {
                viewModel.sessionResultMessage = nil
            }
        } message: {
            Text(viewModel.sessionResultMessage ?? "")
        }
        .alert(
            "Could Not Delete Photos",
            isPresented: deleteErrorBinding
        ) {
            Button("OK", role: .cancel) {
                viewModel.deleteErrorMessage = nil
            }
        } message: {
            Text(viewModel.deleteErrorMessage ?? "")
        }
        .safeAreaInset(edge: .bottom, spacing: 0.0) {
            bottomControlsView
        }
        .loadingOverlay
    }
    
    /*
     MARK: - Private views
     */
    
    @ViewBuilder
    private var headerView: some View {
        HStack(spacing: 2.0.scaled) {
            Text("Swipe")
                .foregroundStyle(.color1)
                .font(.system(size: 28.0.scaled, weight: .bold))
                .multilineTextAlignment(.center)
            
            LottieView(animation: .named("Swipe"))
                .playing(loopMode: .loop)
                .frame(width: 48.0.scaled, height: 48.0.scaled)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    private var finishButton: some View {
        Button(action: handleFinishSession) {
            Text("Finish")
                .font(.system(size: 17.0, weight: .semibold))
                .foregroundStyle(.color1)
                .frame(height: 24.0.scaled)
                .cornerRadius(12.0.scaled)
        }
        .buttonStyle(.glass)
        .disabled(!viewModel.canFinishSession || viewModel.isLoading)
        .opacity(viewModel.canFinishSession && !viewModel.isLoading ? 1.0 : 0.4)
    }
    
    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading {
            ProgressView()
                .controlSize(.large)
                .tint(.color1)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            switch viewModel.photoLibraryStatus {
            case .authorized, .limited:
                if viewModel.photos.isEmpty {
                    emptyPhotosView
                } else {
                    GeometryReader { geometryReader in
                        let cardHeight = photoCardHeight(
                            availableHeight: geometryReader.size.height
                        )
                        
                        VStack(spacing: 12.0.scaled) {
                            progressView
                            photoCardView(height: cardHeight)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    }
                }
            case .denied, .restricted:
                photoAccessView
            default:
                ProgressView()
                    .controlSize(.large)
                    .tint(.color1)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    private var progressView: some View {
        VStack(spacing: 8.0.scaled) {
            HStack {
                Text("Reviewed")
                    .foregroundStyle(.color1.opacity(0.7))
                    .font(.system(size: 13.0.scaled, weight: .regular))
                
                Spacer()
                
                Text(viewModel.progressTitle)
                    .foregroundStyle(.color1)
                    .font(.system(size: 13.0.scaled, weight: .semibold))
            }
            
            ProgressView(
                value: Double(viewModel.reviewedCount),
                total: Double(max(viewModel.photos.count, 1))
            )
            .tint(.color1)
        }
        .padding(14.0.scaled)
        .swipeGlassSurface(cornerRadius: CGFloat(16.0.scaled))
    }
    
    private func photoCardHeight(
        availableHeight: CGFloat
    ) -> CGFloat {
        let reservedHeight = CGFloat(76.0.scaled)
        let maximumHeight = min(
            CGFloat(620.0.scaled),
            max(CGFloat(300.0.scaled), availableHeight - CGFloat(72.0.scaled))
        )
        let minimumHeight = min(CGFloat(300.0.scaled), maximumHeight)
        let candidateHeight = availableHeight - reservedHeight
        
        return max(
            minimumHeight,
            min(maximumHeight, candidateHeight)
        )
    }
    
    @ViewBuilder
    private func photoCardView(
        height: CGFloat
    ) -> some View {
        if let photo = viewModel.currentPhoto {
            GeometryReader { geometryReader in
                ZStack(alignment: .bottomLeading) {
                    Color.black.opacity(0.18)
                    
                    Image(uiImage: photo.image)
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: geometryReader.size.width,
                            height: geometryReader.size.height
                        )
                        .clipped()
                    
                    LinearGradient(
                        colors: [
                            .black.opacity(0.0),
                            .black.opacity(0.68)
                        ],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                    
                    VStack(alignment: .leading, spacing: 4.0.scaled) {
                        Text(photo.dateTitle)
                            .foregroundStyle(.color1)
                            .font(.system(size: 20.0.scaled, weight: .bold))
                        
                        Text(photo.resolutionTitle)
                            .foregroundStyle(.color1.opacity(0.72))
                            .font(.system(size: 13.0.scaled, weight: .regular))
                    }
                    .padding(18.0.scaled)
                }
            }
            .frame(maxWidth: .infinity)
            .overlay(alignment: .topLeading) {
                if dragOffset.width < -18.0.scaled {
                    SwipeDecisionBadge(
                        title: "Delete",
                        systemImage: "trash.fill",
                        tint: PhotoCleanerStyle.deleteAccent
                    )
                    .padding(20.0.scaled)
                }
            }
            .overlay(alignment: .topTrailing) {
                if dragOffset.width > 18.0.scaled {
                    SwipeDecisionBadge(
                        title: "Keep",
                        systemImage: "checkmark.circle.fill",
                        tint: PhotoCleanerStyle.keepAccent
                    )
                    .padding(20.0.scaled)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 28.0.scaled))
            .swipeGlassSurface(cornerRadius: CGFloat(28.0.scaled), isInteractive: true)
            .overlay {
                if let particleBurst {
                    SwipeParticleBurstView(direction: particleBurst.direction)
                        .id(particleBurst.id)
                }
            }
            .offset(dragOffset)
            .rotationEffect(.degrees(cardRotationDegrees))
            .gesture(
                DragGesture(minimumDistance: CGFloat(6.0.scaled), coordinateSpace: .local)
                    .onChanged { gesture in
                        guard
                            !isAnimatingSwipe
                        else { return }
                        
                        dragOffset = CGSize(
                            width: gesture.translation.width,
                            height: gesture.translation.height * 0.18
                        )
                    }
                    .onEnded { gesture in
                        handleDragEnd(gesture)
                    }
            )
            .animation(.spring(response: 0.34, dampingFraction: 0.86), value: dragOffset)
            .frame(height: height)
        } else {
            sessionCompleteView
        }
    }
    
    @ViewBuilder
    private var bottomControlsView: some View {
        if shouldShowBottomControls {
            if #available(iOS 26.0, *) {
                GlassEffectContainer(spacing: CGFloat(16.0.scaled)) {
                    bottomControlsStack
                }
                .padding(.horizontal, 16.0.scaled)
                .padding(.top, 8.0.scaled)
                .padding(.bottom, 8.0.scaled)
            } else {
                bottomControlsStack
                    .padding(.horizontal, 16.0.scaled)
                    .padding(.top, 8.0.scaled)
                    .padding(.bottom, 8.0.scaled)
            }
        }
    }
    
    private var bottomControlsStack: some View {
        VStack(spacing: 16.0.scaled) {
            sessionStatsView
            actionBarView
        }
    }
    
    private var sessionStatsView: some View {
        HStack(spacing: 10.0.scaled) {
            SwipeMetricView(
                title: "Keep",
                value: "\(viewModel.keptCount)",
                systemImage: "checkmark.circle.fill",
                tint: PhotoCleanerStyle.keepAccent
            )
            
            SwipeMetricView(
                title: "Delete",
                value: "\(viewModel.markedForDeletionCount)",
                systemImage: "trash.fill",
                tint: PhotoCleanerStyle.deleteAccent
            )
            
            SwipeMetricView(
                title: "Left",
                value: "\(viewModel.remainingCount)",
                systemImage: "photo.stack.fill",
                tint: .color1
            )
        }
    }
    
    private var actionBarView: some View {
        HStack(spacing: 16.0.scaled) {
            SwipeActionButton(
                title: "Delete",
                systemImage: "trash.fill",
                tint: PhotoCleanerStyle.deleteAccent
            ) {
                animateSwipe(.delete)
            }
            
            SwipeActionButton(
                title: "Keep",
                systemImage: "checkmark.circle.fill",
                tint: PhotoCleanerStyle.keepAccent
            ) {
                animateSwipe(.keep)
            }
        }
        .opacity(viewModel.currentPhoto == nil || viewModel.isLoading ? 0.45 : 1.0)
        .disabled(viewModel.currentPhoto == nil || viewModel.isLoading)
    }
    
    private var shouldShowBottomControls: Bool {
        switch viewModel.photoLibraryStatus {
        case .authorized, .limited:
            return !viewModel.photos.isEmpty
        default:
            return false
        }
    }
    
    private var photoAccessView: some View {
        PhotoCleanerStateCard(
            imageName: "SplashLogo",
            systemImage: nil,
            title: "Photo Access Needed",
            message: "Allow access so Swipe can turn your library into keep-or-delete cards.",
            buttonTitle: "Open Settings",
            accent: .color4,
            action: openSettings
        )
        .padding(24.0.scaled)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyPhotosView: some View {
        PhotoCleanerStateCard(
            imageName: nil,
            systemImage: "sparkles",
            title: "Nothing to Swipe",
            message: "Your current library has no photos available for this swipe session.",
            buttonTitle: nil,
            accent: PhotoCleanerStyle.sparkleAccent,
            action: nil
        )
        .padding(24.0.scaled)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var sessionCompleteView: some View {
        PhotoCleanerStateCard(
            imageName: nil,
            systemImage: "checkmark.seal.fill",
            title: "Session Complete",
            message: "Finish the session to choose what happens with photos marked for deletion.",
            buttonTitle: nil,
            accent: PhotoCleanerStyle.keepAccent,
            action: nil
        )
        .frame(maxWidth: .infinity, minHeight: 470.0.scaled)
    }
    
    private func openSettings() {
        guard
            let url = URL(string: UIApplication.openSettingsURLString)
        else { return }
        
        UIApplication.shared.open(url)
    }
    
    private var sessionResultBinding: Binding<Bool> {
        Binding {
            viewModel.sessionResultMessage != nil
        } set: { isPresented in
            if !isPresented {
                viewModel.sessionResultMessage = nil
            }
        }
    }
    
    private var deleteErrorBinding: Binding<Bool> {
        Binding {
            viewModel.deleteErrorMessage != nil
        } set: { isPresented in
            if !isPresented {
                viewModel.deleteErrorMessage = nil
            }
        }
    }
    
    private var cardRotationDegrees: Double {
        min(
            10.0,
            max(
                -10.0,
                Double(dragOffset.width / 28.0)
            )
        )
    }
    
    /*
     MARK: - Private methods
     */
    
    private func handleDragEnd(
        _ gesture: DragGesture.Value
    ) {
        if let direction = swipeDirection(for: gesture) {
            animateSwipe(direction)
        } else {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                dragOffset = .zero
            }
        }
    }
    
    private func swipeDirection(
        for gesture: DragGesture.Value
    ) -> SwipeDirection? {
        let translationThreshold = CGFloat(72.0.scaled)
        let predictedThreshold = CGFloat(128.0.scaled)
        let translationWidth = gesture.translation.width
        let predictedWidth = gesture.predictedEndTranslation.width
        
        if translationWidth <= -translationThreshold || predictedWidth <= -predictedThreshold {
            return .delete
        }
        
        if translationWidth >= translationThreshold || predictedWidth >= predictedThreshold {
            return .keep
        }
        
        return nil
    }
    
    private func animateSwipe(
        _ direction: SwipeDirection
    ) {
        guard
            viewModel.currentPhoto != nil,
            !isAnimatingSwipe
        else { return }
        
        isAnimatingSwipe = true
        
        if !accessibilityReduceMotion {
            particleBurst = SwipeParticleBurst(direction: direction)
        }
        
        withAnimation(.spring(response: accessibilityReduceMotion ? 0.12 : 0.24, dampingFraction: 0.82)) {
            dragOffset = CGSize(
                width: direction.exitOffset,
                height: dragOffset.height * 0.4
            )
        }
        
        let completionDelay = accessibilityReduceMotion ? 0.1 : 0.28
        
        DispatchQueue.main.asyncAfter(deadline: .now() + completionDelay) {
            switch direction {
            case .delete:
                viewModel.markCurrentPhotoForDeletion()
            case .keep:
                viewModel.keepCurrentPhoto()
            }
            
            particleBurst = nil
            dragOffset = .zero
            isAnimatingSwipe = false
        }
    }
    
    private func handleFinishSession() {
        guard
            viewModel.canFinishSession
        else { return }
        
        guard
            viewModel.markedForDeletionCount > 0
        else {
            viewModel.finishSessionKeepingMarkedPhotos()
            return
        }
        
        if askBeforeDeletingMarkedPhotos {
            isFinishConfirmationPresented = true
        } else {
            Task {
                await viewModel.deleteMarkedPhotos()
            }
        }
    }
}

private enum SwipeDirection {
    case delete,
         keep
    
    var exitOffset: CGFloat {
        switch self {
        case .delete:
            return CGFloat(-720.0.scaled)
        case .keep:
            return CGFloat(720.0.scaled)
        }
    }
    
    var particleTint: Color {
        switch self {
        case .delete:
            return PhotoCleanerStyle.deleteAccent
        case .keep:
            return PhotoCleanerStyle.keepAccent
        }
    }
    
    var horizontalSign: CGFloat {
        switch self {
        case .delete:
            return -1.0
        case .keep:
            return 1.0
        }
    }
}

private struct SwipeParticleBurst: Identifiable {
    
    /*
     MARK: - Properties
     */
    
    let id = UUID()
    let direction: SwipeDirection
}

private struct SwipeParticleBurstView: View {
    
    /*
     MARK: - Properties
     */
    
    var direction: SwipeDirection
    
    @Environment(\.accessibilityReduceMotion)
    private var accessibilityReduceMotion
    
    @State
    private var isExploded: Bool = false
    
    /*
     MARK: - Body
     */
    
    var body: some View {
        GeometryReader { geometryReader in
            ZStack {
                ForEach(0..<18, id: \.self) { index in
                    RoundedRectangle(cornerRadius: CGFloat(3.0.scaled))
                        .fill(direction.particleTint.opacity(particleOpacity(for: index)))
                        .frame(
                            width: particleSize(for: index).width,
                            height: particleSize(for: index).height
                        )
                        .rotationEffect(.degrees(isExploded ? particleRotation(for: index) : 0.0))
                        .scaleEffect(isExploded ? 0.24 : 1.0)
                        .offset(isExploded ? endOffset(for: index, in: geometryReader.size) : startOffset(for: index))
                        .opacity(isExploded ? 0.0 : 1.0)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .allowsHitTesting(false)
        .onAppear {
            guard
                !accessibilityReduceMotion
            else { return }
            
            withAnimation(.easeOut(duration: 0.5)) {
                isExploded = true
            }
        }
    }
    
    /*
     MARK: - Private methods
     */
    
    private func startOffset(
        for index: Int
    ) -> CGSize {
        let column = CGFloat(index % 6)
        let row = CGFloat(index / 6)
        
        return CGSize(
            width: (column - 2.5) * CGFloat(30.0.scaled),
            height: (row - 1.0) * CGFloat(36.0.scaled)
        )
    }
    
    private func endOffset(
        for index: Int,
        in size: CGSize
    ) -> CGSize {
        let row = CGFloat(index / 6)
        let directionBias = CGFloat(index % 3) * CGFloat(18.0.scaled)
        let verticalDirection: CGFloat = index.isMultiple(of: 2) ? -1.0 : 1.0
        let verticalTravel = (CGFloat(70.0.scaled) + row * CGFloat(42.0.scaled)) * verticalDirection
        let horizontalTravel = size.width * 0.34 + CGFloat(92.0.scaled) + directionBias
        
        return CGSize(
            width: startOffset(for: index).width + direction.horizontalSign * horizontalTravel,
            height: startOffset(for: index).height + verticalTravel
        )
    }
    
    private func particleSize(
        for index: Int
    ) -> CGSize {
        CGSize(
            width: CGFloat((index.isMultiple(of: 2) ? 22.0 : 14.0).scaled),
            height: CGFloat((index.isMultiple(of: 3) ? 18.0 : 10.0).scaled)
        )
    }
    
    private func particleRotation(
        for index: Int
    ) -> Double {
        let baseRotation = Double((index % 6) - 3) * 18.0
        return baseRotation * Double(direction.horizontalSign)
    }
    
    private func particleOpacity(
        for index: Int
    ) -> Double {
        index.isMultiple(of: 4) ? 0.9 : 0.62
    }
}

private struct SwipeMetricView: View {
    
    /*
     MARK: - Properties
     */
    
    var title: String
    var value: String
    var systemImage: String
    var tint: Color
    
    /*
     MARK: - Body
     */
    
    var body: some View {
        VStack(spacing: 6.0.scaled) {
            Image(systemName: systemImage)
                .foregroundStyle(tint)
                .font(.system(size: 17.0.scaled, weight: .semibold))
                .frame(height: 20.0.scaled)
            
            Text(value)
                .foregroundStyle(.color1)
                .font(.system(size: 20.0.scaled, weight: .bold))
            
            Text(title)
                .foregroundStyle(.color1.opacity(0.64))
                .font(.system(size: 12.0.scaled, weight: .medium))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12.0.scaled)
        .swipeGlassSurface(cornerRadius: CGFloat(16.0.scaled))
    }
}

private struct SwipeActionButton: View {
    
    /*
     MARK: - Properties
     */
    
    var title: String
    var systemImage: String
    var tint: Color
    var action: () -> Void
    
    /*
     MARK: - Body
     */
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2.0.scaled) {
                Image(systemName: systemImage)
                    .font(.system(size: 16.0.scaled, weight: .semibold))
                
                Text(title)
                    .font(.system(size: 16.0.scaled, weight: .semibold))
            }
            .padding(.vertical, 4.0.scaled)
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.glass)
    }
}

private struct SwipeDecisionBadge: View {
    
    /*
     MARK: - Properties
     */
    
    var title: String
    var systemImage: String
    var tint: Color
    
    /*
     MARK: - Body
     */
    
    var body: some View {
        HStack(spacing: 8.0.scaled) {
            Image(systemName: systemImage)
            
            Text(title)
        }
        .foregroundStyle(tint)
        .font(.system(size: 17.0.scaled, weight: .bold))
        .padding(.horizontal, 14.0.scaled)
        .padding(.vertical, 10.0.scaled)
        .background(.black.opacity(0.4), in: Capsule())
    }
}

private struct SwipeGlassSurface: ViewModifier {
    
    /*
     MARK: - Properties
     */
    
    var cornerRadius: CGFloat
    var isInteractive: Bool
    
    /*
     MARK: - Body
     */
    
    func body(
        content: Content
    ) -> some View {
        if #available(iOS 26.0, *) {
            if isInteractive {
                content
                    .glassEffect(
                        .regular.tint(.color1.opacity(0.06)).interactive(),
                        in: .rect(cornerRadius: cornerRadius)
                    )
            } else {
                content
                    .glassEffect(
                        .regular.tint(.color1.opacity(0.04)),
                        in: .rect(cornerRadius: cornerRadius)
                    )
            }
        } else {
            content
                .background(
                    .ultraThinMaterial,
                    in: RoundedRectangle(cornerRadius: cornerRadius)
                )
        }
    }
}

private extension View {
    
    func swipeGlassSurface(
        cornerRadius: CGFloat,
        isInteractive: Bool = false
    ) -> some View {
        modifier(
            SwipeGlassSurface(
                cornerRadius: cornerRadius,
                isInteractive: isInteractive
            )
        )
    }
}

#Preview {
    SwipeView()
}
