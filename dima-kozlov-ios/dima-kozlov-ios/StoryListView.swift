import SwiftUI
import UIKit

struct StoryListView: View {
    @EnvironmentObject var storyManager: StoryManager

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.currentBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Заголовок
                        Text("Рассказы")
                            .font(AppTypography.largeTitleFont)
                            .foregroundColor(AppTheme.currentAccent)
                            .padding(.top, 20)

                        // Сетка с карточками рассказов
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(storyManager.stories) { story in
                                NavigationLink(destination: ReadingView(story: story)) {
                                    StoryCardView(story: story)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)

                        // Статистика и информация об авторе
                        VStack(spacing: 12) {
                    
                                Text("Рассказы Дима Козлов")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppTheme.currentAccent)

                                Link(destination: URL(string: "https://dimakozlov.ru/")!) {
                                    Text("dimakozlov.ru")
                                        .font(.system(size: 12))
                                        .foregroundColor(AppTheme.currentTextSecondary)
                                        .underline()
                                }
                       
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
        }
    }
}

struct StoryCardView: View {
    let story: Story

    @EnvironmentObject var storyManager: StoryManager

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Изображение
                if let uiImage = storyManager.getImageForStory(story.id) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 120)
                        .clipped()
                        .cornerRadius(12)
                } else {
                    // Заглушка если картинка не найдена
                    ZStack {
                        Color.gray.opacity(0.3)
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    }
                    .frame(height: 120)
                    .cornerRadius(12)
                }

                // Контент карточки
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(story.title ?? "Без названия")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppTheme.currentTextPrimary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true) // Позволяет тексту занимать нужное место

                        Spacer()

                        // Кнопка избранного
                        Button(action: {
                            storyManager.toggleFavorite(story.id)
                        }) {
                            Image(systemName: storyManager.isFavorite(story.id) ? "heart.fill" : "heart")
                                .foregroundColor(storyManager.isFavorite(story.id) ? .red : AppTheme.currentTextSecondary)
                                .font(.system(size: 16))
                        }
                    }

                    // Превью текста
                    Text(story.content.prefix(100) + "...")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.currentTextSecondary)
                        .lineLimit(3)
                        .lineSpacing(2)
                }
                .padding(16)
                .frame(height: 120, alignment: .top) // Фиксированная высота для одинакового размера карточек
            }
        }
        .background(AppTheme.currentSecondaryBackground)
        .cornerRadius(12)
        .shadow(color: AppTheme.shadow, radius: 4, x: 0, y: 2)
        .animation(.easeInOut(duration: 0.2), value: storyManager.isFavorite(story.id))
    }
}


struct StoryListView_Previews: PreviewProvider {
    static var previews: some View {
        StoryListView()
            .environmentObject(StoryManager())
    }
}
