//
//  HomeView.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/22.
//

import SwiftUI
import Shimmer

struct FocusView: View {
  @Environment(\.scenePhase) var phase
  @Environment(FocusKit.self) var focus
  @Environment(TagsKit.self) var tagsKit
  
  @EnvironmentObject var show: ShowKit
  
  @State var onTouching = false
  @State var showSettings = false
  @State var showWheelSlider = false
  @State var progress: CGFloat = 0
  @State var progressTimer: Timer?
  
  var body: some View {
    VStack {
      VStack(spacing: 0) {
        focusView
        
        if focus.state == .running {
          sessionsView
        } else {
          tagView
        }
      }
      
      if focus.state == .idle {
        Text(focus.mode == .work ? "Start Focus" : "Take a rest")
          .font(.custom("Code Next ExtraBold", size: 18))
          .foregroundStyle(.white)
          .padding()
          .background(.black)
          .clipShape(Capsule())
          .onTapGesture {
            withAnimation {
              focus.start()
            }
            
            Tools.haptic()
          }
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(LongTapArea())
    .overlay(LongTapProgressView())
    .overlay {
      if showWheelSlider {
        wheelSliderView
      }
    }
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Symbol("sf.gearshape.fill")
          .onTapGesture {
            self.showSettings = true
          }
      }
    }
    .sheet(isPresented: $show.tags) {
      TagsView()
        .presentationDetents([
          .medium,
        ])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(32)
    }
  }
  
  var focusView: some View {
    HStack(spacing: 8) {
      Text(focus.display.minutes)
        .tracking(-4)
        .font(.custom("Code Next ExtraBold", size: UIDevice.current.orientation.isLandscape ? 200 : (focus.state == .idle) ? 80 : 100).monospacedDigit())
      VStack {
        let size: CGFloat = focus.state != .idle ? 20 : 16
        Circle()
          .frame(width: size, height: size)
        Circle()
          .frame(width: size, height: size)
      }
      Text(focus.display.seconds)
        .tracking(-4)
        .font(.custom("Code Next ExtraBold", size: UIDevice.current.orientation.isLandscape ? 200 : (focus.state == .idle) ? 80 : 100).monospacedDigit())
    }
    .onTapGesture {
      Tools.haptic()
      withAnimation {
        if focus.state == .idle {
          self.showWheelSlider = true
        }
      }
    }
  }
  
  @ViewBuilder
  var tagView: some View {
    if let label = tagsKit.label {
      HStack {
        Text(label.name)
          .font(.custom("Code Next ExtraBold", size: 24))
        Image(systemName: "chevron.compact.right")
      }
      .onTapGesture {
        show.tags = true
      }
    }
  }
  
  var sessionsView: some View {
    HStack(spacing: 16) {
      ForEach(1...focus.sessionsCount, id: \.self) { index in
        ZStack {
          Circle()
            .stroke(Color.black, lineWidth: 4)
            .frame(width: 20, height: 20)
          Circle()
            .trim(from: 0, to: focus.getSessionProgress(index))
            .stroke(Color.black, lineWidth: 10)
            .frame(width: 10, height: 10)
            .animation(.linear(duration: 0.5), value: focus.percent)
        }
      }
    }
    .padding()
  }
  
  var wheelSliderView: some View {
    VStack {
      WheelSlider(value: Binding(
        get: { CGFloat(focus.minutes) },
        set: {
          focus.minutes = Int($0)
          //            UserDefaults.standard.set(Int($0), forKey: "minutes")
        }
      ), config: WheelSlider.Config(
        count: 12,
        showIndicator: true
      ))
      .frame(height: 180)
      
      Text("Done")
        .font(.custom("Code Next ExtraBold", size: 18))
        .foregroundStyle(.white)
        .padding()
        .background(.black)
        .clipShape(Capsule())
        .onTapGesture {
          withAnimation {
            //            self.lockSwitch = false
            self.showWheelSlider = false
          }
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.white)
  }
  
  @ViewBuilder
  func LongTapProgressView() -> some View {
    if focus.state == .running {
      if onTouching {
        VStack {
          ZStack(alignment: .leading) {
            let size: CGSize = CGSize(width: 200, height: 4)
            RoundedRectangle(cornerRadius: size.height / 2, style: .continuous)
              .fill(.black.opacity(0.2))
              .frame(width: size.width, height: size.height)
            
            RoundedRectangle(cornerRadius: size.height / 2, style: .continuous)
              .fill(.black.opacity(0.8))
              .frame(width: size.width * progress, height: size.height)
          }
          .padding(.top, 240)
        }
      }
      
      Text("长按退出")
        .font(.body)
        .shimmering()
        .foregroundColor(onTouching ? Color.slate900 : Color.slate300)
        .padding(.top, 300)
    }
  }
  
  @ViewBuilder
  func LongTapArea() -> some View {
    Color.white
      .opacity(0.001)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .clipShape(Rectangle())
      .gesture(
        DragGesture(minimumDistance: 0)
          .onChanged { gesture in
            if !self.onTouching {
              if focus.state == .running {
                Tools.haptic()
              }
              withAnimation {
                self.onTouching = true
              }
            }
          }
          .onEnded { _ in
            withAnimation(.linear(duration: 0.1)) {
              self.onTouching = false
            }
          }
      )
      .onChange(of: onTouching) { oldValue, newValue in
        if onTouching && focus.state == .running {
          progressTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true, block: { _ in
            if progress <= 1 {
              progress += 0.04
            } else {
              if self.focus.percent != 0 {
                self.focus.stop()
              }
            }
          })
        } else {
          progress = 0
          progressTimer?.invalidate()
          progressTimer = nil
        }
      }
      .onChange(of: phase) { oldValue, newValue in
        if phase != .active {
          onTouching = false
        }
      }
  }
}

#Preview {
  FocusView()
    .environment(TagsKit())
    .environment(FocusKit())
    .environmentObject(ShowKit())
}
