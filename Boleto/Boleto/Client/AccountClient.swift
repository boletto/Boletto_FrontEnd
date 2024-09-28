//
//  AccountClient.swift
//  Boleto
//
//  Created by Sunho on 9/21/24.
//

import Foundation
import Alamofire
import ComposableArchitecture

@DependencyClient
struct AccountClient {
    var postLogi: @Sendable (LoginUserRequest) async throws -> (Bool)
    var postAppleLogin: @Sendable (AppleLoginRequest) async throws -> (Bool)
    var postLogout: @Sendable () async throws -> Bool
    var deleteMemeber: @Sendable () async throws -> Bool
}
extension AccountClient: DependencyKey {
    static var liveValue: Self =  {
        return Self(
            postLogi: {request in
                let task = API.session.request(AccountRouter.postKakaoLogin(request))
                    .validate()
                    .serializingDecodable(GeneralResponse<LoginResponseData>.self)
                switch await task.result {
                case .success(let apiResposne):
                    print(apiResposne)
                    if apiResposne.success, let loginData = apiResposne.data {
                        KeyChainManager.shared.save(key: .accessToken, token: loginData.accessToken)
                        KeyChainManager.shared.save(key: .refreshToken, token: loginData.refreshToken)
                        KeyChainManager.shared.save(key: .id, token: String(loginData.userid))
                        return true
                    }
                    return false
                case .failure(let error):
                    throw error
                    
                }
                
                
            }, postAppleLogin: { req in
                let task = API.session.request(AccountRouter.postAppleLogin(req))
                    .validate()
                    .serializingDecodable(GeneralResponse<LoginResponseData>.self)
                
                switch await task.result {
                case .success(let apiResposne):
                    print(apiResposne)
                    if apiResposne.success, let loginData = apiResposne.data {
                        KeyChainManager.shared.save(key: .accessToken, token: loginData.accessToken)
                        KeyChainManager.shared.save(key: .refreshToken, token: loginData.refreshToken)
                        return true
                    }
                    return false
                case .failure(let error):
                    throw error
                    
                }
            }, postLogout: {
                let task = API.session.request(AccountRouter.postLogout, interceptor: RequestTokenInterceptor())
                    .validate()
                    .serializingDecodable(GeneralResponse<EmptyData>.self)
                switch await task.response.result {
                case .success(let success):
                    return true
                case .failure(let err):
                    throw err
                }
            }, deleteMemeber:  {
                let task = API.session.request(AccountRouter.deleteMemeber, interceptor: RequestTokenInterceptor())
                    .validate()
                    .serializingDecodable(GeneralResponse<EmptyData>.self)
                switch await task.response.result {
                case .success(let success):
                    return true
                case .failure(let err):
                    throw err
                }
            }
        )
    }()
}
extension DependencyValues {
    var accountClient: AccountClient {
        get { self[AccountClient.self] }
        set { self[AccountClient.self] = newValue }
    }
}
