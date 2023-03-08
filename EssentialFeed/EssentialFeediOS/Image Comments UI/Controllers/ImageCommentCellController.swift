//
//  ImageCommentCellController.swift
//  EssentialFeediOS
//
//  Created by Lorenzo Limoli on 07/03/23.
//  Copyright © 2023 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public final class ImageCommentCellController: NSObject  {
    
    private let model: ImageCommentViewModel
    
    public init(model: ImageCommentViewModel){
        self.model = model
    }
}

extension ImageCommentCellController: UITableViewDataSource{
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ImageCommentCell = tableView.dequeueReusableCell()
        cell.messageLabel.text = model.message
        cell.dateLabel.text = model.date
        cell.usernameLabel.text = model.username
        return cell
    }
}
