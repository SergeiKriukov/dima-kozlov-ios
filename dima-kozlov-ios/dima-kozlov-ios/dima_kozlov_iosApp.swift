//
//  dima_kozlov_iosApp.swift
//  dima-kozlov-ios
//
//  Created by Sergey on 03.01.2024.
//

import SwiftUI

@main
struct dima_kozlov_iosApp: App {
    @StateObject private var storyManager = StoryManager()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(storyManager)
        }
#if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified(showsTitle: false))
#endif
    }
}

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            StoryListView()
                .tabItem {
                    Image(systemName: "book.closed")
                    Text("Рассказы")
                }
                .tag(0)

            FavoritesView()
                .tabItem {
                    Image(systemName: "heart")
                    Text("Избранное")
                }
                .tag(1)

            RandomStoryView()
                .tabItem {
                    Image(systemName: "shuffle")
                    Text("Случайный")
                }
                .tag(2)
        }
        .accentColor(AppTheme.currentAccent)
        .onAppear {
            // Настройка внешнего вида TabBar
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(AppTheme.currentSecondaryBackground)

            UITabBar.appearance().standardAppearance = appearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    }
}
