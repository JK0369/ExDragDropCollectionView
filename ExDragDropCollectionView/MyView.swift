//
//  MyView.swift
//  ExDragDropCollectionView
//
//  Created by 김종권 on 2022/01/14.
//

import UIKit
import SnapKit

class MyView: UIView {
  enum Metric {
    static let collectionViewPadding = 4.0
    static let collectionViewNumberOfColumns = 3.0
    static let collectionViewInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    static let collectionViewItemSize: CGSize = {
      let collectionViewLeftRightInset = collectionViewInset.left + collectionViewInset.right
      let cellsWidth = UIScreen.main.bounds.width - collectionViewLeftRightInset - collectionViewPadding * (collectionViewNumberOfColumns - 1)
      let width = cellsWidth / collectionViewNumberOfColumns
      let height = width * 100 / 120
      return CGSize(width: width, height: height)
    }()
  }

  let dragDropCollectionView = DragDropCollectionView<MyCell>(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout().then {
      $0.minimumLineSpacing = Metric.collectionViewPadding
      $0.minimumInteritemSpacing = Metric.collectionViewPadding
      $0.itemSize = Metric.collectionViewItemSize
    }
  ).then {
    $0.backgroundColor = .clear
    $0.enableDragging(true)
    $0.register(cellType: MyCell.self)
  }
  private let infoLabel = UILabel().then {
    $0.text = "myView"
    $0.textColor = .black
    $0.font = .systemFont(ofSize: 56)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.addSubview(self.infoLabel)
    self.addSubview(self.dragDropCollectionView)
    self.infoLabel.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.height.equalTo(56)
      $0.left.equalToSuperview()
    }
    self.dragDropCollectionView.snp.makeConstraints {
      $0.top.equalTo(self.infoLabel.snp.bottom)
      $0.left.right.bottom.equalToSuperview()
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError()
  }
}
