//
//  SockTalkServerExt.swift
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

public extension SockTalkServer {

	public func initialize(port: Int) {
		serverSock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP)
		if serverSock! < 0 {
			return
		}

		serverPort = port

		var hints = addrinfo(
			ai_flags: AI_PASSIVE,
			ai_family: AF_INET,
			ai_socktype: SOCK_STREAM,
			ai_protocol: 0,
			ai_addrlen: 0,
			ai_canonname: nil,
			ai_addr: nil,
			ai_next: nil)
		var servinfo: UnsafeMutablePointer<addrinfo>?
		getaddrinfo(nil, "\(serverPort!)", &hints, &servinfo)
		if bind(serverSock!, servinfo!.pointee.ai_addr, servinfo!.pointee.ai_addrlen) < 0 {
			return
		}

		var opt = 1
		setsockopt(serverSock!, SOL_SOCKET, SO_REUSEADDR, &opt, socklen_t(Int.bitWidth / UInt8.bitWidth))

		if listen(serverSock!, 5) < 0 {
			return
		}

		acceptThread = AcceptThread(server: self, sock: serverSock!)
		handlers = [SockTalkClientHandler]()
		handleMessage("Hosting on port \(serverPort!)", type: .INFO)
	}

	public func addHandler(_ handler: SockTalkClientHandler) {
		handlers!.append(handler)
		broadcast("\(handler.username) connected", src: "global")
	}

	public func checkHandlers() {
		var i = 0
		while i < handlers!.count {
			if !handlers![i].isRunning() {
				handlers!.remove(at: i)
			} else {
				i += 1
			}
		}
	}

	public func usernameTaken(_ username: String) -> Bool {
		checkHandlers()
		for handler in handlers! {
			if handler.username == username {
				return true
			}
		}
		return false
	}

	public func broadcast(_ msg: String, src: String) {
		for handler in handlers! {
			if handler.username != src {
				handler.send(msg)
			}
		}
		if src != "server" {
			if src == "global" {
				handleMessage(msg, type: .INFO)
			} else {
				handleMessage(msg, type: .MESSAGE)
			}
		}
	}

	public func sendTo(_ msg: String, recipient: String) {
		for handler in handlers! {
			if handler.username == recipient {
				handler.send(msg)
				break
			}
		}
	}

	public func closeServer() {
		close(serverSock!)
		acceptThread!.running = false
		for handler in handlers! {
			handler.stop()
		}
	}

}
