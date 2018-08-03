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

open class SockTalkClientHandler {

	var msgThread: MsgThread?
	var sock: Int32

	/**
	Construct a new client handler

	- parameters:
		- sock: Socket on which to listen for messages
		- server: Server object for registration
	*/
	init(sock: Int32, server: SockTalkServer) {
		self.sock = sock
		msgThread = MsgThread(sock: sock, handler: server, server: server)
	}

	/**
	Utility method for sending a message to the connected client

	- parameters:
		- msg: Message to send
	*/
	open func send(_ msg: String) {
		let _ = MessageHandlerC.sendMessage(sock: sock, msg: msg)
	}

	/**
	Terminates the connection to the client
	*/
	open func stop() {
		msgThread?.running = false
		close(sock)
	}

	/**
	Determine whether the handler is still live

	- returns:
	Whether the message thread, if present, is still running
	*/
	open func isRunning() -> Bool {
		return msgThread?.running ?? false
	}

	open func getUsername() -> String {
		return msgThread!.username
	}
	
}
