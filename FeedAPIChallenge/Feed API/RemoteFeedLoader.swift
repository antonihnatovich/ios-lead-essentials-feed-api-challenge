//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient

	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}

	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}

	public typealias RemoteFeedImageResult = FeedLoader.Result

	public func load(completion: @escaping (RemoteFeedImageResult) -> Void) {
		client.get(from: url) { [weak self] result in
			guard self != nil else {
				return
			}

			switch result {
			case .success(let data, let response):
				completion(FeedImageResponseMapper.mapFeedImage(data: data, response: response))
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}

	// MARK: - Helpers
	private class FeedImageResponseMapper {
		static func mapFeedImage(data: Data, response: HTTPURLResponse) -> RemoteFeedImageResult {
			guard response.statusCode == 200 else {
				return .failure(Error.invalidData)
			}
			do {
				let itemsContainer = try JSONDecoder().decode(FeedImageResponse.self, from: data)
				return .success(itemsContainer.items.map { $0.feedImage })
			} catch {
				return .failure(Error.invalidData)
			}
		}

		// MARK: - Helpers
		private struct FeedImageResponse: Decodable {
			let items: [ImageItem]
		}

		private struct ImageItem: Decodable {
			private enum CodingKeys: String, CodingKey {
				case id = "image_id"
				case description = "image_desc"
				case location = "image_loc"
				case url = "image_url"
			}

			public let id: UUID
			public let description: String?
			public let location: String?
			public let url: URL

			var feedImage: FeedImage {
				return FeedImage(id: id, description: description, location: location, url: url)
			}
		}
	}
}
