//
//  UIImage.swift
//  
//
//  Created by p-x9 on 2022/06/05.
//  
//

import UIKit.UIImage

extension UIImage {
    
    func resize(_ scale: CGFloat) -> UIImage {
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        
        return resize(newSize)
    }
    
    func resize(_ size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { _ in
            self.draw(in: .init(origin: .zero, size: size))
        }
        return image.withRenderingMode(self.renderingMode)
    }
}
