//
//  PastTravelView.swift
//  Boleto
//
//  Created by Sunho on 9/5/24.
//

import SwiftUI
import ComposableArchitecture

struct MainTravelTicketsView: View {
    @Bindable var store: StoreOf<MainTravelTicketsFeature>
    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                HStack {
                    Text("진행 중인 여행")
                        .foregroundStyle(.white)
                        .customTextStyle(.subheadline)
                    Spacer()
                }
                if let currentTicket = store.currentTicket {
                    SwipalbleTicketCell(ticket: currentTicket, onAccpet: {
                        store.send(.touchTicket(currentTicket))
                    }, onDelete: {
                        store.send(.confirmDeletion(currentTicket))
                    }, invitedMode: false)
                } else {
                    Button {
                        store.send(.touchAddTravel)
                    } label: {
                        
                        addTicketCell
                    }
                }
                   
                ScrollView {
                    if !store.futureTickets.isEmpty {
                        futureTravelsSection
                            .padding(.bottom,25)
                    }
                    if !store.completedTickets.isEmpty {
                        completedTravelSection
                    }
                }.scrollIndicators(.hidden)
                    .padding(.top, 16)
            }.padding(.horizontal,32)
        }
        .alert($store.scope(state: \.alert, action: \.alert))
    }
    var addTicketCell: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(.gray1)
                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [7]))
                .foregroundStyle(.gray2)
            VStack(spacing: 0) {
                ZStack {
                    Circle().fill(.main)
                        .frame(width: 42,height: 42)
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 21,height: 21)
                        .foregroundStyle(.gray1)
                }
                    .padding(.bottom, 19)
                Text("여행 추가해 추억을 기록해보세요!")
                    .foregroundStyle(.gray4)
                    .customTextStyle(.small)
            }
        }.frame(width: 329,height: 141)
    }
    private var futureTravelsSection: some View {
        VStack(alignment: .leading) {
            Text("예정된 여행 \(store.futureTickets.count)개")
                .font(.headline)
                .foregroundStyle(.white)
            ForEach(store.futureTickets) {ticket in
                SwipalbleTicketCell(ticket: ticket, onAccpet: {
                    store.send(.touchTicket(ticket))
                }, onDelete: {
                    store.send(.confirmDeletion(ticket))
                }, invitedMode: false).padding(.bottom,10)
            }
        }
    }
    private var completedTravelSection: some View {
        VStack(alignment: .leading) {
            Text("완료된 여행 \(store.completedTickets.count)개")
                .font(.headline)
                .foregroundStyle(.white)
            ForEach(store.completedTickets) {ticket in
                SwipalbleTicketCell(ticket: ticket, onAccpet: {
                    store.send(.touchTicket(ticket))
                }, onDelete: {
                    store.send(.confirmDeletion(ticket))
                }, invitedMode: false).padding(.bottom,10)
            }
        }}
}

#Preview {
    MainTravelTicketsView(store: .init(initialState: MainTravelTicketsFeature.State()) {
        MainTravelTicketsFeature()
    })
    .applyBackground(color: .background)
}
