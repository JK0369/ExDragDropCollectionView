//
//  ViewController.swift
//  ExDragDropCollectionView
//
//  Created by 김종권 on 2022/01/14.
//

import UIKit
import Then
import SnapKit
import Reusable

class ViewController: UIViewController {
  private let containerStackView = UIStackView().then {
    $0.axis = .vertical
  }
  private let addButton = UIButton().then {
    $0.setTitle("추가", for: .normal)
    $0.setTitleColor(.systemBlue, for: .normal)
    $0.setTitleColor(.blue, for: .highlighted)
  }
  private let myView = MyView()
  private var colorDataSource = (0...20).map { _ in getRandomColor() }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.addButton.addTarget(self, action: #selector(addItem), for: .touchUpInside)
    
    self.view.addSubview(self.containerStackView)
    self.containerStackView.addArrangedSubview(self.addButton)
    self.containerStackView.addArrangedSubview(self.myView)
    self.containerStackView.snp.makeConstraints {
      $0.edges.equalTo(self.view.safeAreaLayoutGuide)
    }
    
    self.myView.dragDropCollectionView.dataSource = self
    self.myView.dragDropCollectionView.draggingDelegate = self
  }
  
  private func moveItem(from source: IndexPath, to dest: IndexPath, item: UIColor) {
    self.colorDataSource.remove(at: source.item)
    self.colorDataSource.insert(item, at: dest.item)
  }
  
  @objc private func addItem() {
    self.colorDataSource.append(getRandomColor())
    self.myView.dragDropCollectionView.reloadData()
  }
}

extension ViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    self.colorDataSource.count
  }
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: MyCell.self)
    cell.prepare(color: self.colorDataSource[indexPath.item])
    return cell
  }
}

extension ViewController: DrapDropCollectionViewDelegate {
  func dragDropCollectionViewDraggingDidBeginWithCellAtIndexPath<T>(_ collectionView: DragDropCollectionView<T>, indexPath: IndexPath) where T : UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: MyCell.self)
    cell.alpha = 0.1
  }
  
  func dragDropCollectionViewDidMoveCellFromInitialIndexPath<T>(_ collectionView: DragDropCollectionView<T>, initialIndexPath: IndexPath, toNewIndexPath newIndexPath: IndexPath) where T : UICollectionViewCell {
    let item = self.colorDataSource[initialIndexPath.item]
    self.moveItem(from: initialIndexPath, to: newIndexPath, item: item)
  }
  
  func dragDropCollectionViewDraggingDidEndForCellAtIndexPath<T>(_ collectionView: DragDropCollectionView<T>, indexPath: IndexPath) where T : UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: MyCell.self)
    cell.alpha = 1
  }
}

