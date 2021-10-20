//
//  ZDImageRequestOperation.swift
//  SelectAlbum
//
//  Created by 张冬 on 2021/10/19.
//

import Foundation
import Photos

enum ZDPhotoOperateionResult{
    
    case success(UIImage)
    
    case failed(String)
    
    case preogress(Double)
    
}

/**
 *  请求图片operation任务
 */
class ZDPhotoRequestOperation: Operation {
    
    /// 指定_executing用于记录任务是否执行
    var _executing:Bool = false{
        willSet{
            self.willChangeValue(forKey: "isExecuting")
        }
        didSet{
            self.didChangeValue(forKey: "isExecuting")
        }
    }
    
    ///指定_finished用于记录任务是否完成
    var _finished:Bool = false {
        willSet{
            self.willChangeValue(forKey: "isFinished")
        }
        didSet{
            self.didChangeValue(forKey: "isFinished")
        }
    }
    
    private var asset: PHAsset?
    
    private var completionHandler: ((ZDPhotoOperateionResult) -> Void)?
    
    convenience init(_ asset: PHAsset , completeHandler: ((ZDPhotoOperateionResult) -> Void)?) {
        self.init()
        self.asset = asset
        self.completionHandler = completeHandler
        self._finished = false
        self._executing = false
    }
    
    override func start() {
        _executing = true
        guard let _asset = self.asset else {
            self.done()
            return
        }
        ZDPhotoImageManager.getSelectPhotoImage(_asset) { image in
            DispatchQueue.main.async {
                self.completionHandler?(.success(image))
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                    self.done()
                }
            }
        } progressHandler: { progress in
            DispatchQueue.main.async {
                self.completionHandler?(.preogress(progress))
            }
        } failed: { err in
            DispatchQueue.main.async {
                self.completionHandler?(.failed(err))
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                    self.done()
                }
            }
        }

    }
    
    override func cancel() {
        objc_sync_enter(self)
        self.done()
        objc_sync_exit(self)
    }
    
    private func done() {
        super.cancel()
        if _executing {
            _executing = false
            _finished = true
        }
        self.asset = nil
        self.completionHandler = nil
    }
    
    deinit {
        ZDLog("deinit:ZDImageRequestOperation")
    }
    
}
