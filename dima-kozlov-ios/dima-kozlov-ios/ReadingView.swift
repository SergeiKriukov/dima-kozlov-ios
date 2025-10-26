import SwiftUI

struct ReadingView: View {
    let story: Story

    @EnvironmentObject var storyManager: StoryManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Заголовок
                if let title = story.title {
                    Text(title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppTheme.currentTextPrimary)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                }

                // Текст рассказа
                Text(story.content)
                    .font(.system(size: 18))
                    .foregroundColor(AppTheme.currentTextPrimary)
                    .lineSpacing(8)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)

                // Информация об авторе
                VStack(spacing: 8) {
                    Divider()
                        .background(AppTheme.currentTextSecondary.opacity(0.3))
                        .padding(.horizontal, 20)

                    VStack(spacing: 4) {
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
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(AppTheme.currentBackground)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: Button(action: {
            storyManager.toggleFavorite(story.id)
        }) {
            Image(systemName: storyManager.isFavorite(story.id) ? "heart.fill" : "heart")
                .foregroundColor(storyManager.isFavorite(story.id) ? .red : AppTheme.currentTextSecondary)
                .font(.system(size: 20))
        })
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

struct ReadingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ReadingView(story: Story(id: 1, title: "Тестовый рассказ", content: "Это тестовый текст для превью. Здесь будет полный текст рассказа с красивым форматированием и атмосферными изображениями на фоне."))
                .environmentObject(StoryManager())
        }
    }
}
