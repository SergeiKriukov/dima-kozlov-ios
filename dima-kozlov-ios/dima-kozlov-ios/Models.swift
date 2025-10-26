import Foundation
import UIKit

struct Story: Identifiable, Codable, Hashable {
    let id: Int
    let title: String?
    let content: String

    var isFavorite: Bool = false

    init(id: Int, title: String?, content: String) {
        self.id = id
        self.title = title ?? "Рассказ \(String(format: "%03d", id))"
        self.content = content
    }
}

class StoryManager: ObservableObject {
    @Published var stories: [Story] = []
    @Published var favorites: Set<Int> = []

    private let favoritesKey = "favoriteStories"

    init() {
        loadStories()
        loadFavorites()
    }

    func loadStories() {
        stories = loadStoriesFromFiles()
    }

    private func loadStoriesFromFiles() -> [Story] {
        var loadedStories: [Story] = []

        // Получаем список файлов в папке stories
        guard let storiesURL = Bundle.main.resourceURL?.appendingPathComponent("stories"),
              let fileURLs = try? FileManager.default.contentsOfDirectory(at: storiesURL, includingPropertiesForKeys: nil) else {
            print("Could not find stories directory")
            return []
        }

        // Фильтруем только .txt файлы и сортируем по имени
        let txtFiles = fileURLs.filter { $0.pathExtension == "txt" }.sorted { $0.lastPathComponent < $1.lastPathComponent }

        for (index, fileURL) in txtFiles.enumerated() {
            let fileName = fileURL.deletingPathExtension().lastPathComponent

            // Пытаемся получить id из имени файла (001, 002, etc.)
            guard let storyId = Int(fileName) else {
                print("Could not parse story ID from filename: \(fileName)")
                continue
            }

            // Читаем содержимое файла
            do {
                let fileContent = try String(contentsOf: fileURL, encoding: .utf8)
                let title = extractTitle(from: fileContent)
                let content = extractContent(from: fileContent)

                if let content = content {
                    let story = Story(id: storyId, title: title, content: content)
                    loadedStories.append(story)
                    print("Loaded story \(storyId): \(title ?? "No title"), content length: \(content.count)")
                } else {
                    print("Could not extract content from file: \(fileName)")
                }
            } catch {
                print("Error reading file \(fileName): \(error)")
            }
        }

        print("Total stories loaded: \(loadedStories.count)")
        return loadedStories
    }

    func getImageForStory(_ storyId: Int) -> UIImage? {
        // Циклически выбираем картинку на основе ID рассказа
        let imageIndex = storyId % 11
        let imageName = String(format: "pict%03d", imageIndex)

        // Ищем картинку в папке stories
        guard let storiesURL = Bundle.main.resourceURL?.appendingPathComponent("stories") else {
            return nil
        }

        let imageURL = storiesURL.appendingPathComponent("\(imageName).jpg")
        return UIImage(contentsOfFile: imageURL.path)
    }

    func toggleFavorite(_ storyId: Int) {
        if favorites.contains(storyId) {
            favorites.remove(storyId)
        } else {
            favorites.insert(storyId)
        }
        saveFavorites()
        updateStoryFavorites()
    }

    func isFavorite(_ storyId: Int) -> Bool {
        favorites.contains(storyId)
    }

    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let decoded = try? JSONDecoder().decode(Set<Int>.self, from: data) {
            favorites = decoded
        }
    }

    private func saveFavorites() {
        if let data = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(data, forKey: favoritesKey)
        }
    }

    private func updateStoryFavorites() {
        for index in stories.indices {
            stories[index].isFavorite = favorites.contains(stories[index].id)
        }
    }

    private func extractTitle(from text: String) -> String? {
        extractText(from: text, startTag: "<title>", endTag: "</title>")
    }

    private func extractContent(from text: String) -> String? {
        extractText(from: text, startTag: "<content>", endTag: "</content>")
    }

    private func extractText(from text: String, startTag: String, endTag: String) -> String? {
        guard let startRange = text.range(of: startTag),
              let endRange = text.range(of: endTag, range: startRange.upperBound..<text.endIndex) else {
            return nil
        }

        let extractedTextRange = startRange.upperBound..<endRange.lowerBound
        return String(text[extractedTextRange]).trimmingCharacters(in: .whitespacesAndNewlines)
    }
}