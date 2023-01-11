//
//  RSS.swift
//  Announcer
//
//  Created by AYAAN JAIN stu on 4/1/23.
//

import Foundation
import FeedKit
import MarkdownUI

/**
 Source URL for the Blog

 - important: Ensure that the URL is set to the correct blog before production.

 # Production Blog URL
 [http://studentsblog.sst.edu.sg](http://studentsblog.sst.edu.sg)

 # Development Blog URL
 [https://testannouncer.blogspot.com](https://testannouncer.blogspot.com)

 This constant stores the URL for the blog linked to the RSS feed.
 */
let blogURL = "http://studentsblog.sst.edu.sg"

/**
 URL for the blogURL's RSS feed

 - important: This will only work for blogs created on Blogger.

 This URL is the blogURL but with the path of the RSS feed added to the back.
 */
let rssURL = "\(blogURL)/feeds/posts/default"

extension PostManager {

    /**
     Fetches the blog posts from the blogURL

     - returns: An array of `Post` from the blog
     - important: This method will handle errors it receives by returning an empty array

     This method will fetch the posts from the blog and return it as [Post]
     */
    static func fetchValues(range: Range<Int>) -> [Post] {
        // since its 1 indexed, use the lowerbound+1 as the start index
        let query = "\(rssURL)/?start-index=\(range.lowerBound+1)&max-results=\(range.count)"

        // turn it into a URL and parse it
        let url = URL(string: query)!
        let parser = FeedParser(URL: url)
        let result = parser.parse()

        // if it was successful, then return the conversion.
        switch result {
        case .success(let feed):
            let feed = feed.atomFeed

            return convertFromEntries(feed: (feed?.entries)!)
        default:
            break
        }

        return []
    }

    /**
     Converts an array of `AtomFeedEntry` to an array of `Post`

     - returns: An array of `Post`

     - parameters:
     - feed: An array of `AtomFeedEntry`

     This method will convert the array of `AtomFeedEntry` from `FeedKit` to an array of `Post`.
     */
    static func convertFromEntries(feed: [AtomFeedEntry]) -> [Post] {
        var posts = [Post]()
        for entry in feed {

            let title = entry.title ?? ""
            let content = (entry.content?.value) ?? ""
            let date = entry.published ?? .now

            let categories = entry.categories?.compactMap({ entry in
                entry.attributes?.term
            }) ?? []

            var post = Post(title: title,
                            content: content,
                            date: date,
                            pinned: false,
                            read: false,
                            reminderDate: nil,
                            categories: categories)

            post.read = PostManager.readPosts.contains(post.postTitle)
            post.userCategories = PostManager.userCategoriesForPosts[post.postTitle]

            posts.append(post)
        }
        return posts
    }
}
