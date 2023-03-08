//
//  ImageCommentCellController.swift
//  EssentialFeediOS
//
//  Created by Lorenzo Limoli on 07/03/23.
//  Copyright © 2023 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public final class ImageCommentCellController: CellController  {
    
    private let model: ImageCommentViewModel
    
    public init(model: ImageCommentViewModel){
        self.model = model
    }
    
    public func view(in tableView: UITableView) -> UITableViewCell {
        let cell: ImageCommentCell = tableView.dequeueReusableCell()
        cell.messageLabel.text = model.message
        cell.dateLabel.text = model.date
        cell.usernameLabel.text = model.username
        return cell
    }
}
