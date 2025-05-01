//
//  TimelineView.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/28.
//

import SwiftUI

struct Timeline: View {
  let events: [Focus]
  
  init(_ events: [Focus] = []) {
    self.events = events
  }
  
  var body: some View {
    GeometryReader {
      let size = $0.size
      ScrollView {
        VStack(spacing: 0) {
          ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
            TimelineItem(event, isLast: index == events.count - 1)
              .transition(.asymmetric(
                insertion: .offset(y: 30).combined(with: .opacity),
                removal: .opacity
              ))
              .animation(.easeOut(duration: 0.5).delay(Double(index) * 0.05))
              .frame(width: max(size.width - 32, 0), height: 160)
              .frame(maxWidth: .infinity)
          }
        }
        .padding()
      }
    }
  }
}

struct TimelineItem: View {
  let event: Focus
  var isLast: Bool = false
  
  @State private var showInput = false
  @State private var notes: String = ""
  @FocusState private var isFocused: Bool
  
  init(_ event: Focus, isLast: Bool) {
    self.event = event
    self.isLast = isLast
  }
  
  var body: some View {
    HStack(alignment: .top, spacing: 0) {
      VStack(spacing: 0) {
        let ringSize: CGFloat = 12
        Circle()
          .stroke(event.completedSecondsCount == FocusKit.shared.totalSeconds ? .black : .red, lineWidth: 2)
          .frame(width: ringSize, height: ringSize)
          .zIndex(1)
        
        if !isLast {
          Rectangle()
            .stroke(Color.slate200, style: .init(lineWidth: 1, dash: [10]))
            .frame(width: 0.5)
            .frame(maxHeight: .infinity)
        }
      }
      .frame(width: 30)
      
      VStack(alignment: .leading, spacing: 8) {
        HStack {
          Text("\(event.startedAt.format("HH:mm"))-\(event.endedAt.format("HH:mm"))")
            .font(.system(size: 16, weight: .semibold))
          
          Spacer()
          
          HStack(spacing: 4) {
            Text(Tools.formatSeconds(event.completedSecondsCount))
              .foregroundColor(.secondary)
          }
        }
        .offset(y: -4)
        
        if let label = event.label {
          VStack(alignment: .leading, spacing: 12) {
            HStack {
              Text(label.name)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.black)
              
              Spacer()
              
              Button() {
                notes = event.notes
                showInput = true
              } label: {
                Image(systemName: "square.and.pencil")
                  .foregroundColor(.gray)
              }
              .modalView(isPresented: $showInput) {
                ModalView(
                  style: .init(
                    content: "",
                    cornerRadius: 28,
                    foregroundColor: .gray,
                    backgroundColor: .white
                  ),
                  confirm: .init(
                    content: "Save",
                    cornerRadius: 16,
                    foregroundColor: .white,
                    backgroundColor: .black,
                    action: {
                      event.notes = notes
                      showInput = false
                    }
                  )
                ) {
                  TextEditor(text: $notes)
                    .focused($isFocused)
                    .frame(height: 240)
                    .scrollContentBackground(.hidden)
                    .background(Color.slate50)
                    .cornerRadius(20)
                    .onAppear {
                      DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isFocused = true
                      }
                    }
                    .onDisappear {
                      DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isFocused = false
                      }
                    }
                }
              }
            }
            
            Text(event.notes)
              .foregroundColor(.gray)
              .font(.system(size: 16))
          }
          .padding(12)
          // .background(Color(hex: label.backgroundColor))
          .background(Color.slate50)
          .cornerRadius(16)
        }
      }
    }
    .onAppear {
      notes = event.notes
    }
  }
}

import SwiftData
struct TimelinePreviewView: View {
  @Query var events: [Focus]
  
  var body: some View {
    Timeline(events)
  }
}

#Preview {
  TimelinePreviewView()
    .modelContainer(for: [
      Focus.self,
      FocusLabel.self,
    ])
}
