//
//  Mock.swift
//  ExDragDropCollectionView
//
//  Created by 김종권 on 2022/01/14.
//

import UIKit

func getRandomColor() -> UIColor{
  let randomRed:CGFloat = CGFloat(drand48())
  let randomGreen:CGFloat = CGFloat(drand48())
  let randomBlue:CGFloat = CGFloat(drand48())
  return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
}
