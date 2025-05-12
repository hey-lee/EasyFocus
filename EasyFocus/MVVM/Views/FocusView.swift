//
//  HomeView.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/22.
//

import SwiftUI
import Shimmer

struct FocusView: View {
  @Environment(\.modelContext) var context
  @Environment(DBKit.self) var db
  @Environment(TagsKit.self) var tagsKit
  @Environment(FocusService.self) var focusService
  @Environment(ModalKit.self) var modalKit
  @EnvironmentObject var nav: NavKit
  @EnvironmentObject var show: ShowKit
  @EnvironmentObject var stack: Stackit
  
  @AppStorage("enableCalendarSync") var enableCalendarSync = false
  
  @State var showModalView: Bool = false
  
  var body: some View {
    NavigationStack(path: $stack.settings) {
      VStack {
        VStack(spacing: 0) {
          focusView
          
          if case .running = focusService.state {
            if focusService.mode == .rest {
              Symbol("sf.cup.and.saucer")
            } else {
              if focusService.timer.mode == .countdown {
                sessionsView
              }
            }
          }
          if case .idle = focusService.state, focusService.mode == .work, focusService.sessions.completedCount == 0 {
            tagView
          }
        }
        
        if case .idle = focusService.state {
          Group {
            if focusService.sessions.completedCount == 0 {
              Text("Start Focus")
                .onTapGesture {
                  Tools.haptic()
                  focusService.createFocusModel()
                  AppControlsKit.shared.startShield()
                  withAnimation {
                    focusService.start()
                  }
                }
            } else {
              Text(focusService.mode == .work ? "Continue" : "Take a rest")
                .onTapGesture {
                  withAnimation {
                    focusService.start()
                    Tools.haptic()
                  }
                }
            }
          }
          .font(.custom("Code Next ExtraBold", size: 18))
          .foregroundStyle(.white)
          .padding()
          .background(.black)
          .clipShape(Capsule())
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .toolbar {
        if case .idle = focusService.state {
          ToolbarItem(placement: .topBarLeading) {
            Symbol("sf.chart.bar.fill")
              .onTapGesture {
                // stack.settings.append("stats")
                show.StatsView = true
              }
          }
          ToolbarItem(placement: .topBarLeading) {
            Symbol("sf.calendar")
              .onTapGesture {
                // stack.settings.append("stats")
                show.TimelineView = true
              }
          }
          ToolbarItem(placement: .topBarLeading) {
            Text("VIP")
              .onTapGesture {
                show.ProView = true
              }
          }
          ToolbarItem(placement: .topBarTrailing) {
            Symbol("sf.ellipsis")
              .onTapGesture {
                stack.settings.append("settings")
              }
          }
        }
      }
      .overlay {
        if case .running = focusService.state {
          LongTapView {
            withAnimation {
              if focusService.timer.mode == .forward {
                self.focusService.stop()
              } else {
                if self.focusService.progress != 0 {
                  self.focusService.stop()
                }
              }
            }
          }
        }
      }
      .overlay {
        if show.WheelSliderView {
          WheelSliderView()
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
      .fullScreenCover(isPresented: $show.StatsView) {
        StatsView()
      }
      .fullScreenCover(isPresented: $show.ProView) {
        ProductsView()
      }
      .fullScreenCover(isPresented: $show.TimelineView) {
        TimelineView()
      }
      .onChange(of: show.ProView, { oldValue, newValue in
        print("show.ProView", show.ProView)
      })
      .onChange(of: tagsKit.modelLabel) { oldValue, newValue in
        if let label = tagsKit.modelLabel, let focus = focusService.focusModel {
          focus.label = label
        }
      }
      .task {
        focusService.updateDuration()
        focusService.onStageChange { stage in
          print("onStageChange", stage)
          switch stage {
          case .willTransition(from: .running, to: .idle):
            focusService.updateFocusModel()
            if let focusModel = focusService.focusModel {
              Task {
                do {
                  if enableCalendarSync {
                    focusModel.calendarEventID = try await CalendarKit.shared.addFocusToCalendar(focusModel)
                  }
                  context.insert(focusModel)
                  try context.save()
                  print("focus.saved")
                } catch let error {
                  print("focus model save error", error)
                }
              }
            }
          case .didTransition(to: .idle):
            AppControlsKit.shared.stopShield()
          default: break
          }
        }
      }
      .modalView(isPresented: $showModalView) {
        ModalView(
          title: "Congrets",
          style: .init(
            content: "",
            cornerRadius: 28,
            foregroundColor: .gray,
            backgroundColor: .white
          ),
          confirm: .init(
            content: "Take a break",cornerRadius: 16,
            foregroundColor: .white,
            backgroundColor: .black,
            action: {
              print("take a break")
              focusService.start()
              showModalView = false
            }
          )
        )
      }
      .navigationDestination(for: String.self) { key in
        switch key {
        case "stats":
          StatsView()
        case "settings":
          SettingsView()
        case "icloud.sync":
          iCloudSyncView()
        default:
          PageView()
        }
      }
    }
  }
  
  var focusView: some View {
    HStack(spacing: 8) {
      Group {
        Text(focusService.display.minutes)
        VStack {
          let size: CGFloat = focusService.state != .idle() ? 20 : 16
          Circle()
            .frame(width: size, height: size)
          Circle()
            .frame(width: size, height: size)
        }
        Text(focusService.display.seconds)
      }
      .tracking(-4)
      .font(.custom("Code Next ExtraBold", size: UIDevice.current.orientation.isLandscape ? 200 : (focusService.state == .idle()) ? 80 : 100).monospacedDigit())
    }
    .onTapGesture {
      Tools.haptic()
      withAnimation {
        if case .idle = focusService.state {
          show.WheelSliderView = true
        }
      }
    }
  }
  
  @ViewBuilder
  var tagView: some View {
    if let label = tagsKit.modelLabel {
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
      ForEach(0...focusService.sessions.totalCount - 1, id: \.self) { index in
        ZStack {
          Circle()
            .stroke(Color.black, lineWidth: 4)
            .frame(width: 20, height: 20)
          Circle()
            .trim(from: 0, to: focusService.getSessionProgress(index))
            .stroke(Color.black, lineWidth: 10)
            .frame(width: 10, height: 10)
            .animation(.linear(duration: 0.5), value: focusService.progress)
        }
      }
    }
    .padding()
  }
}

#Preview {
  FocusView()
    .environment(DBKit())
    .environment(TagsKit())
    .environment(FocusKit())
    .environment(FocusService())
    .environment(ModalKit.shared)
    .environmentObject(NavKit())
    .environmentObject(ShowKit())
    .environmentObject(Stackit())
    .modelContainer(for: [
      Focus.self,
    ])
}
