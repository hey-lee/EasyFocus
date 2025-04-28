//
//  WeekSlider.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/28.
//

import SwiftUI

struct WeekSlider: View {
  @Binding var date: Date
//  @State private var currentDate: Date = Date()
  @State private var weekSlider: [[Date.WeekDay]] = []
  @State private var currentWeekIndex: Int = 1
  @State private var createWeek: Bool = false
  
  @Namespace private var animation
  
  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      HeaderView()
    }
    .vLayout(.top)
    .onAppear {
      if weekSlider.isEmpty {
        let currentWeek = Date().fetchWeek()
        
        if let firstDate = currentWeek.first?.date {
          weekSlider.append(firstDate.createPrevWeek())
        }
        
        weekSlider.append(currentWeek)
        
        if let lastDate = currentWeek.last?.date {
          weekSlider.append(lastDate.createNextWeek())
        }
        
      }
    }
  }
  
  @ViewBuilder
  func HeaderView() -> some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Text(date.format("MMMM"))
          .foregroundStyle(.blue)
        Text(date.format("YYYY"))
          .foregroundStyle(.gray)
      }
      .font(.title.bold())
      
      Text(date.formatted(date: .complete, time: .omitted))
        .font(.callout)
        .fontWeight(.semibold)
        .textScale(.secondary)
        .foregroundStyle(.gray)
      
      TabView(selection: $currentWeekIndex) {
        ForEach(weekSlider.indices, id: \.self) { index in
          let week = weekSlider[index]
          WeekView(week)
            .padding(.horizontal, 16)
            .tag(index)
        }
      }
      .padding(.horizontal, -16)
      .tabViewStyle(.page(indexDisplayMode: .never))
      .frame(height: 100)
    }
    .padding()
    .hLayout(.leading)
    .background(.white)
    .onChange(of: currentWeekIndex) { oldValue, newValue in
      if newValue == 0 || newValue == (weekSlider.count - 1) {
        createWeek = true
      }
    }
  }
  
  @ViewBuilder
  func WeekView(_ week: [Date.WeekDay]) -> some View {
    HStack(spacing: 0) {
      ForEach(week) { day in
        VStack(spacing: 8) {
          Text(day.date.format("E"))
            .font(.callout)
            .fontWeight(.medium)
            .textScale(.secondary)
            .foregroundStyle(.gray)
          
          Text(day.date.format("dd"))
            .font(.callout)
            .fontWeight(.medium)
            .textScale(.secondary)
            .foregroundStyle(day.date.isEqualTo(date) ? .white : .gray)
            .frame(width: 36, height: 36)
            .background {
              if day.date.isEqualTo(date) {
                Circle()
                  .fill(.black)
                  .matchedGeometryEffect(id: "TABINDICATOR", in: animation)
              }
              if day.date.isToday {
                Circle()
                  .fill(.black)
                  .frame(width: 6, height: 6)
                  .vLayout(.bottom)
                  .offset(y: 12)
              }
            }
            .background(.white.shadow(.drop(radius: 1)), in: .circle)
        }
        .hLayout(.center)
        .contentShape(.rect)
        .onTapGesture {
          withAnimation(.snappy) {
            date = day.date
          }
        }
      }
    }
    .background {
      GeometryReader {
        let minX = $0.frame(in: .global).minX
        
        Color.clear
          .preference(key: OffsetKey.self, value: minX)
          .onPreferenceChange(OffsetKey.self) { value in
            // When the offset reaches 15 and if the createWeek is toggled then simply generating next set of week
            if value.rounded() == 16 && createWeek {
              paginateWeek()
              createWeek = false
            }
          }
      }
    }
  }
  
  func paginateWeek() {
    // safe check
    if weekSlider.indices.contains(currentWeekIndex) {
      if let firstDate = weekSlider[currentWeekIndex].first?.date, currentWeekIndex == 0 {
        weekSlider.insert(firstDate.createPrevWeek(), at: 0)
        weekSlider.removeLast()
        currentWeekIndex = 1
      }
      if let lastDate = weekSlider[currentWeekIndex].last?.date, currentWeekIndex == (weekSlider.count - 1) {
        weekSlider.append(lastDate.createNextWeek())
        weekSlider.removeFirst()
        currentWeekIndex = weekSlider.count - 2
      }
    }
  }
}

#Preview {
  struct PreviewView: View {
    @State var date: Date = Date()
    
    var body: some View {
      VStack {
        WeekSlider(date: $date)
      }
      .onChange(of: date, { oldValue, newValue in
        print(date.format("yyyy-MM-dd HH:mm:ss"))
      })
      .background(ThemeKit.theme.backgroundColor)
    }
  }
  
  return PreviewView()
}
