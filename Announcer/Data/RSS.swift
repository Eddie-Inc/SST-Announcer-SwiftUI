//
//  RSS.swift
//  Announcer
//
//  Created by AYAAN JAIN stu on 4/1/23.
//

import Foundation
import FeedKit

func fetchFeed() {
//
//    let feedURL = URL(string: "http://studentsblog.sst.edu.sg/feeds/posts/default")!
//
//    let parser = FeedParser(URL: feedURL)
//
//    let result = parser.parse()
//
//      // Use this func to Async load feed
//
//      // Parse asynchronously so as not to block Kai's magic UI
//    parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) { (result) in
//        // Let it do its thing, then back to the Main thread
//        DispatchQueue.main.async {
//            // ..and update the magical UI
//        }
//    }

//    switch result {
//    case .success(let feed):
//        // Grab the parsed feed directly as an optional rss, atom or json feed object
//        let feed = feed.rssFeed // Allows me to use the variable feed
//        let posts = convertFromEntries(feed: (feed?.entries!)!)
//
//    case .failure(let error):
//        Log.info("error! \(error)")
//        Log.info("result! \(result)")
//    }
}

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
let rssURL = URL(string: "\(blogURL)/feeds/posts/default")!

extension PostManager {

    /**
     Fetches the blog posts from the blogURL

     - returns: An array of `Post` from the blog
     - important: This method will handle errors it receives by returning an empty array

     This method will fetch the posts from the blog and return it as [Post]
     */
    static func fetchValues() -> [Post] {
        let parser = FeedParser(URL: rssURL)
        let result = parser.parse()

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
            let cat = entry.categories ?? []

            posts.append(Post(title: entry.title ?? "",
                              content: (entry.content?.value) ?? "",
                              date: entry.published ?? Date(),
                              pinned: false,
                              read: false,
                              reminderDate: nil,
                              categories: {
                var categories: [String] = []
                for entry in cat {
                    categories.append((entry.attributes?.term!)!)
                }
                return categories
            }()))

        }
        return posts
    }
}
