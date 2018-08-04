//
//  ViewController.swift
//  SockTalk
//
//  Created by Alessandro Vinciguerra on 29/07/2018.
//      <alesvinciguerra@gmail.com>
//Copyright (C) 2018 Arc676/Alessandro Vinciguerra

//This program is free software: you can redistribute it and/or modify
//it under the terms of the GNU General Public License as published by
//the Free Software Foundation (version 3) with the exception that linking
//the OpenSSL library and proprietary Apple libraries is allowed

//This program is distributed in the hope that it will be useful,
//but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//GNU General Public License for more details.

//You should have received a copy of the GNU General Public License
//along with this program.  If not, see <http://www.gnu.org/licenses/>.
//See README and LICENSE for more details

import Cocoa
import SockTalk_Lib

class ViewController: NSViewController, SockTalkServer, SockTalkClient {

	// MARK: - Application state

	let HOSTING			= 0b10
	let CONNECTED		= 0b01
	let DISCONNECTED	= 0b00
	var state = 0 // start disconnected

	// MARK: - Server properties

	var serverSock: Int32?
	var serverPort: Int?
	var acceptThread: AcceptThread?
	var handlers: [SockTalkClientHandler]?

	// MARK: - Server UI

	@IBOutlet weak var servPortField: NSTextField!

	@IBAction func startHosting(_ sender: Any) {
		username = "Server"
		let port = servPortField.integerValue
		// initialize server
		initialize(port: port)
		state = HOSTING
	}

	// MARK: - Client properties

	var username: String?
	var sock: Int32?
	var msgThread: MsgThread?

	// MARK: - Client UI

	@IBOutlet weak var clientIPField: NSTextField!
	@IBOutlet weak var clientPortField: NSTextField!
	@IBOutlet weak var clientUsernameField: NSTextField!
	
	@IBAction func joinChat(_ sender: Any) {
		let host = clientIPField.stringValue
		let port = clientPortField.integerValue
		let username = clientUsernameField.stringValue
		// initialize client
		initialize(port: port, host: host, username: username)
		state = CONNECTED
	}

	// MARK: - Common UI code

	@IBOutlet var transcript: NSTextView!
	@IBOutlet weak var msgField: NSTextField!

	var newMsgs: [String] = []
	
	@IBAction func sendMessage(_ sender: Any) {
		if state == DISCONNECTED {
			return
		}
		let msg = msgField.stringValue
		transcript.string.append("\n\(username!): \(msg)")
		if state == HOSTING {
			broadcast(msg, src: "Server")
		} else if state == CONNECTED {
			let _ = send(msg)
		}
		msgField.stringValue = ""
	}
	
	@IBAction func disconnect(_ sender: Any) {
		if state == HOSTING {
			closeServer()
		} else if state == CONNECTED {
			closeClient()
		}
		state = DISCONNECTED
	}

	func handleMessage(_ msg: String, type: MessageType, src: String) {
		if state == HOSTING {
			DispatchQueue.main.async {
				self.transcript.string.append("\n\(src): \(msg)")
			}
			if src != "Error" && src != "Notice" {
				broadcast(msg, src: src)
			}
		} else {
			DispatchQueue.main.async {
				self.transcript.string.append("\n\(msg)")
			}
		}
	}

}
