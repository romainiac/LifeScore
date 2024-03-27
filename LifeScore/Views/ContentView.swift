//
//  ContentView.swift
//  LifeScore
//
//  Created by Roman Yefimets on 3/20/24.
//

import SwiftUI
import SwiftData
import Combine
struct ContentView: View {
    @State private var isShowingItemSheet = false
    @State private var eventToEdit: LifeEvent?
    @Environment(\.modelContext) var context
    @Query(sort: [SortDescriptor(\LifeEvent.timestamp, order: .reverse)]) private var events: [LifeEvent]

    var body: some View {
        NavigationStack {
            List {
                ForEach(events) {event in LifeEventCell(event: event)
                        .onTapGesture {
                        eventToEdit = event
                        }
                    }
                    .onDelete(perform: deleteItems)


            }
            .sheet(isPresented: $isShowingItemSheet, content: {
                AddEventSheet()
            })
            .sheet(item: $eventToEdit) { event in
                UpdateEventSheet(event: event)
                
            }
            .toolbar {
                ToolbarItemGroup(placement: .automatic) {
                    Button("Add", systemImage: "plus") {
                        isShowingItemSheet = true
                    }
                }
            }
            .overlay {
                if events.isEmpty {
                    ContentUnavailableView(label: {
                        Label( "No Events", systemImage: "list.bullet.rectangle.portrait")
                    })
                }
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                context.delete(events[index])
            }
        }
    }

}

struct LifeEventCell: View {
    
    let event: LifeEvent
    
    var body: some View {
        HStack {
            Text(event.timestamp, format: .dateTime.month(.abbreviated).day())
            Spacer()
            Text(event.title)
            Spacer()
            Text(event.score, format: .number)
        }
    }
}

struct AddEventSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) var context
    @State private var title: String = ""
    @State private var score: Double = 0.0
    @State private var date: Date = .now
    var body: some View {
        NavigationStack {
            Form {
                TextField("Event Name", text: $title)
                TextField("Score", value: $score, format: .number).keyboardType(.numbersAndPunctuation)
                DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
            }
            .navigationTitle("New Event")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Save") {
                        let event = LifeEvent(title: title, timestamp: date, score: score)
                        context.insert(event)
                        dismiss()
                    }
                }
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("Cancel") {dismiss()}
                }

            }
            
        }
    }
}

struct UpdateEventSheet: View {
    @Bindable var event: LifeEvent
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) var context
    @State private var title: String = ""
    @State private var score: Double = 0.0
    @State private var date: Date = .now
    var body: some View {
        NavigationStack {
            Form {
                TextField("Event Name", text: $event.title)
                TextField("Score", value: $event.score, format: .number).keyboardType(.numbersAndPunctuation)
                DatePicker("Date", selection: $event.timestamp, displayedComponents: [.date, .hourAndMinute])
            }
            .navigationTitle("Update Event")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Done") {dismiss()}
                }

            }
            
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: LifeEvent.self, inMemory: true)
}
