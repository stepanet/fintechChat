//
//  ConversationTableViewCell.swift
//  fintechChat
//
//  Created by Jack Sp@rroW on 21/02/2019.
//  Copyright © 2019 Jack Sp@rroW. All rights reserved.
//

import UIKit

class ConversationTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var messageLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var cellViewContent: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

   public func dataCell(_ conversationLists: ConversationCellConfiguration) {

        nameLbl.text = conversationLists.name

        if let second = conversationLists.date?.timeIntervalSince1970 {
            let timestampDate = Date(timeIntervalSince1970: second)
            let dateFormatter = DateFormatter()

            if ConversationTableViewCell.daysBetween(start: Date(), end: conversationLists.date!) < 0 {
                dateFormatter.dateFormat = "dd MMM"
            } else {
                dateFormatter.dateFormat = "HH:mm"
            }
            dateLbl.text = dateFormatter.string(from: timestampDate as Date)
        }

        if conversationLists.hasUnreadMessage {
            messageLbl.font = UIFont.boldSystemFont(ofSize: 17)
        }

        if conversationLists.message == nil {
            messageLbl.text = "No messages yet"
            messageLbl.textColor = .gray
            messageLbl.font = UIFont.init(name: "HelveticaNeue-Thin", size: 14)
        } else {
            messageLbl.text = conversationLists.message
        }
    }

    public static func daysBetween(start: Date, end: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: start, to: end).day!
    }

}
