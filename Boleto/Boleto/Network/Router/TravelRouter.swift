//
//  TravelRouter.swift
//  Boleto
//
//  Created by Sunho on 9/22/24.
//

import Alamofire
import Foundation
enum TravelRouter {
    case postTravel(TravelRequest)
    case updateTravel(TravelFetchRequest)
    case deleteTravel(SingleTravelRequest)
    case getAllTravel
    case getSingleTravel(SingleTravelRequest)
    case getSingleMemory(SingleTravelRequest)
    case postSinglePicture(ImageUploadRequest, imageFile: Data)
    case postFourPicture(FourCutRequest, imageFile: [Data])
    case deleteSinglePicture(SignlePictureRequest)
    case patchEditData(EditMemoryRequest)
}
extension TravelRouter: NetworkProtocol {
    
    var baseURL: String {
        return CommonAPI.api+"/api/v1/travel"
    }
    var path: String {
        switch self {
        case .postTravel:
            "/create"
        case .updateTravel:
            "/update"
        case .deleteTravel:
            "/delete"
        case .getAllTravel:
            "/get/all"
        case .getSingleTravel:
            "/get"
        case .getSingleMemory:
            "/memory/get"
        case .postSinglePicture:
            "/memory/picture/save"
        case .postFourPicture:
            "/memory/picture/save/fourCut"
        case .deleteSinglePicture:
            "/memory/picture/delete"
        case .patchEditData:
            "/memory/edit"
        }
    }
    var method: HTTPMethod {
        switch self {
        case .postTravel:
                .post
        case .updateTravel, .patchEditData:
                .patch
        case .deleteTravel, .deleteSinglePicture:
                .delete
//        case .deleteSinglePicture:
//                .post
        case .postSinglePicture, .postFourPicture:
                .post
        case .getAllTravel, .getSingleTravel, .getSingleMemory:
                .get
        }
    }
    var parameters: RequestParams {
        switch self {
        case .postTravel(let travelDTO):
            return .body(travelDTO)
        case .updateTravel(let travelDTO):
            return .body(travelDTO)
        case .deleteTravel(let deleteDTO):
            return  .query(deleteDTO)
        case .getAllTravel:
            return  .none
        case .getSingleTravel(let travelID):
            return  .query(travelID)
        case .getSingleMemory(let travelID):
            return .query(travelID)
        case .postSinglePicture,.postFourPicture:
            return .none
        case .deleteSinglePicture(let pictureDTO):
            return .body(pictureDTO)
        case .patchEditData(let patchDTO):
            return .body(patchDTO)
        }
    }
    var multipartData: MultipartFormData? {
        switch self {
        case .postSinglePicture(let imageRequest, let imageFile):
            let multiPart = MultipartFormData()
            let dataDict = imageRequest.toDictionary()
            let fileName = String( imageRequest.travelId * 10 + imageRequest.pictureIdx)
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: dataDict)
                multiPart.append(jsonData, withName: "data", mimeType: "application/json")
            } catch {
                return nil
            }
            multiPart.append(imageFile,withName: "picture_file", fileName: fileName, mimeType: "image/jpeg")
            
            
            return multiPart
        case .postFourPicture(let fourRequest, let imageFiles):
            let multiPart = MultipartFormData()
            let jsonData = Data()
            let dataDict = fourRequest.toDictionary()
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: dataDict)
                multiPart.append(jsonData, withName: "data", mimeType: "application/json")
            } catch {
                return nil
            }
            for (index, imageFile) in imageFiles.enumerated() {
                let fileName = String(fourRequest.travelId * 10 + fourRequest.pictureIdx) + "_\(index + 1)"
                multiPart.append(imageFile, withName: "picture_file", fileName: fileName, mimeType: "image/jpeg")
            }
            var totalSize: Int = 0
              
              // Size of JSON data
              totalSize += jsonData.count
              
              // Size of each image
              for imageFile in imageFiles {
                  totalSize += imageFile.count
              }
              
              // Estimate some extra overhead from multipart boundaries (about 500 bytes per part)
              let overheadEstimate = 500 * (imageFiles.count + 1)  // +1 for the JSON part
              totalSize += overheadEstimate
              
              print("Total request size: \(Double(totalSize) / 1024.0 / 1024.0) MB")
            return multiPart
        default:
            return nil
        }
    }
    
}
