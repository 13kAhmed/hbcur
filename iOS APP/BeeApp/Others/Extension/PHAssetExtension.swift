//
//  PHAssetExtension.swift
//

import Photos
import UIKit

//MARK: -
extension PHAsset {
    
    func getFullImageAsycNoPlaceHolder(callBackImage:@escaping ((UIImage)->())) {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.resizeMode = .fast
        let size = CGSize(width:826, height:1472)
        manager.requestImage(for: self, targetSize: size, contentMode: .default, options: options) { (image, info) in
            DispatchQueue.main.async {
                if let img = image {
                    callBackImage(img)
                } else {
                    callBackImage(UIImage())
                }
            }
        }
    }
    
    func getAVAssetForVideo(callBackAVAsset: @escaping ((AVAsset?)->())) {
        let manager = PHImageManager.default()
        let options = PHVideoRequestOptions()
        options.deliveryMode = .automatic
        options.isNetworkAccessAllowed = true
        manager.requestAVAsset(forVideo: self, options: options) { (avAsset: AVAsset?, audioMix: AVAudioMix?, dictionary: [AnyHashable : Any]?) in
            DispatchQueue.main.async {
                callBackAVAsset(avAsset)
            }
        }
    }
    
    func getfullImage() -> UIImage? {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        var imageFull: UIImage? = nil
        options.isSynchronous = true
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .fast
        manager.requestImage(for:self, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.default, options:options) { (image, info) in
            imageFull = image
            
        }
        return imageFull
    }
    
    func getImageDataFromAsset() -> Data? {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        var imageData: Data? = nil
        options.isSynchronous = true
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        manager.requestImageData(for: self, options: options) { (data: Data?, string: String?, orientation: UIImage.Orientation, anyObject:[AnyHashable : Any]?) in
            imageData = data
        }
        return imageData
    }
    
    func getCIImageFromAsset() -> CIImage? {
        var ciFullImage: CIImage? = nil
        let options = PHContentEditingInputRequestOptions()
        options.isNetworkAccessAllowed = true
        requestContentEditingInput(with: options) { (contentEditingInput: PHContentEditingInput?, anyObject: [AnyHashable : Any]) in
            if let contentEditing = contentEditingInput {
                if let imageURL = contentEditing.fullSizeImageURL {
                    if let fullCIImage = CIImage(contentsOf: imageURL) {
                        ciFullImage = fullCIImage
                        yzPrint(items: "getCIImageFromAsset().requestContentEditingInput.ciFullImage : \(String(describing: ciFullImage?.properties))")
                    }
                }
            }
        }
        return ciFullImage
    }
    
    func getVideoUrl(_ complitionBlock: @escaping (URL?)->()){
        let option = PHVideoRequestOptions()
        option.deliveryMode = .fastFormat
        option.version = .original
        option.isNetworkAccessAllowed = true
        PHCachingImageManager().requestAVAsset(forVideo: self, options: option, resultHandler: { (avAsset, avAudioMix, info) in
            if let videoUrl = avAsset as? AVURLAsset {
                DispatchQueue.main.async {
                    complitionBlock(videoUrl.url)
                }
            }
        })
    }
    
    func getVideoURL() -> URL? {
        if self.mediaType == PHAssetMediaType.video{
            var url: URL? = nil
            //(contentEditingInput!.avAsset as? AVURLAsset)?.url.absoluteString
            PHCachingImageManager().requestAVAsset(forVideo: self, options: nil) { (avAsset: AVAsset?, avAudioMix: AVAudioMix?, anyObject: [AnyHashable : Any]?) in
                let avAssets = avAsset as? AVURLAsset
                if avAssets != nil {
                    yzPrint(items: "URL of video : \(String(describing: avAssets?.url))")
                    url = avAssets?.url
                }
            }
            return url
        }else {
            yzPrint(items: "its not video type")
            return nil
        }
        
    }
    
    func getResizedImage(size:CGSize, thumbnailHandler: @escaping ((UIImage) -> Void)) {
        PHImageManager.default().requestImage(for:self, targetSize: size, contentMode: PHImageContentMode.aspectFill, options: nil) { (image, userInfo) -> Void in
            if let img = image{
                thumbnailHandler(img)
            }
        }
    }
    
    func getThumbImage(_ size: CGSize, progressBlock: ((Double)->())?, completionBlock: ((UIImage?)->())?) {
        let manager = PHImageManager.default()
        let initialRequestOptions = PHImageRequestOptions()
        initialRequestOptions.isSynchronous = true
        initialRequestOptions.isNetworkAccessAllowed = true
        initialRequestOptions.deliveryMode = .fastFormat
        initialRequestOptions.resizeMode = .fast
        initialRequestOptions.progressHandler = { (progress, error, stop, userInfo) in
            DispatchQueue.main.sync {
                progressBlock?(progress)
            }
        }
        manager.requestImage(for: self, targetSize: size, contentMode: PHImageContentMode.aspectFill, options: initialRequestOptions) { (image, info) in
            DispatchQueue.main.async {
                completionBlock?(image)
            }
        }
    }
    
    func getfullImage(_ progressBlock: ((Double, UnsafeMutablePointer<ObjCBool>, Int32)->())?, completionBlock: ((UIImage?)->())?) {
        // Prepare the options to pass when fetching the (photo, or video preview) image.
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.progressHandler = { progress, error, stop, userInfo in
            // Handler might not be called on the main queue, so re-dispatch for UI work.
            if let dictUserInfo = userInfo {
                if let requestID = dictUserInfo[PHImageResultRequestIDKey] as? Int32 {
                    DispatchQueue.main.sync {
                        progressBlock?(progress, stop, requestID)
                    }
                }else{
                    DispatchQueue.main.sync {
                        progressBlock?(progress, stop, 0)
                    }
                }
            }else{
                DispatchQueue.main.sync {
                    progressBlock?(progress, stop, 0)
                }
            }
        }
        PHImageManager.default().requestImage(for: self, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: options, resultHandler: { image, _ in
            completionBlock?(image)
        })
    }
}

//MARK: -
extension PHPhotoLibrary {

    class func fetchLastestAsset(_ completionBlock: ((_ asset: PHAsset?) -> ())?) {
        YZPermission.checkOrRequest.photoLibraryAccess { (status: Int, isGranted: Bool) in
            if PHAuthorizationStatus.authorized.rawValue == status {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                let fetchResults = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                DispatchQueue.main.async {
                    completionBlock?(fetchResults.lastObject)
                }
            }
        }
    }
    
    public func saveVideoToLibrary(_ fileUrl: URL, completion: ((PHAsset?, Error?)->())? = nil) {
        if let assetCollection = PHPhotoLibrary.shared().findAlbum(_appName) {
            saveVideoToAlbum(fileUrl, assetCollection: assetCollection, completion: completion)
        } else {
            PHPhotoLibrary.shared().createAlbum(_appName, completion: {[weak self](collection, error) in
                if let collection = collection {
                    self?.saveVideoToAlbum(fileUrl, assetCollection: collection, completion: completion)
                } else {
                    DispatchQueue.main.async {
                        completion?(nil, error)
                    }
                }
            })
        }
    }

    fileprivate func saveVideoToAlbum(_ fileUrl: URL, assetCollection: PHAssetCollection, completion:((PHAsset?, Error?)->())? = nil) {
        var placeHolder: PHObjectPlaceholder?
        PHPhotoLibrary.shared().performChanges({
            if let createAssetRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileUrl) {
                if let albumChangeRequest = PHAssetCollectionChangeRequest(for: assetCollection) {
                    placeHolder = createAssetRequest.placeholderForCreatedAsset
                    let fastEnumeration = NSArray(array: [placeHolder] as! [PHObjectPlaceholder])
                    albumChangeRequest.addAssets(fastEnumeration)
                }else{
                    DispatchQueue.main.async {
                        completion?(nil, nil)
                    }
                }
            }else{
                DispatchQueue.main.async {
                    completion?(nil, nil)
                }
            }
        }, completionHandler: { success, error in
            if let placeHolder = placeHolder {
                if success {
                    let assets =  PHAsset.fetchAssets(withLocalIdentifiers: [placeHolder.localIdentifier], options: nil)
                    DispatchQueue.main.async {
                        completion?(assets.firstObject, error)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion?(nil, error)
                    }
                }
            }else{
                DispatchQueue.main.async {
                    completion?(nil, error)
                }
            }
        })
    }

    public func saveImageToLibrary(_ image: UIImage, completion: ((PHAsset?, Error?) -> ())?) {
        if let assetCollection = PHPhotoLibrary.shared().findAlbum(_appName) {
            saveImageToAlbum(image, assetCollection: assetCollection, completion: completion)
        } else {
            PHPhotoLibrary.shared().createAlbum(_appName, completion: {[weak self](collection, error) in
                if let collection = collection {
                    self?.saveImageToAlbum(image, assetCollection: collection, completion: completion)
                } else {
                    DispatchQueue.main.async {
                        completion?(nil, error)
                    }
                }
            })
        }
    }
    
    fileprivate func saveImageToAlbum(_ image: UIImage, assetCollection: PHAssetCollection, completion:((PHAsset?, Error?)->())? = nil) {
        var placeHolder: PHObjectPlaceholder?
        PHPhotoLibrary.shared().performChanges({
            let createAssetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            if let albumChangeRequest = PHAssetCollectionChangeRequest(for: assetCollection) {
                placeHolder = createAssetRequest.placeholderForCreatedAsset
                let fastEnumeration = NSArray(array: [placeHolder] as! [PHObjectPlaceholder])
                albumChangeRequest.addAssets(fastEnumeration)
            }else{
                DispatchQueue.main.async {
                    completion?(nil, nil)
                }
            }
        }, completionHandler: { success, error in
            if let placeHolder = placeHolder {
                if success {
                    let assets =  PHAsset.fetchAssets(withLocalIdentifiers: [placeHolder.localIdentifier], options: nil)
                    DispatchQueue.main.async {
                        completion?(assets.firstObject, error)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion?(nil, error)
                    }
                }
            }else{
                DispatchQueue.main.async {
                    completion?(nil, error)
                }
            }
        })
    }

    fileprivate func findAlbum(_ albumName: String) -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let fetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        guard let photoAlbum = fetchResult.firstObject else {
            return nil
        }
        return photoAlbum
    }
    
    fileprivate func createAlbum(_ albumName: String, completion: @escaping (PHAssetCollection?, Error?)->()) {
        var placeHolder: PHObjectPlaceholder?
        PHPhotoLibrary.shared().performChanges({
            let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
            placeHolder = createAlbumRequest.placeholderForCreatedAssetCollection
        }, completionHandler: { success, error in
            if success {
                if let placeHolder = placeHolder {
                    let fetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [placeHolder.localIdentifier], options: nil)
                    if let album = fetchResult.firstObject {
                        DispatchQueue.main.async {
                            completion(album, error)
                        }
                    }else{
                        DispatchQueue.main.async {
                            completion(nil, error)
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        })
    }
}
