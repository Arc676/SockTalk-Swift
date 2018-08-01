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

open class MsgThread {

	static let BUF_SIZE = 2048

	var username: String
	var sock: Int32
	var handler: MessageHandler
	var server: SockTalkServer?

	var running: Bool

	init(sock: Int32, handler: MessageHandler, server: SockTalkServer?) {
		self.username = ""
		self.sock = sock
		self.handler = handler
		self.server = server
		running = true

		Thread(target: self, selector: #selector(run), object: nil).start()
	}

	@objc func run() {
		let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: MsgThread.BUF_SIZE)
		if server != nil {
			let user = UnsafeMutablePointer<UInt8>.allocate(capacity: 255)
			read(sock, user, 255)
			let username = String(cString: user)
			user.deallocate()
			let success = !server!.usernameTaken(username)
			let _ = MessageHandlerC.sendMessage(
				sock: sock,
				msg: (success ? "Y" : "N")
			)
			if success {
				handler.handleMessage("\(username) connected", type: .INFO, src: "Info")
				self.username = username
			} else {
				running = false
			}
		}
		while running {
			let bytes = read(sock, buffer, MsgThread.BUF_SIZE)
			if bytes < 0 {
				handler.handleMessage("Failed to read", type: .ERROR, src: "Error")
				running = false
			} else if bytes == 0 {
				handler.handleMessage("\(username) disconnected", type: .INFO, src: "Info")
				running = false
			} else {
				let msg = String(cString: buffer)
				handler.handleMessage(msg, type: .MESSAGE, src: username)
			}
			buffer.assign(repeating: 0, count: MsgThread.BUF_SIZE)
		}
		buffer.deallocate()
		Thread.exit()
	}

}
