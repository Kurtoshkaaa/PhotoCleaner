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
    
    @State
    private var dragOffset: CGSize = .zero
    
    @State
    private var isAnimatingSwipe: Bool = false
    
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
            LinearGradient(
                colors: [
                    .color4,
                    .color2
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
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
            actionBarView
                .padding(.horizontal, 16.0.scaled)
                .padding(.top, 8.0.scaled)
                .padding(.bottom, 8.0.scaled)
        }
        .loadingOverlay
    }
    
    /*
     MARK: - Private views
     */
    
    private var headerView: some View {
        HStack(spacing: 12.0.scaled) {
            HStack(spacing: 2.0.scaled) {
                Text("Swipe")
                    .foregroundStyle(.color1)
                    .font(.system(size: 28.0.scaled, weight: .bold))
                    .multilineTextAlignment(.leading)
                
                LottieView(animation: .named("Swipe"))
                    .playing(loopMode: .loop)
                    .frame(width: 48.0.scaled, height: 48.0.scaled)
            }
            
            Spacer()
            
            Button(action: handleFinishSession) {
                Text("Finish")
                    .foregroundStyle(.color1)
                    .font(.system(size: 15.0.scaled, weight: .semibold))
                    .frame(height: 32.0.scaled)
                    .padding(.horizontal, 14.0.scaled)
            }
            .buttonStyle(.glass)
            .disabled(!viewModel.canFinishSession || viewModel.isLoading)
            .opacity(viewModel.canFinishSession && !viewModel.isLoading ? 1.0 : 0.4)
        }
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
                            sessionStatsView
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
        let reservedHeight = 188.0.scaled
        let maximumHeight = 470.0.scaled
        let minimumHeight = 300.0.scaled
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
                if dragOffset.width < -24.0.scaled {
                    SwipeDecisionBadge(
                        title: "Delete",
                        systemImage: "trash.fill",
                        tint: .red
                    )
                    .padding(20.0.scaled)
                }
            }
            .overlay(alignment: .topTrailing) {
                if dragOffset.width > 24.0.scaled {
                    SwipeDecisionBadge(
                        title: "Keep",
                        systemImage: "checkmark.circle.fill",
                        tint: .green
                    )
                    .padding(20.0.scaled)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 28.0.scaled))
            .swipeGlassSurface(cornerRadius: CGFloat(28.0.scaled), isInteractive: true)
            .offset(dragOffset)
            .rotationEffect(.degrees(Double(dragOffset.width / 24.0)))
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        guard
                            !isAnimatingSwipe
                        else { return }
                        
                        dragOffset = gesture.translation
                    }
                    .onEnded { gesture in
                        handleDragEnd(translation: gesture.translation)
                    }
            )
            .animation(.spring(response: 0.34, dampingFraction: 0.86), value: dragOffset)
            .frame(height: height)
        } else {
            sessionCompleteView
        }
    }
    
    private var sessionStatsView: some View {
        HStack(spacing: 10.0.scaled) {
            SwipeMetricView(
                title: "Keep",
                value: "\(viewModel.keptCount)",
                systemImage: "checkmark.circle.fill",
                tint: .green
            )
            
            SwipeMetricView(
                title: "Delete",
                value: "\(viewModel.markedForDeletionCount)",
                systemImage: "trash.fill",
                tint: .red
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
        HStack(spacing: 18.0.scaled) {
            SwipeActionButton(
                title: "Delete",
                systemImage: "trash.fill",
                tint: .red
            ) {
                animateSwipe(.delete)
            }
            
            SwipeActionButton(
                title: "Keep",
                systemImage: "checkmark.circle.fill",
                tint: .green
            ) {
                animateSwipe(.keep)
            }
        }
        .opacity(viewModel.currentPhoto == nil || viewModel.isLoading ? 0.45 : 1.0)
        .disabled(viewModel.currentPhoto == nil || viewModel.isLoading)
    }
    
    private var photoAccessView: some View {
        VStack(spacing: 14.0.scaled) {
            Image(systemName: "photo.badge.exclamationmark")
                .foregroundStyle(.color1)
                .font(.system(size: 42.0.scaled, weight: .semibold))
            
            Text("Allow Photo Access")
                .foregroundStyle(.color1)
                .font(.system(size: 20.0.scaled, weight: .bold))
            
            Text("Open Settings to let PhotoCleaner show and delete photos you mark during a swipe session.")
                .foregroundStyle(.color1.opacity(0.72))
                .font(.system(size: 15.0.scaled, weight: .regular))
                .multilineTextAlignment(.center)
            
            Button("Open Settings") {
                guard
                    let url = URL(string: UIApplication.openSettingsURLString)
                else { return }
                
                UIApplication.shared.open(url)
            }
            .buttonStyle(.glass)
        }
        .padding(24.0.scaled)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyPhotosView: some View {
        ContentUnavailableView(
            "No Photos",
            systemImage: "photo.stack",
            description: Text("There are no photos available for this swipe session.")
        )
        .foregroundStyle(.color1)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var sessionCompleteView: some View {
        VStack(spacing: 14.0.scaled) {
            Image(systemName: "checkmark.seal.fill")
                .foregroundStyle(.green)
                .font(.system(size: 52.0.scaled, weight: .semibold))
            
            Text("Session Complete")
                .foregroundStyle(.color1)
                .font(.system(size: 22.0.scaled, weight: .bold))
            
            Text("Finish the session to choose what happens with photos marked for deletion.")
                .foregroundStyle(.color1.opacity(0.72))
                .font(.system(size: 15.0.scaled, weight: .regular))
                .multilineTextAlignment(.center)
        }
        .padding(24.0.scaled)
        .frame(maxWidth: .infinity, minHeight: 470.0.scaled)
        .swipeGlassSurface(cornerRadius: CGFloat(28.0.scaled))
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
    
    /*
     MARK: - Private methods
     */
    
    private func handleDragEnd(
        translation: CGSize
    ) {
        if translation.width <= -110.0.scaled {
            animateSwipe(.delete)
        } else if translation.width >= 110.0.scaled {
            animateSwipe(.keep)
        } else {
            dragOffset = .zero
        }
    }
    
    private func animateSwipe(
        _ direction: SwipeDirection
    ) {
        guard
            viewModel.currentPhoto != nil,
            !isAnimatingSwipe
        else { return }
        
        isAnimatingSwipe = true
        
        let horizontalOffset = direction == .delete ? -620.0.scaled : 620.0.scaled
        
        withAnimation(.easeIn(duration: 0.18)) {
            dragOffset = CGSize(
                width: horizontalOffset,
                height: dragOffset.height
            )
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            switch direction {
            case .delete:
                viewModel.markCurrentPhotoForDeletion()
            case .keep:
                viewModel.keepCurrentPhoto()
            }
            
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
            VStack(spacing: 6.0.scaled) {
                Image(systemName: systemImage)
                    .font(.system(size: 24.0.scaled, weight: .semibold))
                
                Text(title)
                    .font(.system(size: 13.0.scaled, weight: .semibold))
            }
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity)
            .frame(height: 68.0.scaled)
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
