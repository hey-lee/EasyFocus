//
//  HomeView.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/22.
//

import SwiftUI
import Shimmer

struct FocusView: View {
  @Environment(FocusKit.self) var focus
  @Environment(TagsKit.self) var tagsKit
  @EnvironmentObject var show: ShowKit
  
  @State var showSettings = false
  @State var showWheelSlider = false
  
  var body: some View {
    VStack {
      VStack(spacing: 0) {
        focusView
        
        if focus.state == .running {
          if !focus.isForwardMode {
            sessionsView
          }
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
            Tools.haptic()
            withAnimation {
              focus.start()
            }
          }
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .overlay {
      if focus.state == .running {
        LongTapView {
          withAnimation {
            if focus.isForwardMode {
              self.focus.stop()
            } else {
              if self.focus.percent != 0 {
                self.focus.stop()
              }
            }
          }
        }
      }
    }
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
      Group {
        Text(focus.display.minutes)
        VStack {
          let size: CGFloat = focus.state != .idle ? 20 : 16
          Circle()
            .frame(width: size, height: size)
          Circle()
            .frame(width: size, height: size)
        }
        Text(focus.display.seconds)
      }
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
      WheelSlider(value: .init(
        get: { CGFloat(focus.minutes) },
        set: {
          focus.minutes = Int($0)
        }
      ), config: .init(
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
            self.showWheelSlider = false
          }
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.white)
  }
}

#Preview {
  FocusView()
    .environment(TagsKit())
    .environment(FocusKit())
    .environmentObject(ShowKit())
}
