//
//  PurchaseManager.swift
//  Subscription
//
//  Created by 濱田裕史 on 2018/08/07.
//  Copyright © 2018年 濱田裕史. All rights reserved.
//

import Foundation
import StoreKit

class PurchaseManager:NSObject, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    
    static var shared = PurchaseManager()
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction:SKPaymentTransaction in transactions {
            switch transaction.transactionState {
            case SKPaymentTransactionState.purchasing:
                print("課金が進行中")
            case SKPaymentTransactionState.deferred:
                print("課金が遅延中")
            case SKPaymentTransactionState.failed:
                print("課金に失敗")
                queue.finishTransaction(transaction)
            case SKPaymentTransactionState.purchased:
                receiptValidation(url: "https://buy.itunes.apple.com/verifyReceipt")
                print("購入に成功")
                queue.finishTransaction(transaction)
            case SKPaymentTransactionState.restored:
                print("リストア")
                queue.finishTransaction(transaction)
                receiptValidation(url: "https://buy.itunes.apple.com/verifyReceipt")
            }
        }
    }
    
    func requestPurchase() {
        let productIdentifier:Set = ["your product identifier"]
        let productsRequest: SKProductsRequest = SKProductsRequest.init(productIdentifiers: productIdentifier)
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print(response.invalidProductIdentifiers.count)
        for product in response.products {
            let payment: SKPayment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        }
    }
    
    func receiptValidation(url: String) {
        let receiptUrl = Bundle.main.appStoreReceiptURL
        let receiptData = try! Data(contentsOf: receiptUrl!)

        let requestContents = [
            "receipt-data": receiptData.base64EncodedString(options: .endLineWithCarriageReturn),
            "password": "your password"
        ]
        
        let requestData = try! JSONSerialization.data(withJSONObject: requestContents, options: .init(rawValue: 0))

        var request = URLRequest(url: URL(string: url)!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"content-type")
        request.timeoutInterval = 5.0
        request.httpMethod = "POST"
        request.httpBody = requestData
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: {(data, response, error) -> Void in
            
            guard let jsonData = data else {
                return
            }
            
            do {
                let json:Dictionary<String, AnyObject> = try JSONSerialization.jsonObject(with: jsonData, options: .init(rawValue: 0)) as! Dictionary<String, AnyObject>
                
                let status:Int = json["status"] as! Int
                if status == receiptErrorStatus.invalidReceiptForProduction.rawValue {
                    self.receiptValidation(url: "https://sandbox.itunes.apple.com/verifyReceipt")
                }
                
                guard let receipts:Dictionary<String, AnyObject> = json["receipt"] as? Dictionary<String, AnyObject> else {
                    return
                }
                
                self.provideFunctions(receipts: receipts)
            } catch let error {
                print("SKPaymentManager : Failure to validate receipt: \(error)")
            }
        })
        task.resume()
    }
    
    func restore() {
        let request = SKReceiptRefreshRequest()
        request.delegate = self
        request.start()
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func requestDidFinish(_ request: SKRequest) {
        print("success")
    }
    
    private func request(request: SKRequest, didFailWithError error: Error) {
        // レシート取得失敗時にしたい処理
        print("failed")
    }
    
    private func provideFunctions(receipts:Dictionary<String, AnyObject>) {
        let in_apps = receipts["in_app"] as! Array<Dictionary<String, AnyObject>>
        
        var latestExpireDate:Int = 0
        for in_app in in_apps {
            let receiptExpireDateMs = Int(in_app["expires_date_ms"] as? String ?? "") ?? 0
            let receiptExpireDateS = receiptExpireDateMs / 1000
            if receiptExpireDateS > latestExpireDate {
                latestExpireDate = receiptExpireDateS
            }
        }
        UserDefaults.standard.set(latestExpireDate, forKey: "expireDate")
    }
}
