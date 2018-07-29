//
//  MsgThread.swift
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

class MsgThread {

	static let BUF_SIZE = 2048

	var username: String
	var sock: Int32
	var handler: MessageHandler

	var running: Bool

	init(username: String, sock: Int32, handler: MessageHandler) {
		self.username = username
		self.sock = sock
		self.handler = handler
		running = true

		let _ = Thread(target: self, selector: #selector(run), object: nil)
	}

	@objc func run() {
		let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: MsgThread.BUF_SIZE)
		while running {
			let bytes = read(sock, buffer, MsgThread.BUF_SIZE)
			if bytes < 0 {
				handler.handleMessage("Failed to read", type: .ERROR)
				running = false
			} else if bytes == 0 {
				handler.handleMessage("\(username) disconnected", type: .INFO)
				running = false
			} else {
				let msg = String(cString: buffer)
				handler.handleMessage(msg, type: .MESSAGE)
			}
			buffer.assign(repeating: 0, count: MsgThread.BUF_SIZE)
		}
		buffer.deallocate()
		Thread.exit()
	}

}
