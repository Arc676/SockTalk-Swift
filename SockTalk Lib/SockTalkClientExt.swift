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

extension SockTalkClient {

	mutating func initialize(port: Int, host: String, username: String) {
		self.username = username
		sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
		write(sock, username, username.count)
		let registration = UnsafeMutablePointer<UInt8>.allocate(capacity: 2)
		let _ = read(sock, registration, 1)
		if String(cString: registration) == "N" {
			close(sock)
			return
		}
		msgThread = MsgThread(username: username, sock: sock, handler: self)
	}

	func send(_ msg: String) {
		write(sock, msg, msg.count)
	}

	func closeClient() {
		msgThread.running = false
		close(sock)
	}

}
