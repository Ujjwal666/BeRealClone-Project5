//
//  CustomTableViewCell.swift
//  BeRealClone
//
//  Created by Ujjwal Adhikari on 2/26/23.
//

import UIKit
import Alamofire
import AlamofireImage

class PostCell: UITableViewCell {
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var postImageView: UIImageView!
    @IBOutlet private weak var captionLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    private var imageDataRequest: DataRequest?
    
    func formatDateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }
    
    func configure(with post: Post) {
        // Username
        if let user = post.user {
            if (post.location != nil){
                usernameLabel.text = user.username! + " is in " + post.location!
            }else{
                usernameLabel.text = user.username
            }
            //Profile
            if let profileImage = user.image,
               let imageUrl = profileImage.url {
                print("Profile", imageUrl)
                // Use AlamofireImage helper to fetch remote image from URL
                imageDataRequest = AF.request(imageUrl).responseImage { [weak self] response in
                    switch response.result {
                    case .success(let image):
                        // Set image view image with fetched image
                        self?.profileImageView.image = image
                    case .failure(let error):
                        print("❌❌ Error fetching image: \(error.localizedDescription)")
                        break
                    }
                }
            }
        }
        
        // Image
        if let imageFile = post.imageFile,
           let imageUrl = imageFile.url {
            print("Post", imageUrl)
            // Use AlamofireImage helper to fetch remote image from URL
            imageDataRequest = AF.request(imageUrl).responseImage { [weak self] response in
                switch response.result {
                case .success(let image):
                    // Set image view image with fetched image
                    self?.postImageView.image = image
                case .failure(let error):
                    print("❌ Error fetching image: \(error.localizedDescription)")
                    break
                }
            }
        }

        // Caption
        captionLabel.text = post.caption

        // Date
//        print("❌", post.createdAt)
//        if let date = post.createdAt {
//            dateLabel.text = DateFormatter.postFormatter.string(from: date)
//        }
        let dateString = formatDateString(post.createdAt!)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = dateFormatter.date(from: dateString) {
            dateLabel.text = DateFormatter.postFormatter.string(from: date)
//            print(formattedDate)
        }


    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Reset image view image.
        postImageView.image = nil

        // Cancel image request.
        imageDataRequest?.cancel()

    }
}
extension DateFormatter {
    static let postFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
}
