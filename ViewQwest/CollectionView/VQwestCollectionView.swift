//
//  VQuestCollectionView.swift
//  ViewQuestTask
//
//  Created by Satham Hussain on 8/24/18.
//  Copyright © 2018 Satham Hussain. All rights reserved.
//

import UIKit
import SDWebImage


class VQwestCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  
    
    let  collectionViewCellId = "vQuestCell"
    let  headerID             = "vQuestHeaderCell"
    let screenWidth :CGFloat = UIScreen.main.bounds.width
    let apiService = APIService()
    var userLst = [Users]()
    var limit = 0
    var offsetLimit = 0
    var sum = 0
    
    var HUD: MBProgressHUD = MBProgressHUD()

   
    override func awakeFromNib() {
        self.delegate = self
        self.dataSource = self
        limit = 10
        offsetLimit = 10
        DispatchQueue.main.async {
            self.HUD.labelText = "Loading..."
            self.addSubview(self.HUD)
        }
        
        if NetworkConnectivity.isConnectedToNetwork() {
            fetchUserInfo(fetchLimit: limit, offset: offsetLimit)
        }else{
            showAlert(message: "Please connect to the network 🌍")
        }
        let itemSize = (UIScreen.main.bounds.width-20) / 2
        let layout =  UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5  )
        layout.headerReferenceSize = CGSize(width: screenWidth, height: 50)
        layout.itemSize = CGSize(width: itemSize, height: self.frame.size.height/3)
        self.collectionViewLayout = layout
      
    }
  //MARK: DELEGATE METHODS
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSize = (UIScreen.main.bounds.width-20) / 2

        if (userLst[indexPath.section].items?.count)! % 2 == 0 {
            return CGSize(width: itemSize, height: self.frame.size.height/4)
        }else {
            if indexPath.row == 0 {
                let width = collectionView.frame.width-10
                let height : CGFloat = 350.0
                return CGSize(width: width, height: height)
            }else{
                return CGSize(width: itemSize, height: self.frame.size.height/4)
            }
    }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return userLst.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (userLst[section].items?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionViewCellId, for: indexPath) as! VQwestCell
        
        cell.clipsToBounds = true
        cell.layer.cornerRadius = 3.0
        let itemImgUrl = userLst[indexPath.section].items
         cell.itemImgView.sd_setShowActivityIndicatorView(true)
         cell.itemImgView.sd_setIndicatorStyle(.white)
        cell.itemImgView.sd_setImage(with: URL(string: itemImgUrl![indexPath.item]) , placeholderImage: UIImage(named: "placeholder.png"))
        return cell
    }
    

    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionHeaderView = self.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerID, for: indexPath) as! VQwestSectionHeader
        
        sectionHeaderView.userImgView.clipsToBounds = true
        sectionHeaderView.userImgView.layer.cornerRadius = sectionHeaderView.userImgView.frame.width/2
        
         sectionHeaderView.userImgView.sd_setShowActivityIndicatorView(true)
         sectionHeaderView.userImgView.sd_setIndicatorStyle(.white)
        
        
        let imageUrl = userLst[indexPath.section].image
        sectionHeaderView.userImgView.sd_setImage(with: URL(string: imageUrl!) , placeholderImage: UIImage(named: "placeholder.png"))
        sectionHeaderView.userNameLbl.text = userLst[indexPath.section].name
        return sectionHeaderView
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //Checks the last section below
        if indexPath.section == userLst.count - 1 {  //numberofitem count
            updateNextSet()
        }
        //animation
      /*  cell.alpha = 0
        cell.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.75) {
            cell.alpha = 1
            cell.transform = .identity
        }*/
    }
    
    
    //MARK: API Calls
    func updateNextSet(){
        print("On Completetion")
        offsetLimit = offsetLimit + limit + 1
        print(offsetLimit)
        
        if NetworkConnectivity.isConnectedToNetwork() {
            fetchUserInfo(fetchLimit: limit, offset: offsetLimit)
        }else{
            showAlert(message: "Please connect to the network 🌍")
        }
    }
    
    
    func fetchUserInfo(fetchLimit : Int, offset : Int)  {
        self.HUD.show(true)
        let apiUrl =  "http://sd2-hiring.herokuapp.com/api/users?offset=\(offset)&limit=\(fetchLimit)"
        print(apiUrl)
        apiService.getUserInfo(url:apiUrl) { (success, err) in
            if err == nil{
                // self.userLst = (success.data?.users)!
                print("before append count \(self.userLst.count)")
                for users in (success.data?.users)!{
                    self.userLst.append(users)
                }
                print("after append count \(self.userLst.count)")
                DispatchQueue.main.async {
                    self.reloadData()
                    self.HUD.hide(true)
                }
            }else{
                //something wrong happend
               self.showAlert(message: "Something wrong happened !!!")
            }
        }
    }
    
  
  
    func showAlert(message : String) {
        let alertController = UIAlertController(title: "Info", message:
            message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
}
