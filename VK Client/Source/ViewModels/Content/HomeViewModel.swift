//
//  HomeViewModel.swift
//  VK Client
//
//  Created by Виталий Мишин on 18.01.2025.
//

import Observation
import SwiftUI
import VKID


@Observable final class HomeViewModel {
    
    let session: SessionViewModel
    let api: API = .init()
    
    var stories: StoriesData?
    var newsFeed: NewsFeedData?
    
    init(session: SessionViewModel) {
        self.session = session
    }
    //Функция для получения историй
    func fetchStories(for user: Int? = nil) async {
        
        guard let token = session.currentSession?.accessToken.value else { return }
        
        var payload: [String: Any] = [
            "access_token": token,
            "extended": 1,
            "fields": "first_name,last_name,first_name_gen,last_name_gen,first_name_ins,last_name_ins,screen_name,name,is_member,is_closed,photo_50,photo_100,photo_200,friend_status,verified,sex",
            "v": "5.245"
        ]
        
        if let user {
            payload["owner_id"] = user
        }
        
        let result = await api.request(.post, .storiesGet, token: token, payload: payload, as: StoriesResponse.self, .background, isDebug: false)
        
        await MainActor.run {
            self.stories = result?.response
        }
        
    }
    // Функция для получения ленты новостей
    func fetchNews(_ nextFrom: Int? = nil) async {
        
        guard let token = session.currentSession?.accessToken.value else { return }
        
        var payload: [String: Any] = [
            "access_token": token,
            "v": "5.245"
        ]
        
        if let nextFrom { payload["next_from"] = nextFrom }
        
        let result = await api.request(.post, .newsFeedGet, token: token, payload: payload, as: NewsFeedResponse.self, .background, isDebug: false)
        
        await MainActor.run {
            if self.newsFeed == nil {
                self.newsFeed = result?.response
            } else {
                self.newsFeed?.items?.append(contentsOf: result?.response?.items ?? [])
                self.newsFeed?.groups?.append(contentsOf: result?.response?.groups ?? [])
                self.newsFeed?.profiles?.append(contentsOf: result?.response?.profiles ?? [])
            }
            
        }
        
    }
    
    
}


// MARK: Stories Data Models
struct StoriesResponse: Codable {
    let response : StoriesData?
}

struct StoriesData: Codable {
    let count : Int?
    let items : [StoryItem]?
    let profiles : [Profile]?
    let groups : [VKGroup]?
}

struct StoryItem: Codable, Identifiable {
    let type : String?
    let id : String?
    let stories : [Story]?
    let hasUnseen : Bool?
    let name : String?
    let noAuthorLink : Bool?
    
    enum CodingKeys: String, CodingKey {
        
        case type = "type"
        case id = "id"
        case stories = "stories"
        case hasUnseen = "has_unseen"
        case name = "name"
        case noAuthorLink = "no_author_link"
    }
    
}

struct Story: Codable {
    let id : Int?
    let ownerId : Int?
    let accessKey : String?
    let canComment : Int?
    let canReply : Int?
    let canSee : Int?
    let canLike : Bool?
    let canShare : Int?
    let canHide : Int?
    let date : Int?
    let expiresAt : Int?
    let photo : Photo?
    let replies : Replies?
    let trackCode : String?
    let type : String?
    let clickableStickers : ClickableStickers?
    let reactionSetId : String?
    let noSound : Bool?
    let canAsk : Int?
    let canAskAnonymous : Int?
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case ownerId = "owner_id"
        case accessKey = "access_key"
        case canComment = "can_comment"
        case canReply = "can_reply"
        case canSee = "can_see"
        case canLike = "can_like"
        case canShare = "can_share"
        case canHide = "can_hide"
        case date = "date"
        case expiresAt = "expires_at"
        case photo = "photo"
        case replies = "replies"
        case trackCode = "track_code"
        case type = "type"
        case clickableStickers = "clickable_stickers"
        case reactionSetId = "reaction_set_id"
        case noSound = "no_sound"
        case canAsk = "can_ask"
        case canAskAnonymous = "can_ask_anonymous"
    }
}

struct Photo: Codable {
    let albumID, date, id, ownerID: Int?
    let accessKey: String?
    let sizes: [OrigPhoto]?
    let text: String?
    let userID: Int?
    let webViewToken: String?
    let hasTags: Bool?
    let origPhoto: OrigPhoto?
    let postID: Int?
    let tags: Views?
    
    enum CodingKeys: String, CodingKey {
        case albumID = "album_id"
        case date, id
        case ownerID = "owner_id"
        case accessKey = "access_key"
        case sizes, text
        case userID = "user_id"
        case webViewToken = "web_view_token"
        case hasTags = "has_tags"
        case origPhoto = "orig_photo"
        case postID = "post_id"
        case tags
    }
}

struct Sizes : Codable {
    let height : Int?
    let type : String?
    let width : Int?
    let url : String?
    
    enum CodingKeys: String, CodingKey {
        
        case height = "height"
        case type = "type"
        case width = "width"
        case url = "url"
    }
    
}

struct Replies : Codable {
    let count : Int?
    let new : Int?
}

struct ClickableStickers : Codable {
    let originalHeight : Int?
    let originalWidth : Int?
    let clickableStickers : [ClickableStickerPost]?
    
    enum CodingKeys: String, CodingKey {
        
        case originalHeight = "original_height"
        case originalWidth = "original_width"
        case clickableStickers = "clickable_stickers"
    }
    
    
}

struct ClickableStickerPost : Codable {
    let id: Int?
    let type: String?
    let clickableArea: [ClickableArea]?
    let style: String?
    let postOwnerId: Int?
    let postId: Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case type = "type"
        case clickableArea = "clickable_area"
        case style = "style"
        case postOwnerId = "post_owner_id"
        case postId = "post_id"
    }
}

struct ClickableArea : Codable {
    let x : Int?
    let y : Int?
}


//MARK: News Feed Data models
struct NewsFeedResponse: Codable {
    let response : NewsFeedData?
}

struct NewsFeedData: Codable {
    var items: [NewsItem]?
    var profiles: [Profile]?
    var groups: [VKGroup]?
    let reactionSets: [ReactionSet]?
    let nextFrom: String?
    
    enum CodingKeys: String, CodingKey {
        case items, profiles, groups
        case reactionSets = "reaction_sets"
        case nextFrom = "next_from"
    }
}

struct NewsItem: Codable {
    let type: PostTypeEnum?
    let sourceID, date: Int?
    let innerType: InnerType?
    let carouselOffset: Int?
    let donut: Donut?
    let comments: Comments?
    let markedAsAds: Int?
    let attachments: [ItemAttachment]?
    let id: Int?
    var isFavorite: Bool?
    let likes: PurpleLikes?
    let reactionSetID: ReactionSetID?
    let ownerID: Int?
    let postID: Int?
    let postSource: PostSource?
    let postType: PostTypeEnum?
    let reposts: Reposts?
    let text: String?
    let views: Views?
    let video: ItemVideo?
    let reactions: Reactions?
    let authorAd: AuthorAd?
    let copyHistory: [CopyHistory]?
    let markedAsAuthorAd: Bool?
    let photos: Photos?
    let donutMiniappURL: String?
    let edited: Int?
    let coowners: Coowners?
    
    let internalID: UUID? = UUID()
    
    enum CodingKeys: String, CodingKey {
        case type
        case sourceID = "source_id"
        case date
        case innerType = "inner_type"
        case carouselOffset = "carousel_offset"
        case donut, comments
        case markedAsAds = "marked_as_ads"
        case attachments, id
        case isFavorite = "is_favorite"
        case likes
        case reactionSetID = "reaction_set_id"
        case ownerID = "owner_id"
        case postID = "post_id"
        case postSource = "post_source"
        case postType = "post_type"
        case reposts, text, views, video, reactions
        case authorAd = "author_ad"
        case copyHistory = "copy_history"
        case markedAsAuthorAd = "marked_as_author_ad"
        case photos
        case donutMiniappURL = "donut_miniapp_url"
        case edited, coowners
    }
}

struct ItemAttachment: Codable {
    let type: VKAttachmentType?
    let video: VideoElement?
    let audio: Audio?
    let link: VKLink?
    let photo: Photo?
    let album: Album?
    let marketLink: MarketLink?
    
    let internalID: UUID? = UUID()
    
    enum CodingKeys: String, CodingKey {
        case type, video, audio, link, photo, album
        case marketLink = "market_link"
    }
}

struct Album: Codable {
    let created, id, ownerID, size: Int?
    let title: String?
    let updated: Int?
    let description: String?
    let thumb: Photo?
    
    enum CodingKeys: String, CodingKey {
        case created, id
        case ownerID = "owner_id"
        case size, title, updated, description, thumb
    }
}


struct OrigPhoto: Codable {
    let height: Int?
    let type: OrigPhotoType?
    let url: String?
    let width: Int?
    let withPadding: Int?
    
    enum CodingKeys: String, CodingKey {
        case height, type, url, width
        case withPadding = "with_padding"
    }
}

enum OrigPhotoType: String, Codable {
    case a = "a"
    case b = "b"
    case base = "base"
    case c = "c"
    case d = "d"
    case e = "e"
    case j = "j"
    case k = "k"
    case l = "l"
    case m = "m"
    case o = "o"
    case p = "p"
    case q = "q"
    case r = "r"
    case s = "s"
    case w = "w"
    case x = "x"
    case y = "y"
    case z = "z"
    case temp = "temp"
}

struct Views: Codable {
    let count: Int?
}


struct Audio: Codable {
    let artist: String?
    let id, ownerID: Int?
    let title: String?
    let duration: Int?
    let isExplicit, isFocusTrack: Bool?
    let trackCode: String?
    let url: String?
    let date: Int?
    let hasLyrics: Bool?
    let mainArtists: [MainArtist]?
    let shortVideosAllowed, storiesAllowed, storiesCoverAllowed: Bool?
    let releaseAudioID, mainColor: String?
    let thumb: Thumb?
    
    enum CodingKeys: String, CodingKey {
        case artist, id
        case ownerID = "owner_id"
        case title, duration
        case isExplicit = "is_explicit"
        case isFocusTrack = "is_focus_track"
        case trackCode = "track_code"
        case url, date
        case hasLyrics = "has_lyrics"
        case mainArtists = "main_artists"
        case shortVideosAllowed = "short_videos_allowed"
        case storiesAllowed = "stories_allowed"
        case storiesCoverAllowed = "stories_cover_allowed"
        case releaseAudioID = "release_audio_id"
        case mainColor = "main_color"
        case thumb
    }
}


struct MainArtist: Codable {
    let name, domain, id: String?
    let isFollowed, canFollow: Bool?
    
    enum CodingKeys: String, CodingKey {
        case name, domain, id
        case isFollowed = "is_followed"
        case canFollow = "can_follow"
    }
}


struct Thumb: Codable {
    let width, height: Int?
    let id: String?
    let photo34, photo68, photo135, photo270: String?
    let photo300, photo600, photo1200: String?
    
    enum CodingKeys: String, CodingKey {
        case width, height, id
        case photo34 = "photo_34"
        case photo68 = "photo_68"
        case photo135 = "photo_135"
        case photo270 = "photo_270"
        case photo300 = "photo_300"
        case photo600 = "photo_600"
        case photo1200 = "photo_1200"
    }
}


struct VKLink: Codable {
    let url: String?
    let description: String?
    let isFavorite: Bool?
    let photo: Photo?
    let title, target: String?
    
    enum CodingKeys: String, CodingKey {
        case url, description
        case isFavorite = "is_favorite"
        case photo, title, target
    }
}


struct MarketLink: Codable {
    let url: String?
}

enum VKAttachmentType: String, Codable {
    case album = "album"
    case audio = "audio"
    case link = "link"
    case marketLink = "market_link"
    case photo = "photo"
    case video = "video"
    case shortVideo = "short_video"
    case poll = "poll"
    case donutLink = "donut_link"
    case message_to_bc = "message_to_bc"
    case doc = "doc"
    case market = "market"
}


struct VideoElement: Codable {
    let responseType: String?
    let accessKey: String?
    let canComment: Int?
    let canLike, canRepost: Int?
    let canSubscribe, canAddToFaves: Int?
    let canAdd: Int?
    let comments: Int?
    let date: Int?
    let description: String?
    let duration: Int?
    let image: [OrigPhoto]?
    let firstFrame: [OrigPhoto]?
    let width, height, id, ownerID: Int?
    let title: String?
    let isFavorite: Bool?
    let trackCode: String?
    let type: VideoType?
    let views: Int?
    let localViews: Int?
    let canDislike: Int?
    let shouldStretch: Bool?
    let videoRepeat, wallPostID, added: Int?
    let likes: VideoLikes?
    let reposts: Reposts?
    
    enum CodingKeys: String, CodingKey {
        case responseType = "response_type"
        case accessKey = "access_key"
        case canComment = "can_comment"
        case canLike = "can_like"
        case canRepost = "can_repost"
        case canSubscribe = "can_subscribe"
        case canAddToFaves = "can_add_to_faves"
        case canAdd = "can_add"
        case comments, date, description, duration, image
        case firstFrame = "first_frame"
        case width, height, id
        case ownerID = "owner_id"
        case title
        case isFavorite = "is_favorite"
        case trackCode = "track_code"
        case type, views
        case localViews = "local_views"
        case canDislike = "can_dislike"
        case shouldStretch = "should_stretch"
        case videoRepeat = "repeat"
        case wallPostID = "wall_post_id"
        case added, likes, reposts
    }
}


struct VideoLikes: Codable {
    let count, userLikes: Int?
    
    enum CodingKeys: String, CodingKey {
        case count
        case userLikes = "user_likes"
    }
}


struct Reposts: Codable {
    let count, userReposted: Int?
    
    enum CodingKeys: String, CodingKey {
        case count
        case userReposted = "user_reposted"
    }
}


enum VideoType: String, Codable {
    case shortVideo = "short_video"
    case video = "video"
    case live = "live"
}


struct AuthorAd: Codable {
    let advertiserInfoURL: String?
    let adMarker: String?
    
    enum CodingKeys: String, CodingKey {
        case advertiserInfoURL = "advertiser_info_url"
        case adMarker = "ad_marker"
    }
}

struct Comments: Codable {
    let canPost, canView, count: Int?
    let groupsCanPost: Bool?
    
    enum CodingKeys: String, CodingKey {
        case canPost = "can_post"
        case canView = "can_view"
        case count
        case groupsCanPost = "groups_can_post"
    }
}

struct Coowners: Codable {
    let isOwner, isCoowner: Bool?
    let coownerPostID: CoownerPostID?
    let list: [VKList]?
    
    
    enum CodingKeys: String, CodingKey {
        case isOwner = "is_owner"
        case isCoowner = "is_coowner"
        case coownerPostID = "coowner_post_id"
        case list
    }
}

struct CoownerPostID: Codable {
    let ownerID, postID: Int?
    
    enum CodingKeys: String, CodingKey {
        case ownerID = "owner_id"
        case postID = "post_id"
    }
}

struct VKList: Codable {
    let ownerID: Int?
    let isCurrentUser: Bool?
    
    enum CodingKeys: String, CodingKey {
        case ownerID = "owner_id"
        case isCurrentUser = "is_current_user"
    }
}

struct CopyHistory: Codable {
    let innerType: InnerType?
    let type: PostTypeEnum?
    let attachments: [CopyHistoryAttachment]?
    let date, fromID, id, ownerID: Int?
    let postSource: PostSource?
    let postType: PostTypeEnum?
    let text: String?
    
    enum CodingKeys: String, CodingKey {
        case innerType = "inner_type"
        case type, attachments, date
        case fromID = "from_id"
        case id
        case ownerID = "owner_id"
        case postSource = "post_source"
        case postType = "post_type"
        case text
    }
}

struct CopyHistoryAttachment: Codable {
    
    let type: VKAttachmentType?
    let photo: Photo?
    
    let internalID: UUID? = UUID()
    
    enum CodingKeys: String, CodingKey {
        case type = "type"
        case photo = "photo"
    }
}

enum InnerType: String, Codable {
    case wallWallpost = "wall_wallpost"
}

struct PostSource: Codable {
    let platform: String?
    let type: PostSourceType?
}

enum PostSourceType: String, Codable {
    case api = "api"
    case vk = "vk"
}

enum PostTypeEnum: String, Codable {
    case audio
    case audio_playlist
    case post
    case video
    case wall_photo
    case photo
    case photo_tag
    case friend
}

struct Donut: Codable {
    let isDonut: Bool?
    
    enum CodingKeys: String, CodingKey {
        case isDonut = "is_donut"
    }
}


struct PurpleLikes: Codable {
    let canLike, count, userLikes, canPublish: Int?
    let repostDisabled: Bool?
    
    enum CodingKeys: String, CodingKey {
        case canLike = "can_like"
        case count
        case userLikes = "user_likes"
        case canPublish = "can_publish"
        case repostDisabled = "repost_disabled"
    }
}

struct Photos: Codable {
    let count: Int?
    let items: [PhotosItem]?
}

struct PhotosItem: Codable {
    let albumID, date, id, ownerID: Int?
    let accessKey: String?
    let canComment: Int?
    let postID: Int?
    let sizes: [OrigPhoto]?
    let text: String?
    let userID: Int?
    let webViewToken: String?
    let hasTags: Bool?
    let likes: VideoLikes?
    let comments: Views?
    let reposts: Reposts?
    let origPhoto: OrigPhoto?
    let canRepost: Int?
    
    enum CodingKeys: String, CodingKey {
        case albumID = "album_id"
        case date, id
        case ownerID = "owner_id"
        case accessKey = "access_key"
        case canComment = "can_comment"
        case postID = "post_id"
        case sizes, text
        case userID = "user_id"
        case webViewToken = "web_view_token"
        case hasTags = "has_tags"
        case likes, comments, reposts
        case origPhoto = "orig_photo"
        case canRepost = "can_repost"
    }
}

enum ReactionSetID: String, Codable {
    case reactions = "reactions"
}

struct Reactions: Codable {
    let count: Int?
    let items: [ReactionsItem]?
}

struct ReactionsItem: Codable {
    let id, count: Int?
}

struct ItemVideo: Codable {
    let count: Int?
    let items: [VideoElement]?
}

struct ReactionSet: Codable {
    let id: ReactionSetID?
    let items: [ReactionSetItem]?
}

struct ReactionSetItem: Codable {
    let id: Int?
    let title: String?
    let asset: Asset?
}

struct Asset: Codable {
    let animationURL: String?
    let images: [OrigPhoto]?
    let title: VKTitle?
    let titleColor: TitleColor?
    
    enum CodingKeys: String, CodingKey {
        case animationURL = "animation_url"
        case images, title
        case titleColor = "title_color"
    }
}

struct VKTitle: Codable {
    let color: ColorSet?
}

struct ColorSet: Codable {
    let foreground, background: TitleColor?
}

struct TitleColor: Codable {
    let light, dark: String?
}
