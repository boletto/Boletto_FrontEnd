//
//  PastTicketDetailView.swift
//  Boleto
//
//  Created by Sunho on 9/7/24.
//

import SwiftUI
import ComposableArchitecture

struct PastTicketDetailView: View {
    @Bindable var store: StoreOf<PastTicketDeatilFeature>
    var body: some View {
        VStack {
            
            HStack {
                Spacer()
                NumsParticipantsView(personNum: store.ticket.participant.count)
            }
       
            TicketView(ticket: store.ticket)
        }
        .padding(.horizontal, 32)
        .applyBackground(color: .background)
//        .toolbar {
//            ToolbarItem(placement: ., content: <#T##() -> View#>)
//        }
//        .navigationBarTitleDisplayMode(.inline)
    }
}

//#Preview {
//    NavigationStack {
//        PastTicketDetailView(ticket: Ticket(departaure: "Seoul", arrival: "Busan", startDate: "2024.1.28", endDate: "2024.04.12", participant: [Person(image: "beef3", name: "강병호"),Person(image: "beef1", name: "김수민"),Person(image: "beef2", name: "하잇"),Person(image: "beef4", name: "면답"), Person(image: "beef2", name: "호잇")], keywords: [.activity,.exercise]))
//    }
//}
