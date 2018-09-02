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

class ViewController: NSViewController, SockTalkServer, SockTalkClient, NSTableViewDataSource {

	// MARK: - Application state

	let HOSTING			= 0b10
	let CONNECTED		= 0b01
	let DISCONNECTED	= 0b00
	var state = 0 // start disconnected
	var status: ErrorCode = .SUCCESS

	// MARK: - SSL
	@IBOutlet weak var enableSSL: NSButton!
	@IBOutlet weak var certPath: NSPathControl!
	@IBOutlet weak var keyPath: NSPathControl!
	var ssl: SSLWrapper?

	// MARK: - Server properties

	var serverSock: Int32?
	var serverPort: Int?
	var acceptThread: AcceptThread?
	var handlers: [SockTalkClientHandler]?
	var banlist: [[String]] = []

	// MARK: - Server UI

	@IBOutlet weak var servPortField: NSTextField!
	@IBOutlet weak var hostButton: NSButton!

	@IBOutlet weak var unbanField: NSTextField!
	@IBOutlet weak var userlist: NSTableView!
	
	@IBAction func startHosting(_ sender: Any) {
		username = "Server"
		let port = servPortField.integerValue
		var cert: URL? = nil
		var key: URL? = nil
		if enableSSL.state == NSControl.StateValue.on {
			cert = certPath.url
			key = keyPath.url
		}
		// initialize server
		initialize(port: port, cert: cert, key: key)
		if status == .SUCCESS {
			state = HOSTING
			toggleUIElements(false)
		} else {
			handleMessage(ErrorCodes.errToString(status), type: .ERROR, src: "Error")
		}
	}

	@IBAction func kickSelectedUser(_ sender: Any) {
		let row = userlist.selectedRow
		if row != -1 {
			let user = handlers![row].getUsername()
			let _ = kickUser(user)
		}
	}

	@IBAction func banSelectedUser(_ sender: Any) {
		let row = userlist.selectedRow
		if row != -1 {
			let user = handlers![row].getUsername()
			let _ = banUser(user)
		}
	}

	@IBAction func unbanGivenUser(_ sender: Any) {
		unbanUser(username: unbanField.stringValue, addr: nil)
		unbanField.stringValue = ""
	}

	func numberOfRows(in tableView: NSTableView) -> Int {
		return handlers?.count ?? 0
	}

	func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
		if row >= handlers!.count {
			return nil
		}
		if tableColumn?.title == "Username" {
			return handlers![row].getUsername()
		} else {
			return handlers![row].ip
		}
	}

	// MARK: - Client properties

	var username: String?
	var sock: Int32?
	var msgThread: MsgThread?

	// MARK: - Client UI

	@IBOutlet weak var clientIPField: NSTextField!
	@IBOutlet weak var clientPortField: NSTextField!
	@IBOutlet weak var clientUsernameField: NSTextField!
	@IBOutlet weak var joinButton: NSButton!
	
	@IBAction func joinChat(_ sender: Any) {
		let host = clientIPField.stringValue
		let port = clientPortField.integerValue
		let username = clientUsernameField.stringValue
		var cert: URL? = nil
		var key: URL? = nil
		if enableSSL.state == NSControl.StateValue.on {
			cert = certPath.url
			key = keyPath.url
		}
		// initialize client
		initialize(port: port, host: host, username: username, cert: cert, key: key)
		if status == .SUCCESS {
			state = CONNECTED
			toggleUIElements(true)
		} else {
			handleMessage(ErrorCodes.errToString(status), type: .ERROR, src: "Error")
		}
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
		updateTranscript("\n\(username!): \(msg)")
		if state == HOSTING {
			broadcast(msg, src: "Server")
		} else if state == CONNECTED {
			let _ = send(msg)
		}
		msgField.stringValue = ""
	}
	
	@IBAction func disconnect(_ sender: Any?) {
		if state == HOSTING {
			closeServer()
		} else if state == CONNECTED {
			closeClient()
		}
		state = DISCONNECTED
		toggleUIElements(true)
	}

	func handleMessage(_ msg: String, type: MessageType, src: String) {
		if state == HOSTING {
			updateTranscript("\n\(src): \(msg)")
			if src != "Error" && src != "Notice" {
				broadcast(msg, src: src)
			}
			if msg.hasSuffix("connected") {
				DispatchQueue.main.async {
					self.userlist.reloadData()
				}
			}
		} else {
			updateTranscript("\n\(msg)")
			if msg.starts(with: "TERM: ") {
				DispatchQueue.main.async {
					self.disconnect(nil)
				}
			}
		}
	}

	func updateTranscript(_ msg: String) {
		DispatchQueue.main.async {
			self.transcript.string.append(msg)
			self.transcript.scrollRangeToVisible(
				NSMakeRange(
					self.transcript.string.count - 1, 1))
		}
	}

	func toggleUIElements(_ state: Bool) {
		servPortField.isEnabled = state
		clientIPField.isEnabled = state
		clientPortField.isEnabled = state
		clientUsernameField.isEnabled = state
		hostButton.isEnabled = state
		joinButton.isEnabled = state
	}

}
