//
//  MyCell.swift
//  ExDragDropCollectionView
//
//  Created by 김종권 on 2022/01/14.
//

import UIKit
import Reusable
import Then
import SnapKit

final class MyCell: UICollectionViewCell, Reusable {
  private let colorView = UIView().then {
    $0.backgroundColor = nil
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.contentView.addSubview(self.colorView)
    self.colorView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
  required init?(coder: NSCoder) {
    fatalError()
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    self.prepare(color: nil)
  }
  
  func prepare(color: UIColor?) {
    self.colorView.backgroundColor = color
  }
}
