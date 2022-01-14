//
//  DragDropCollectionView.swift
//  DragDrop
//
//  Created by Lior Neu-ner on 2014/12/30.
//  Copyright (c) 2014 LiorN. All rights reserved.
// 3rd test for git submodule
//Just testing git subtree for the second time

import UIKit
import AVFoundation
import Then

protocol DrapDropCollectionViewDelegate: AnyObject {
  func dragDropCollectionViewDidMoveCellFromInitialIndexPath<T>(
    _ collectionView: DragDropCollectionView<T>,
    initialIndexPath: IndexPath,
    toNewIndexPath newIndexPath: IndexPath
  )
  func dragDropCollectionViewDraggingDidBeginWithCellAtIndexPath<T>(_ collectionView: DragDropCollectionView<T>, indexPath: IndexPath)
  func dragDropCollectionViewDraggingDidEndForCellAtIndexPath<T>(_ collectionView: DragDropCollectionView<T>, indexPath: IndexPath)
}

class DragDropCollectionView<DraggableCellType>: UICollectionView,
  UIGestureRecognizerDelegate
  where DraggableCellType: UICollectionViewCell {
  weak var draggingDelegate: DrapDropCollectionViewDelegate?
  
  var longPressRecognizer = UILongPressGestureRecognizer().then {
    $0.delaysTouchesBegan = false
    $0.cancelsTouchesInView = false
    $0.numberOfTouchesRequired = 1
    $0.minimumPressDuration = 0.5
    $0.allowableMovement = 10.0
  }
  
  var draggedCellIndexPath: IndexPath?
  var draggingView: UIView?
  var touchOffsetFromCenterOfCell: CGPoint?
  let pingInterval = 0.03
  var isSwapEnabled = true
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.commonInit()
  }
  
  override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
    super.init(frame: frame, collectionViewLayout: layout)
    self.commonInit()
  }
  
  func commonInit() {
    self.longPressRecognizer.addTarget(self, action: #selector(self.handleLongPress(_:)))
    self.longPressRecognizer.isEnabled = false
    self.addGestureRecognizer(self.longPressRecognizer)
  }
  
  @objc func handleLongPress(_ longPressRecognizer: UILongPressGestureRecognizer) {
    let touchLocation = longPressRecognizer.location(in: self)
    
    switch longPressRecognizer.state {
    case .began:
      self.draggedCellIndexPath = self.indexPathForItem(at: touchLocation)
      guard
        let draggedCellIndexPath = self.draggedCellIndexPath,
        self.cellForItem(at: draggedCellIndexPath) is DraggableCellType,
        case _ = self.draggingDelegate?.dragDropCollectionViewDraggingDidBeginWithCellAtIndexPath(self, indexPath: draggedCellIndexPath),
        let draggedCell = self.cellForItem(at: draggedCellIndexPath)
      else { return }
      let draggingView = UIImageView(image: self.getRasterizedImageCopyOfCell(draggedCell))
      self.draggingView = draggingView
      draggingView.center = (draggedCell.center)
      self.addSubview(draggingView)
      draggedCell.isHidden = true
      self.touchOffsetFromCenterOfCell = CGPoint(x: draggedCell.center.x - touchLocation.x, y: draggedCell.center.y - touchLocation.y)
      UIView.animate(
        withDuration: 0.4,
        animations: {
          draggingView.transform = .init(scaleX: 1.1, y: 1.1)
          draggingView.alpha = 0.9
          draggingView.layer.shadowRadius = 20
          draggingView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
          draggingView.layer.shadowOpacity = 0.2
          draggingView.layer.shadowOffset = CGSize(width: 0, height: 25)
        }
      )
    case .changed:
      guard
        self.draggedCellIndexPath != nil,
        let touchOffsetFromCenterOfCell = self.touchOffsetFromCenterOfCell
      else { return }
      self.draggingView?.center = CGPoint(
        x: touchLocation.x + touchOffsetFromCenterOfCell.x,
        y: touchLocation.y + touchOffsetFromCenterOfCell.y
      )
      
      self.dispatchOnMainQueueAfter(
        self.pingInterval,
        closure: {
          let shouldSwapCellsTuple = self.shouldSwapCells(touchLocation)
          if shouldSwapCellsTuple.shouldSwap {
            guard let newIndexPath = shouldSwapCellsTuple.newIndexPath else { return }
            self.swapDraggedCellWithCellAtIndexPath(newIndexPath)
          }
        }
      )
    case .ended:
      guard
        let draggedCellIndexPath = self.draggedCellIndexPath,
        case _ = self.draggingDelegate?.dragDropCollectionViewDraggingDidEndForCellAtIndexPath(self, indexPath: draggedCellIndexPath),
        let draggedCell = self.cellForItem(at: draggedCellIndexPath)
      else { return }
      UIView.animate(
        withDuration: 0.4,
        animations: {
          self.draggingView?.transform = .identity
          self.draggingView?.alpha = 1.0
          self.draggingView?.center = draggedCell.center
          self.draggingView?.layer.shadowRadius = 0
          self.draggingView?.layer.shadowColor = nil
          self.draggingView?.layer.shadowOffset = .zero
        },
        completion: { finished -> Void in
          self.draggingView?.removeFromSuperview()
          self.draggingView = nil
          draggedCell.isHidden = false
          self.draggedCellIndexPath = nil
        }
      )
    default:
      break
    }
  }
  
  func enableDragging(_ enable: Bool) {
    self.longPressRecognizer.isEnabled = enable
  }
  
  fileprivate func shouldSwapCells(_ previousTouchLocation: CGPoint) -> (shouldSwap: Bool, newIndexPath: IndexPath?) {
    guard
      self.isSwapEnabled,
      case let currentTouchLocation = self.longPressRecognizer.location(in: self),
      let draggedCellIndexPath = self.draggedCellIndexPath,
      !Double(currentTouchLocation.x).isNaN,
      !Double(currentTouchLocation.y).isNaN,
      self.distanceBetweenPoints(previousTouchLocation, secondPoint: currentTouchLocation) < CGFloat(20.0),
      let newIndexPathForCell = self.indexPathForItem(at: currentTouchLocation),
      self.cellForItem(at: draggedCellIndexPath) is DraggableCellType,
      self.cellForItem(at: newIndexPathForCell) is DraggableCellType,
      newIndexPathForCell != draggedCellIndexPath
    else { return (false, nil) }
    return (true, newIndexPathForCell)
  }
  
  fileprivate func swapDraggedCellWithCellAtIndexPath(_ newIndexPath: IndexPath) {
    guard let draggedCellIndexPath = self.draggedCellIndexPath else { return }
    let generator = UIImpactFeedbackGenerator(style: .light)
    generator.impactOccurred()
    self.moveItem(at: draggedCellIndexPath, to: newIndexPath)
    self.draggingDelegate?.dragDropCollectionViewDidMoveCellFromInitialIndexPath(
      self,
      initialIndexPath: draggedCellIndexPath,
      toNewIndexPath: newIndexPath
    )
    self.draggedCellIndexPath = newIndexPath
  }
}

//Assisting Functions
extension DragDropCollectionView {
  func getRasterizedImageCopyOfCell(_ cell: UICollectionViewCell) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(cell.bounds.size, false, 0.0)
    guard let context = UIGraphicsGetCurrentContext() else { return nil }
    cell.layer.render(in: context)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
  }
  
  func dispatchOnMainQueueAfter(_ delay: Double, closure: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(
      deadline: .now() + delay,
      qos: .userInteractive,
      flags: .enforceQoS,
      execute: closure
    )
  }
  
  func distanceBetweenPoints(_ firstPoint: CGPoint, secondPoint: CGPoint) -> CGFloat {
    let xDistance = firstPoint.x - secondPoint.x
    let yDistance = firstPoint.y - secondPoint.y
    return sqrt(xDistance * xDistance + yDistance * yDistance)
  }
}
