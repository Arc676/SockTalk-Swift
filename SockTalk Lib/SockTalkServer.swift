//
//  SockTalkServer.swift
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

public protocol SockTalkServer : MessageHandler {

	var serverSock: Int32? { get set }
	var serverPort: Int? { get set }

	var acceptThread: AcceptThread? { get set }

	var handlers: [SockTalkClientHandler]? { get set }

	/**
	Initialize server

	- parameters:
		- port: Port on which to host chat
	*/
	func initialize(port: Int)

	/**
	Adds a new client handler

	- parameters:
		- handler: New client handler
	*/
	func addHandler(_ handler: SockTalkClientHandler)

	/**
	Checks handlers for any dead connections and drops any corresponding
	to clients that have disconnected
	*/
	func checkHandlers()

	/**
	Shuts down the server
	*/
	func closeServer()

	/**
	Determines whether a username is invalid

	- parameters:
		- username: Username to check

	- returns:
	Whether the username is reserved or taken by another client
	*/
	func usernameTaken(_ username: String) -> Bool

	/**
	Broadcasts a message to all connected clients

	- parameters:
		- msg: Message to send
		- src: Original sender of message
	*/
	func broadcast(_ msg: String, src: String)

	/**
	Send a message to a single client

	- parameters:
		- msg: Message to send
		- recipient: Username of client to which to send the message
	*/
	func sendTo(_ msg: String, recipient: String)
	
}
