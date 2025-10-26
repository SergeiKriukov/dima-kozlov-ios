//
//  ImageOptimizer.swift
//  dima-kozlov-ios
//
//  Created by Sergey on 26.10.2025.
//  Утилиты для оптимизации изображений в приложении
//

import UIKit
import SwiftUI

class ImageOptimizer {
    /// Оптимизирует изображение для отображения в приложении
    /// - Parameters:
    ///   - image: Исходное изображение
    ///   - targetSize: Максимальный размер (по большей стороне)
    ///   - compressionQuality: Качество сжатия JPEG (0.0 - 1.0)
    /// - Returns: Оптимизированное изображение
    static func optimizeImage(_ image: UIImage,
                            targetSize: CGFloat = 1200,
                            compressionQuality: CGFloat = 0.85) -> UIImage? {

        // Вычисляем коэффициент масштабирования
        let maxDimension = max(image.size.width, image.size.height)
        guard maxDimension > targetSize else {
            // Изображение уже достаточно маленькое
            return image
        }

        let scale = targetSize / maxDimension
        let newSize = CGSize(width: image.size.width * scale,
                           height: image.size.height * scale)

        // Создаем контекст для рисования
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        defer { UIGraphicsEndImageContext() }

        // Рисуем изображение в новом размере
        image.draw(in: CGRect(origin: .zero, size: newSize))

        guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }

        return resizedImage
    }

    /// Сжимает изображение в JPEG данные
    static func compressImageToJPEG(_ image: UIImage,
                                  quality: CGFloat = 0.85) -> Data? {
        return image.jpegData(compressionQuality: quality)
    }

    /// Получает оптимизированное изображение из Bundle
    static func getOptimizedImage(named name: String,
                                in bundle: Bundle = .main) -> UIImage? {
        guard let image = UIImage(named: name, in: bundle, with: nil) else {
            return nil
        }

        return optimizeImage(image)
    }

    /// Кеш для оптимизированных изображений
    private static var imageCache = NSCache<NSString, UIImage>()

    /// Получает изображение из кеша или оптимизирует и кеширует
    static func getCachedOptimizedImage(named name: String) -> UIImage? {
        let cacheKey = name as NSString

        // Проверяем кеш
        if let cachedImage = imageCache.object(forKey: cacheKey) {
            return cachedImage
        }

        // Загружаем и оптимизируем
        guard let optimizedImage = getOptimizedImage(named: name) else {
            return nil
        }

        // Сохраняем в кеш
        imageCache.setObject(optimizedImage, forKey: cacheKey)
        return optimizedImage
    }
}

// Расширение для удобного использования в SwiftUI
extension Image {
    /// Создает Image из оптимизированного изображения
    init(optimizedNamed name: String) {
        if let uiImage = ImageOptimizer.getCachedOptimizedImage(named: name) {
            self.init(uiImage: uiImage)
        } else {
            // Fallback на обычное изображение
            self.init(name)
        }
    }
}

// Пример использования в коде:
//
// В StoryCardView вместо:
// if let uiImage = storyManager.getImageForStory(story.id) {
//     Image(uiImage: uiImage)
//
// Использовать:
// Image(optimizedNamed: "pict\(String(format: "%03d", story.id))")
//
// В StoryManager можно добавить метод:
// func getOptimizedImageForStory(_ storyId: Int) -> UIImage? {
//     let imageName = String(format: "pict%03d", storyId)
//     return ImageOptimizer.getCachedOptimizedImage(named: imageName)
// }
