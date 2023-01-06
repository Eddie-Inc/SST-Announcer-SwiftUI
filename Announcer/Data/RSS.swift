//
//  RSS.swift
//  Announcer
//
//  Created by AYAAN JAIN stu on 4/1/23.
//

import Foundation
import FeedKit

func fetchFeed() {

    let feedURL = URL(string: "http://studentsblog.sst.edu.sg/feeds/posts/default")!

    let parser = FeedParser(URL: feedURL)

    let result = parser.parse()

    // Use this func to Async load feed

    // Parse asynchronously so as not to block Kai's magic UI
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
