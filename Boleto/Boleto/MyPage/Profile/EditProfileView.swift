//
//  EditProfileView.swift
//  Boleto
//
//  Created by Sunho on 9/12/24.
//

import SwiftUI
import ComposableArchitecture
import PhotosUI
struct EditProfileView: View {
    @Bindable var store: StoreOf<MyProfileFeature>
    var body: some View {
        VStack {
            
            PhotosPicker(selection: Binding( get: {
                store.selectedItem
            }, set: { newvalue in
                store.send(.imagePickerSelection(newvalue))
            }), matching: .images) {
                ZStack(alignment: .bottomTrailing) {
                    if let profileImage = store.profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 148,height: 148)
                            .clipShape(Circle())
                    } else {
                        Image("profile")
                            .resizable()
                            .frame(width: 148,height: 148)
                    }
                    
                    ZStack {
                        Circle()
                            .fill(.white)
                            .frame(width: 38,height: 38)
                        Image("PencilSimple")
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 21,height: 21)
                            .foregroundStyle(.main)
                        
                    }
                    
                }
            }
            .padding(.bottom, 56)
            VStack(alignment: .leading, spacing: 10) {
                Text("닉네임")
                    .customTextStyle(.subheadline)
                    .foregroundColor(.white)
                TextField("닉네임을 입력하세요", text: $store.nickName)
                    .foregroundStyle(.white)
                    .customTextStyle(.body1)
                //                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Divider()
                    .frame(width: .infinity,height: 1)
                    .background(.gray2)
                    .padding(.bottom, 25)
                Text("이름")
                    .customTextStyle(.subheadline)
                    .foregroundColor(.white)
                TextField("닉네임을 입력하세요", text: $store.name)
                    .foregroundStyle(.white)
                    .customTextStyle(.body1)
                Divider()
                    .frame(width: .infinity,height: 1)
                    .background(.gray2)
            }
            Spacer()
            Button(action: {}, label: {
                Text("저장")
                    .customTextStyle(.normal)
                    .foregroundStyle(.gray1)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(RoundedRectangle(cornerRadius: 30).fill(.main))
                
            })
            
        }
        .padding(.top, 40)
        .padding(.horizontal, 32)
        .applyBackground(color: .background)
        
    }
}

#Preview {
    EditProfileView(store: .init(initialState: MyProfileFeature.State(), reducer: {
        MyProfileFeature()
    }))
}
