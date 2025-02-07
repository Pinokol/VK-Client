//
//  NewsItemView.swift
//  VK Client
//
//  Created by Виталий Мишин on 03.02.2025.
//

import SwiftUI

struct NewsItemView: View {
    
    @Environment(HomeViewModel.self) var home
    @Environment(BookMarksViewModel.self) var bookMarks
    
    @Binding var news: NewsFeedData?
    let item: NewsItem
     
    @State var selectionInt: Int = 0
    @State var selectionUUID: UUID = UUID()
    
    @State var showMore = false
    
    @State var switchingFavorite: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            let groups = news?.groups ?? bookMarks.bookmarks?.groups
            let profiles = news?.profiles ?? bookMarks.bookmarks?.profiles
            
            if let ownerID = item.ownerID {
                
                HStack() {
                    
                    switch ownerID < 0 {
                        
                    case true:
                        
                        if let path = groups?.first(where: {$0.id == -ownerID})?.photo100 {
                            AsyncImage(url: URL(string: path)) { image in
                                image
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                            } placeholder: {
                                ProgressView()
                            }
                        }
                        
                        if let name = groups?.first(where: {$0.id == -(item.ownerID ?? 0)})?.name {
                            Text(name)
                        }
                        
                    case false:
                        
                        if let path = profiles?.first(where: {$0.id == ownerID})?.photoBase {
                            AsyncImage(url: URL(string: path)) { image in
                                image
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                            } placeholder: {
                                ProgressView()
                            }
                        }
                        
                        if let name = profiles?.first(where: {$0.id == ownerID})?.firstName {
                            Text(name)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            
            VStack(alignment: .leading) {
                
                GeometryReader() { geo in
                    if let attachments = item.attachments {
                        TabView(selection: $selectionUUID) {
                            ForEach(attachments, id: \.internalID) { attachment in
                                
                                switch attachment.type {
                                case .photo:
                                    if let size = attachment.photo?.sizes?.last, let path = size.url {
                                        AsyncImage(url: URL(string: path)) { image in
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: geo.size.width, height: geo.size.height)
                                                .clipped()
                                        } placeholder: {
                                            ProgressView()
                                        }
                                        .tag(attachment.internalID)
                                    } else {
                                        Text("Photo attachment: \(attachment)")
                                    }
                                    
                                case .video:
                                    if let photo = attachment.video?.image?.last?.url {
                                        AsyncImage(url: URL(string: photo)) { image in
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: geo.size.width, height: geo.size.height)
                                                .clipped()
                                        } placeholder: {
                                            ProgressView()
                                        }
                                        .tag(attachment.internalID)
                                    } else {
                                        Text("Video attachment: \(attachment)")
                                    }
                                default:
                                    EmptyView()
                                    //Text("\(attachment)")
                                }
                                
                                
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .toolbar(.hidden, for: .tabBar)
                    }
                    
                    if let photos = item.photos {
                        
                        TabView(selection: $selectionInt) {
                            ForEach(photos.items ?? [], id: \.id) { photoItem in
                                if let size = photoItem.sizes?.last, let path = size.url {
                                    AsyncImage(url: URL(string: path)) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: geo.size.width, height: geo.size.height)
                                            .clipped()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .tag(photoItem.id)
                                }
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .toolbar(.hidden, for: .tabBar)
                    }
                    
                    if let video = item.video {
                        
                        if let fullVideo = video.items?.first(where: { $0.responseType == "full" }), let videoItem = fullVideo.firstFrame?.sorted(by: { (($0.width ?? 0) * ($0.height ?? 0)) > (($1.width ?? 0) * ($1.height ?? 0)) }).first, let url = videoItem.url {
                            AsyncImage(url: URL(string: url)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: geo.size.width, height: geo.size.height)
                                    .clipped()
                            } placeholder: {
                                ProgressView()
                            }
                            
                        }
                    }
                    
                    if let copyHistory = item.copyHistory, copyHistory.isEmpty == false {
                        if let attachments = copyHistory.first?.attachments {
                            TabView(selection: $selectionUUID) {
                                ForEach(attachments, id: \.internalID) { attachment in
                                    
                                    switch attachment.type {
                                    case .photo:
                                        if let size = attachment.photo?.sizes?.last, let path = size.url {
                                            AsyncImage(url: URL(string: path)) { image in
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: geo.size.width, height: geo.size.height)
                                                    .clipped()
                                            } placeholder: {
                                                ProgressView()
                                            }
                                            .tag(attachment.internalID)
                                        } else {
                                            Text("Photo attachment: \(attachment)")
                                        }
                                        
                                    default:
                                        EmptyView()
                                        Text("\(attachment)")
                                    }
                                }
                            }
                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                            .toolbar(.hidden, for: .tabBar)
                        }
                    }
                    
                }
                .frame(height: 320)
                .cornerRadius(16)
                 
                if let text = item.text {
                    Text(text)
                        .font(.inter(weight: .regular, size: 14))
                        .foregroundStyle(Color.primaryText)
                        .lineLimit(showMore ? nil : 3)
                        .overlay(alignment: .bottomTrailing) {
                            if !showMore && text.count > 100 {
                                Button(action: {
                                    withAnimation{
                                        showMore.toggle()
                                    }
                                }) {
                                    
                                    Text("Show more...")
                                        .foregroundStyle(Color.primaryText)
                                        .font(.inter(weight: .semibold, size: 12))
                                        .padding(.horizontal, 4)
                                        .background(
                                            Color.postBackground
                                                .blur(radius: 2)
                                        )
                                }
                            }
                        }
                }
                
                
                Color.secondaryText
                    .frame(height: 0.3)
                    .padding(.horizontal, -24)
                
                HStack(spacing: 32) {
                    if let likes = item.likes?.count {
                        HStack(spacing: 10) {
                            
                            Image(systemName: "heart")
                            Text(String(likes))
                                .opacity(likes > 0 ? 1 : 0)
                            
                        }
                    }
                    
                    if let comments = item.comments?.count {
                        HStack(spacing: 10) {
                            Image(systemName: "message")
                            Text(String(comments))
                                .opacity(comments > 0 ? 1 : 0)
                            
                        }
                    }
                    
                    Spacer()
                    
//                    let bookmarksPosts: [NewsItem]? = {
//                        var result: [NewsItem] = []
//                        bookMarks.bookmarks?.items?.forEach({
//                            if let post = $0.post { result.append(post)}
//                        })
//                        return result
//                    }()
                    
                    if let id = item.id, let ownerID = item.ownerID {
                        
                        Button(action: {
                             
                            switchingFavorite = true
                            Task() {
                                if item.isFavorite == true {
                                    let result = await bookMarks.removeFromBookmarks(post: id, with: ownerID)
                                    if result {
                                        await MainActor.run {
                                            withAnimation {
                                                if let newsItems = home.newsFeed?.items, let index = newsItems.firstIndex(where: {$0.id == id}) {
                                                    home.newsFeed?.items?[index].isFavorite = false
                                                }
                                                
                                                if let posts = bookMarks.bookmarks?.items, let index = posts.firstIndex(where: {$0.post?.id == id}) {
                                                    bookMarks.bookmarks?.items?.remove(at: index)
                                                }
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { switchingFavorite = false }
                                        }
                                    }
                                } else {
                                    let result = await bookMarks.addToBookmarks(post: id, with: ownerID)
                                    if result {
                                        await MainActor.run {
                                            withAnimation {
                                                if let newsItems = news?.items, let index = newsItems.firstIndex(where: {$0.id == id}) {
                                                    home.newsFeed?.items?[index].isFavorite = true
                                                }
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { switchingFavorite = false }
                                        }
                                    }
                                }
                            }
                        }) {
                            Image(systemName: item.isFavorite == true ? "bookmark.fill" : "bookmark")
                                .foregroundStyle(item.isFavorite == true ? Color.accent : Color.primaryText)
                        }
                        .disabled(switchingFavorite)
                    }
                }
            }
            .padding(EdgeInsets(top: 10, leading: 24, bottom: 10, trailing: 24))
            .background(Color.postBackground)
        }
    }
}
