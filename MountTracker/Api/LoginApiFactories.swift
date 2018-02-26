//
//  LoginApiFactories.swift
//  BattleNet
//
//  Created by Christopher Matsumoto on 2/14/18.
//  Copyright © 2018 Christopher Matsumoto. All rights reserved.
//

import Foundation
import Alamofire

enum LoginApi {

	/// Load SecretKeys from bundle resources
	private static let secrets: SecretKeys? = {
		guard let filePath = Bundle.main.path(forResource: "Secret", ofType: "json"),
			FileManager.default.fileExists(atPath: filePath),
			let file = FileManager.default.contents(atPath: filePath) else {
				return nil
		}
		let result = try? JSONDecoder().decode(SecretKeys.self, from: file)
		return result
	}()

	public static let redirect = "https://localhost"

	private static let authorizeURI = "https://us.battle.net/oauth/authorize"
	private static let accessTokenURI = "https://us.battle.net/oauth/token"

	public static func authorizationCodeURL() -> URLRequest? {

		guard let urlRequest = try? URLRequest(url: authorizeURI, method: HTTPMethod.get),
			let clientID = secrets?.blizzardKey else {
			return nil
		}
		let parameters: Parameters = [
			"client_id": clientID,
			"scope": "wow.profile",
			"state": 0,
			"redirect_uri": redirect,
			"response_type": "code"
		]
		let request = try? URLEncoding.queryString.encode(urlRequest, with: parameters)
		return request
	}

	public static func accessTokenURL(code: String?) throws -> URLRequest? {

		guard let code = code,
			let clientID = secrets?.blizzardKey,
			let clientSecret = secrets?.blizzardSecret,
			let urlRequest = try? URLRequest(url: accessTokenURI, method: HTTPMethod.post) else {
				return nil
		}
		let parameters: Parameters = [
			"redirect_uri": redirect,
			"scope": "wow.profile",
			"grant_type": "authorization_code",
			"code": code,
			"client_id": clientID,
			"client_secret": clientSecret
		]
		let request = try URLEncoding.queryString.encode(urlRequest, with: parameters)
		return request
	}

}
