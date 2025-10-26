import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var storyManager: StoryManager

    var favoriteStories: [Story] {
        storyManager.stories.filter { storyManager.isFavorite($0.id) }
    }

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.currentBackground
                    .ignoresSafeArea()

                if favoriteStories.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "heart")
                            .font(.system(size: 60))
                            .foregroundColor(AppTheme.currentTextSecondary.opacity(0.5))

                        Text("Нет избранных рассказов")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(AppTheme.currentTextPrimary)

                        Text("Добавьте рассказы в избранное, нажав на сердечко")
                            .font(.system(size: 16))
                            .foregroundColor(AppTheme.currentTextSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(favoriteStories) { story in
                                NavigationLink(destination: ReadingView(story: story)) {
                                    FavoriteStoryRowView(story: story)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                    }
                }
            }
            .navigationTitle("Избранное")
            .onAppear {
                // Настройка внешнего вида навигационной панели
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor(AppTheme.currentBackground)
                appearance.titleTextAttributes = [.foregroundColor: UIColor(AppTheme.currentTextPrimary)]
                appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(AppTheme.currentTextPrimary)]

                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    }
}

struct FavoriteStoryRowView: View {
    let story: Story

    @EnvironmentObject var storyManager: StoryManager

    var body: some View {
        HStack(spacing: 16) {
            // Изображение
            if let uiImage = storyManager.getImageForStory(story.id) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipped()
                    .cornerRadius(8)
            } else {
                ZStack {
                    Color.gray.opacity(0.3)
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                }
                .frame(width: 80, height: 80)
                .cornerRadius(8)
            }

            // Контент
            VStack(alignment: .leading, spacing: 8) {
                Text(story.title ?? "Без названия")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppTheme.currentTextPrimary)
                    .lineLimit(2)

                Text(story.content.prefix(150) + "...")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.currentTextSecondary)
                    .lineLimit(3)
                    .lineSpacing(2)
            }

            Spacer()

            // Кнопка удаления из избранного
            Button(action: {
                storyManager.toggleFavorite(story.id)
            }) {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                    .font(.system(size: 20))
            }
        }
        .padding(16)
        .background(AppTheme.currentSecondaryBackground)
        .cornerRadius(12)
        .shadow(color: AppTheme.shadow, radius: 4, x: 0, y: 2)
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView()
            .environmentObject(StoryManager())
    }
}