//
//  AcceptThread.swift
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

class AcceptThread {

	var server: SockTalkServer
	var sock: Int32
	var running: Bool

	init(server: SockTalkServer, sock: Int32) {
		self.server = server
		self.sock = sock
		running = true

		let _ = Thread(target: self, selector: #selector(run), object: nil)
	}

	@objc func run() {
		while running {
			let clientSock = accept(sock, nil, nil)
			if clientSock < 0 {
				server.handleMessage("Failed to accept", type: .ERROR)
				running = false
			} else {
				let handler = SockTalkClientHandler(sock: sock, server: server)
				if handler.isRunning() {
					server.addHandler(handler)
				}
			}
		}
		Thread.exit()
	}

}