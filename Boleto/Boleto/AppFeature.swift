//
//  AppFeature.swift
//  Boleto
//
//  Created by Sunho on 9/7/24.
//

import SwiftUI
import ComposableArchitecture
import CoreLocation
import UserNotifications
import AuthenticationServices

@Reducer
struct AppFeature {
    @ObservableState
    struct State {
        var pastTravel: MainTravelTicketsFeature.State = .init()
        var loginState: LoginFeature.State = .init()
        var path =  StackState<Destination.State>()
        @Shared(.appStorage("isMonitoring")) public var isMonitoring = false
        @Shared(.appStorage("destination")) var currentMonitoredSpot: Spot?
        @Shared(.appStorage("isLogin")) var isLogin: Bool = false
        var isNotificationEnabled = false
        var monitoringEvents: [MonitorEvent] = []
        var currentLogin: Bool = false
//        init() {
//            self.currentLogin = isLogin
//        }
        
        
    }
    @Reducer(state: .equatable)
    enum Destination {
        case notifications(NotificationFeature)
        case detailEditView(DetailTravelFeature)
        case addticket(AddTicketFeature)
        case myPage(MyPageFeature)
        case editProfile(MyProfileFeature)
        case mySticker(MyStickerFeature)
        case myPhotos(MyphotoFeature)
        case friendLists(MyFriendListsFeature)
        case invitedTravel(MyInvitedFeature)
        case frameNotificationView(FrameNotificationFeature)
        case badgeNotificationView(BadgeNotificationFeature)
    }
    
    enum Action {
        case pastTravel(MainTravelTicketsFeature.Action)
        case login(LoginFeature.Action)
        case tabNotification
        case sendToFrameView
        case sendToBadgeView
        case tabmyPage
        case path(StackActionOf<Destination>)
        case popAll
        case requestLocationAuthorizaiton
        case authorizationResponse(CLAuthorizationStatus?)
        case toggleMonitoring(Spot)
        case monitoringEvent(MonitorEvent)
//        case scheduleNotification(Spot)
        case toggleNoti(Bool)
        
    
        
        
    }
    @Dependency(\.locationClient) var locationClient
    var body: some ReducerOf<Self> {
        Scope(state: \.pastTravel, action: \.pastTravel) {
            MainTravelTicketsFeature()
        }
        Scope(state:\.loginState, action: \.login) {
            LoginFeature()
        }
        Reduce { state, action in
            switch action {
            case let .path(action):
                switch action {
                case .element(id: _, action: .myPage(.profileTapped)):
                    state.path.append(.editProfile(MyProfileFeature.State()))
                    return .none
                case .element(id: _, action: .myPage(.invitedTravelsTapped)):
                    state.path.append(.invitedTravel(MyInvitedFeature.State()))
                    return .none
                case .element(id: _, action: .myPage(.stickersTapped)):
                    state.path.append(.mySticker(MyStickerFeature.State()))
                    return .none
                case .element(id: _, action: .addticket(.tapbackButton)):
                    state.path.popLast()
                    return .none
                case .element(id: _, action: .addticket(.successTicket)):
                    state.path.popLast()
                    //그리고 다시 리프레쉬 기능 해야함 여기서
                    return .none
                case .element(id: let id, action: .detailEditView(.touchEditView)):
                    if case let .detailEditView(detailState) = state.path[id: id] {
                          state.path.append(.addticket(AddTicketFeature.State(mode: .edit(detailState.ticket))))
                      }
                      return .none
                case .element(id: _, action: .myPage(.goLoginView)):
                    state.path.removeAll()
                    state.currentLogin = false
                    state.isLogin = false
                    return .none
                default:
                    return .none
                }
            case .sendToBadgeView:
             
                state.path.append(.badgeNotificationView(BadgeNotificationFeature.State()))
                return .none
            case .sendToFrameView:
                state.path.append(.frameNotificationView(FrameNotificationFeature.State()))
                return .none
            case .pastTravel(.touchAddTravel):
                state.path.append(.addticket(AddTicketFeature.State()))
                return .none
            case .pastTravel(.touchTicket(let ticket)):
                state.path.append(.detailEditView(DetailTravelFeature.State(ticket: ticket)))
                return .none
            case .pastTravel:
                return .none
            case .tabNotification:
                state.path.append(.notifications(NotificationFeature.State()))
                return .none
            case .tabmyPage:
                state.path.append(.myPage(MyPageFeature.State()))
                return .none
            case .popAll:
                state.path.removeAll()
                return .none
            case .requestLocationAuthorizaiton:
                return .run {send in
                    let status  = await locationClient.requestauthorzizationStatus()
                    await send(.authorizationResponse(status))
                }
            case let .authorizationResponse(status):
//                state.authorizationStatus = status
                return .none
            case let .toggleMonitoring(spot):
                if state.isMonitoring {
                    state.isMonitoring = false
                    state.currentMonitoredSpot = nil
                    return .run { _ in
                        await locationClient.stopMonitoring(spot)
                    }
                } else {
                    state.isMonitoring = true
                    state.currentMonitoredSpot = spot
                    return .run { send in
                        for await event in try await locationClient.startMonitoring(spot) {
                            await send(.monitoringEvent(event))
                        }
                    }
                }
            case let .monitoringEvent(event):
                state.monitoringEvents.append(event)
//                if case .didEnterRegion(let spot) = event {
//                    return .send(.scheduleNotification(spot))
//                }
                return .none
//            case let .scheduleNotification(spot):
//                guard state.isNotificationEnabled else { return .none }
//                let content = UNMutableNotificationContent()
//                content.title = "Location Update"
//                content.body = "도착했습니다."
//                content.sound = .default
//                content.userInfo = ["NotificationType": PushNotificationTypes.fourCutframe.rawValue]
////                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
//                let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude:  37.24135596, longitude: 127.07958444), radius: 1, identifier: UUID().uuidString)
//            
//                let trigger = UNLocationNotificationTrigger(region: region, repeats: false)
//                return .run { _ in
//                    _ = try await locationClient.scheduleNotification(content, trigger)
//                }
            case .login(.loginSuccess):
                state.currentLogin = true
                return .none
            case .login:
                return .none
            case .toggleNoti(let bool):
                state.isLogin = false
                if bool {
                    return .run { _ in
                       try await locationClient.requestNotiAuthorization()
                    }
                }
                return .none
 
        
            }
            
        }.forEach(\.path, action: \.path)
   
    }
    
}
