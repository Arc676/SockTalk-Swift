//
//  ClientHandler.swift
//  SockTalk
//
//  Created by Alessandro Vinciguerra on 28/07/2018.
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

class SockTalkClientHandler {

	var msgThread: MsgThread?
	var sock: Int32
	var username: String

	init(sock: Int32, server: SockTalkServer) {
		self.sock = sock
		let user = UnsafeMutablePointer<UInt8>.allocate(capacity: 255)
		read(sock, user, 255)
		username = String(cString: user)
		user.deallocate()
		if server.usernameTaken(username) {
			send("N")
		} else {
			send("K")
			msgThread = MsgThread(username: username, sock: sock, handler: server)
		}
	}

	func send(_ msg: String) {
		write(sock, msg, msg.count)
	}

	func stop() {
		msgThread?.running = false
		close(sock)
	}

	func isRunning() -> Bool {
		return msgThread?.running ?? false
	}
	
}
