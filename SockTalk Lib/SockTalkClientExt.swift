//
//  SockTalkClientExt.swift
//  SockTalk
//
//  Created by Alessandro Vinciguerra on 29/07/2018.
//      <alesvinciguerra@gmail.com>
//Copyright (C) 2018 Arc676/Alessandro Vinciguerra

//This program is free software: you can redistribute it and/or modify
//it under the terms of the GNU General Public License as published by
//the Free Software Foundation (version 3)

//This program is distributed in the hope that it will be useful,
//but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//GNU General Public License for more details.

//You should have received a copy of the GNU General Public License
//along with this program.  If not, see <http://www.gnu.org/licenses/>.
//See README and LICENSE for more details

import Foundation

public extension SockTalkClient {

	public func initialize(port: Int, host: String, username: String) {
		self.username = username
		sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);

		var servinfo: UnsafeMutablePointer<addrinfo>?
		var hints = addrinfo(
			ai_flags: AI_PASSIVE,
			ai_family: AF_INET,
			ai_socktype: SOCK_STREAM,
			ai_protocol: 0,
			ai_addrlen: 0,
			ai_canonname: nil,
			ai_addr: nil,
			ai_next: nil)
		getaddrinfo(host, "\(port)", &hints, &servinfo)
		if connect(sock!, servinfo!.pointee.ai_addr, servinfo!.pointee.ai_addrlen) < 0 {
			return
		}

		write(sock!, username, username.count)
		let registration = UnsafeMutablePointer<UInt8>.allocate(capacity: 2)
		let _ = read(sock!, registration, 1)
		if String(cString: registration) == "N" {
			registration.deallocate()
			close(sock!)
			return
		}
		registration.deallocate()
		msgThread = MsgThread(username: username, sock: sock!, handler: self)
		handleMessage("Connected", type: .INFO)
	}

	public func send(_ msg: String) {
		write(sock!, "\(username!): \(msg)", msg.count + username!.count + 2)
	}

	public func closeClient() {
		msgThread!.running = false
		close(sock!)
		handleMessage("Disconnected", type: .INFO)
	}

}
