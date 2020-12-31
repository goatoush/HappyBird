//
//  UIImageExtentions.swift
//  HappyBird
//
//  Created by Utshaho Gupta on 12/27/20.
//

import Foundation
import UIKit

extension UIImage {

    func cropMargins(margin: CGFloat = 0.02) -> UIImage? {
        let scaledMargin: CGFloat = margin * min(size.width, size.height) * scale
        let width: CGFloat = size.width - scaledMargin * 2
        let height: CGFloat = size.height - scaledMargin * 2
        let scaledRect = CGRect(x: scaledMargin, y: scaledMargin, width: width, height: height)

        guard let imageRef: CGImage = self.cgImage?.cropping(to:scaledRect)
        else {
            return nil
        }

        let croppedImage: UIImage = UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
        return croppedImage
    }
    
    func blur(_ radius: CGFloat = 10.0) -> UIImage? {

        guard let imageRef: CIImage = self.ciImage?.applyingFilter("CIBoxBlur", parameters: ["inputImage" : self.ciImage as Any, "inputRadius" : radius])
        else {
            return nil
        }

        let croppedImage: UIImage = UIImage(ciImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
        return croppedImage
    }
    
    func alpha(_ value:CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

extension UILabel {
    func setHighlighted(_ text: String, with search: String) {
        let attributedText = NSMutableAttributedString(string: text)
        let range = NSString(string: text).range(of: search, options: .caseInsensitive)
        let highlightColor = traitCollection.userInterfaceStyle == .light ? UIColor.systemTeal : UIColor.systemBlue
        let highlightedAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.backgroundColor: highlightColor.withAlphaComponent(0.5)]
        attributedText.addAttributes(highlightedAttributes, range: range)
        self.attributedText = attributedText
    }
}

extension RangeReplaceableCollection {
    public mutating func resize(_ size: Int, fillWith value: Iterator.Element) {
        let c = count
        if c < size {
            append(contentsOf: repeatElement(value, count: c.distance(to: size)))
        } else if c > size {
            let newEnd = index(startIndex, offsetBy: size)
            removeSubrange(newEnd ..< endIndex)
        }
    }
}
