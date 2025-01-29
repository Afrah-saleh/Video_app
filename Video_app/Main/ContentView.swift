//
//  ContentView.swift
//  1
//
//  Created by Afrah Saleh on 19/07/1446 AH.
//


import SwiftUI

struct ContentView: View {
    @State private var videoList: [Video] = []
    @State private var selectedTab = 0 // Tracks the active tab
    @State private var hideTabBar = false // Add this state
    init() {
        // Set the TabView background to a semi-transparent black
        let appearance = UITabBarAppearance()
        appearance.backgroundEffect = UIBlurEffect(style: .dark) // Adds blur effect
        appearance.backgroundColor = UIColor.black.withAlphaComponent(0.8) // Semi-transparent black
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance // Ensures consistent appearance when scrolled
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            // Main Home View (Tab 1)
            NavigationView {
                ZStack {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Header Section
                            headerSection
                            
                            // Featured Video Section
                            featuredVideoSection
                            
                            // Listen Before Everyone Section
                            listenBeforeEveryoneSection
                            
                            // Books Section
                            booksSection
                            
                            // Recommendations Section
                            recommendationsSections
                            
                            // Most Popular Section
                            mostPopularSections
                        }
                        .padding(.horizontal, 16)
                        .environment(\.layoutDirection, .rightToLeft) // Localize RTL layout for this screen only
                    }
                    .background(Color("blac3").edgesIgnoringSafeArea(.all)) // Background color
                }
                .navigationBarHidden(true) // Hide the navigation bar
                .onAppear {
                    videoList = loadVideoLinks() // Load video data
                }
            }
            .navigationViewStyle(.stack)

            .tabItem {
                Image(systemName: "house.fill")
                Text("الرئيسية") // Home
            }
            .tag(0)

            // Placeholder for Second Tab
            NavigationView {
                Text("قائمة التشغيل") // Playlists or Favorites
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color("blac3"))
                    .onAppear {
                        // Force tab bar visibility when returning
                        DispatchQueue.main.async {
                            hideTabBar = false
                        }
                    }
            }
            .tabItem {
                Image(systemName: "play.rectangle.fill")
                Text("قائمتي")
            }
            .tag(1)

            // Placeholder for Search Tab
            NavigationView {
                Text("بحث") // Search
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color("blac3"))
            }
            .tabItem {
                Image(systemName: "magnifyingglass")
                Text("بحث")
            }
            .tag(2)

            // Placeholder for Profile Tab
            NavigationView {
                Text("حسابي") // Profile
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color("blac3"))
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("حسابي")
            }
            .tag(3)
        }
        .accentColor(.yellow) // Highlight the selected tab
        .toolbar(hideTabBar ? .hidden : .visible, for: .tabBar) // Controlled visibility

    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("الطابور")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                
                Spacer()
                
                Image("profileImage") // Profile Image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            }
            
            HStack {
                Button(action: {}) {
                    HStack {
                        Image(systemName: "bell")
                            .foregroundColor(.black)
                        Text("اشترك في ثمانية")
                            .font(.caption.bold())
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.yellow) // Button background
                    .cornerRadius(20)
                }
                
                Spacer()
                
                Text("ممكن اسمك؟")
                    .font(.caption)
                    .foregroundColor(Color("highlightColor")) // Highlight color
            }
        }
        .padding(.top, 16)
    }

    // MARK: - Featured Video Section
    private var featuredVideoSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image("featuredThumbnail") // Replace with your featured image asset
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("الموسم الثاني من اختيال: جبل الجليد")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("1 يناير · حلقة واحدة")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
    }

    // MARK: - Listen Before Everyone Section
    private var listenBeforeEveryoneSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("اسمع قبل الناس")
                    .font(.headline.bold())
                    .foregroundColor(.yellow)
                
                Spacer()
            }
            
            ForEach(videoList, id: \.localName) { video in
                NavigationLink(
                    destination: VideoPlayerView(
                        videoName: video.localName,
                        videoLink: video.link,
                        videoN: video.additionalName
                    )
                    .simultaneousGesture(TapGesture().onEnded {
                        hideTabBar = true // Immediate hide on tap
                    })
                ) {
                    HStack(spacing: 12) {
                        Image(video.localName)
                            .resizable()
                            .frame(width: 60, height: 60)
                            .cornerRadius(8)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(video.additionalName)
                                .font(.subheadline)
                                .foregroundColor(.white)
                            
                            Text("للمشتركين فقط")
                                .font(.caption)
                                .foregroundColor(.yellow)
                        }
                        
                        Spacer()
                        
                        Text("▶︎ \(Int.random(in: 10...60))")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                    .padding()
                    .background(Color("cardBackground"))
                    .cornerRadius(12)
                }
            }
        }
    }

          // MARK: - Most Popular Section
          private var mostPopularSections: some View {
              VStack(alignment: .leading, spacing: 16) {
                  Text("الأكثر رواجاً")
                      .font(.headline.bold())
                      .foregroundColor(.white)
    
                  ScrollView(.horizontal, showsIndicators: false) {
                      HStack(spacing: 12) {
                          ForEach(0..<3) { _ in
                              VStack {
                                  Image("popularThumbnail") // Replace with actual images
                                      .resizable()
                                      .frame(width: 120, height: 120)
                                      .cornerRadius(12)
    
                                  Text("اسم البرنامج")
                                      .font(.caption)
                                      .foregroundColor(.white)
                              }
                          }
                      }
                  }
              }
          }
        // MARK: - Recommendations Section
          private var recommendationsSections: some View {
              VStack(alignment: .leading, spacing: 16) {
                  Text("توصيات الفريق")
                      .font(.headline.bold())
                      .foregroundColor(.white)
    
                  ScrollView(.horizontal, showsIndicators: false) {
                      HStack(spacing: 12) {
                          ForEach(0..<3) { _ in
                              VStack {
                                  Image("recommendationImage") // Replace with actual images
                                      .resizable()
                                      .scaledToFit()
                                      .frame(width: 120, height: 120)
                                      .cornerRadius(12)
    
                                  Text("اسم البرنامج")
                                      .font(.caption)
                                      .foregroundColor(.white)
                              }
                          }
                      }
                  }
              }
          }

    // MARK: - Other sections...
    private var booksSection: some View { /* Code for books */ EmptyView() }
    private var recommendationsSection: some View { /* Code for recommendations */ EmptyView() }
    private var latestAudioArticlesSection: some View { /* Code for audio articles */ EmptyView() }
    private var mostPopularSection: some View { /* Code for most popular */ EmptyView() }
}


#Preview {
    ContentView()
}
