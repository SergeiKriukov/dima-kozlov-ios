import SwiftUI

struct RandomStoryView: View {
    @EnvironmentObject var storyManager: StoryManager
    @State private var currentStory: Story?
    @State private var showingStory = false

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.currentBackground
                    .ignoresSafeArea()

                VStack(spacing: 40) {
                    Spacer()

                    // Иконка
                    Image(systemName: "shuffle")
                        .font(.system(size: 80))
                        .foregroundColor(AppTheme.currentAccent)

                    // Заголовок
                    Text("Случайный рассказ")
                        .font(AppTypography.largeTitleFont)
                        .foregroundColor(AppTheme.currentTextPrimary)
                        .multilineTextAlignment(.center)

                    // Описание
                    Text("Откройте случайное произведение Димы Козлова и погрузитесь в мир философских размышлений")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.currentTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .lineSpacing(4)

                    Spacer()

                    // Кнопка
                    Button(action: {
                        selectRandomStory()
                    }) {
                        HStack {
                            Image(systemName: "shuffle")
                            Text("Открыть случайный рассказ")
                        }
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(AppTheme.currentAccent)
                        .cornerRadius(25)
                    }
                    .padding(.bottom, 40)

                    // Информация об авторе
                    VStack(spacing: 8) {
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
            .navigationTitle("Случайный")
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
        .sheet(isPresented: $showingStory) {
            if let story = currentStory {
                NavigationView {
                    ReadingView(story: story)
                        .environmentObject(storyManager)
                        .navigationBarItems(trailing: Button("Закрыть") {
                            showingStory = false
                        })
                }
            }
        }
    }

    private func selectRandomStory() {
        guard !storyManager.stories.isEmpty else { return }
        
        let randomIndex = Int.random(in: 0..<storyManager.stories.count)
        currentStory = storyManager.stories[randomIndex]
        showingStory = true
    }
}

struct RandomStoryView_Previews: PreviewProvider {
    static var previews: some View {
        RandomStoryView()
            .environmentObject(StoryManager())
    }
}
