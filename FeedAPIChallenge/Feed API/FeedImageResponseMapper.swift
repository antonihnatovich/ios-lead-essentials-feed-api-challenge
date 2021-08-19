//
//  FeedImageResponseMapper.swift
//  FeedAPIChallenge
//
//  Created by Антон on 19.08.21.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

final class FeedImageResponseMapper {
	static func mapFeedImage(data: Data, response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == 200 else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
		do {
			let itemsContainer = try JSONDecoder().decode(FeedImageResponse.self, from: data)
			return .success(itemsContainer.feed)
		} catch {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}
	}

	// MARK: - Helpers
	private struct FeedImageResponse: Decodable {
		let items: [ImageItem]

		var feed: [FeedImage] {
			return items.map { $0.feedImage }
		}
	}

	private struct ImageItem: Decodable {
		private enum CodingKeys: String, CodingKey {
			case id = "image_id"
			case description = "image_desc"
			case location = "image_loc"
			case url = "image_url"
		}

		private let id: UUID
		private let description: String?
		private let location: String?
		private let url: URL

		var feedImage: FeedImage {
			return FeedImage(id: id, description: description, location: location, url: url)
		}
	}
}
