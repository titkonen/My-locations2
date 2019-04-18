//
//  MyTabBarController.swift
//  MyLocations
//
//  Created by Toni Itkonen on 12/04/2019.
//  Copyright © 2019 Ray Wenderlich. All rights reserved.
//

import Foundation

import UIKit

class MyTabBarController: UITabBarController {
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  override var childForStatusBarStyle: UIViewController? {
    return nil
  }
}
