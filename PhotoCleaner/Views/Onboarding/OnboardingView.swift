//
//  OnboardingView.swift
//  PhotoCleaner
//
//  Created by Alexey Kurto on 24.09.25.
//

import SwiftUI
import RealmSwift
import Lottie

struct OnboardingView: View {
    
    /*
     MARK: - Properties
     */
    
    @StateObject
    private var viewModel = OnboardingViewModel()
    
    /*
     MARK: - Body
     */
    
    var body: some View {
        GeometryReader { geometryProxy in
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(spacing: 32.0.scaled) {
                    OnboardingPageView(
                        state: viewModel.state,
                        finishAction: {
                            viewModel.currentPageIndex = 4
                        }
                    )
                    .frame(width: geometryProxy.size.width)
                    .id(viewModel.currentPageIndex)
                    
                    ProgressCapsuleView(progress: Double(viewModel.state.rawValue) / Double(OnboardingState.allCases.count))
                        .frame(width: 200.0.scaled, height: 8.0.scaled)
                    
                    Button(action: {
                        viewModel.updateState()
                    }) {
                        Text(viewModel.state.buttonTitle)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.color1)
                            .frame(height: 52.0.scaled)
                            .frame(maxWidth: .infinity)
                            .cornerRadius(12.0.scaled)
                    }
                    .buttonStyle(.glass)
                    .padding(.bottom, 32.0.scaled)
                    .padding(.horizontal, 16.0.scaled)
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
            }
            .scrollDisabled(true)
            .background(
                Image("SplashBackground")
                    .resizable()
                    .ignoresSafeArea()
            )
            .edgesIgnoringSafeArea(.bottom)
        }
        .animation(
            .easeInOut(duration: 0.2),
            value: viewModel.state
        )
        .frame(maxHeight: .infinity)
        .edgesIgnoringSafeArea(.bottom)
        .background(.color2)
    }
}

private struct OnboardingPageView: View {
    
    /*
     MARK: - Properties
     */
    
    var state: OnboardingState
    var finishAction: (() -> Void)?
    
    /*
     MARK: - Body
     */
    
    var body: some View {
        VStack(spacing: 48.0.scaled) {
            Image(state.imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
            
            VStack(spacing: 8.0.scaled) {
                Text(state.title)
                    .foregroundStyle(.color1)
                    .font(.system(size: 28.0.scaled, weight: .bold))
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                
                Text(state.description)
                    .foregroundStyle(.color10)
                    .font(.system(size: 15.0.scaled, weight: .regular))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 16.0.scaled)
        }
    }
}

struct ProgressCapsuleView: View {
    
    /*
     MARK: - Properties
     */
    
    let progress: Double
    
    /*
     MARK: - Body
     */
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            
            Capsule()
                .fill(.color1.opacity(0.1))
                .overlay(
                    Capsule()
                        .fill(.color1)
                        .frame(width: max(25, width * progress)),
                    alignment: .leading
                )
        }
    }
}

struct SearchingProgressCounterView: View {
    
    /*
     MARK: - Properties
     */
    
    let finishAction: () -> Void
    
    @State
    private var progress: Double = 0.0
    
    private let step = 0.1
    private let duration = 5.0
    
    /*
     MARK: - Body
     */
    
    var body: some View {
        Text("\(Int(progress))%")
            .foregroundStyle(.color1)
            .font(.system(size: 36.0.scaled, weight: .bold))
            .onAppear {
                var currentStepValue: Double = 0.0
                
                Timer.scheduledTimer(
                    withTimeInterval: step,
                    repeats: true
                ) { timer in
                    currentStepValue += step
                    let value = min(currentStepValue / duration * 100.0, 100.0)
                    progress = value
                    
                    guard
                        value >= 100
                    else { return }
                    
                    timer.invalidate()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        finishAction()
                    }
                }
            }
    }
}

#Preview {
    OnboardingView()
}
