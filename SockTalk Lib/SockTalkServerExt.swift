//
//  SockTalkServerExt.swift
//  SockTalk
//
//  Created by Alessandro Vinciguerra on 29/07/2018.
//      <alesvinciguerra@gmail.com>
//Copyright (C) 2018 Arc676/Alessandro Vinciguerra

//This program is free software: you can redistribute it and/or modify
//it under the terms of the GNU General Public License as published by
//the Free Software Foundation (version 3) with the exception that linking
//the OpenSSL library is allowed

//This program is distributed in the hope that it will be useful,
//but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//GNU General Public License for more details.

//You should have received a copy of the GNU General Public License
//along with this program.  If not, see <http://www.gnu.org/licenses/>.
//See README and LICENSE for more details

//OpenSSL library available under OpenSSL and SSLeay license
/* ====================================================================
* Copyright (c) 1998-2017 The OpenSSL Project.  All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions
* are met:
*
* 1. Redistributions of source code must retain the above copyright
*    notice, this list of conditions and the following disclaimer.
*
* 2. Redistributions in binary form must reproduce the above copyright
*    notice, this list of conditions and the following disclaimer in
*    the documentation and/or other materials provided with the
*    distribution.
*
* 3. All advertising materials mentioning features or use of this
*    software must display the following acknowledgment:
*    "This product includes software developed by the OpenSSL Project
*    for use in the OpenSSL Toolkit. (http://www.openssl.org/)"
*
* 4. The names "OpenSSL Toolkit" and "OpenSSL Project" must not be used to
*    endorse or promote products derived from this software without
*    prior written permission. For written permission, please contact
*    openssl-core@openssl.org.
*
* 5. Products derived from this software may not be called "OpenSSL"
*    nor may "OpenSSL" appear in their names without prior written
*    permission of the OpenSSL Project.
*
* 6. Redistributions of any form whatsoever must retain the following
*    acknowledgment:
*    "This product includes software developed by the OpenSSL Project
*    for use in the OpenSSL Toolkit (http://www.openssl.org/)"
*
* THIS SOFTWARE IS PROVIDED BY THE OpenSSL PROJECT ``AS IS'' AND ANY
* EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
* IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
* PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE OpenSSL PROJECT OR
* ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
* SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
* NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
* HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
* STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
* ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
* OF THE POSSIBILITY OF SUCH DAMAGE.
* ====================================================================
*
* This product includes cryptographic software written by Eric Young
* (eay@cryptsoft.com).  This product includes software written by Tim
* Hudson (tjh@cryptsoft.com).
*
*/
/* Copyright (C) 1995-1998 Eric Young (eay@cryptsoft.com)
* All rights reserved.
*
* This package is an SSL implementation written
* by Eric Young (eay@cryptsoft.com).
* The implementation was written so as to conform with Netscapes SSL.
*
* This library is free for commercial and non-commercial use as long as
* the following conditions are aheared to.  The following conditions
* apply to all code found in this distribution, be it the RC4, RSA,
* lhash, DES, etc., code; not just the SSL code.  The SSL documentation
* included with this distribution is covered by the same copyright terms
* except that the holder is Tim Hudson (tjh@cryptsoft.com).
*
* Copyright remains Eric Young's, and as such any Copyright notices in
* the code are not to be removed.
* If this package is used in a product, Eric Young should be given attribution
* as the author of the parts of the library used.
* This can be in the form of a textual message at program startup or
* in documentation (online or textual) provided with the package.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions
* are met:
* 1. Redistributions of source code must retain the copyright
*    notice, this list of conditions and the following disclaimer.
* 2. Redistributions in binary form must reproduce the above copyright
*    notice, this list of conditions and the following disclaimer in the
*    documentation and/or other materials provided with the distribution.
* 3. All advertising materials mentioning features or use of this software
*    must display the following acknowledgement:
*    "This product includes cryptographic software written by
*     Eric Young (eay@cryptsoft.com)"
*    The word 'cryptographic' can be left out if the rouines from the library
*    being used are not cryptographic related :-).
* 4. If you include any Windows specific code (or a derivative thereof) from
*    the apps directory (application code) you must include an acknowledgement:
*    "This product includes software written by Tim Hudson (tjh@cryptsoft.com)"
*
* THIS SOFTWARE IS PROVIDED BY ERIC YOUNG ``AS IS'' AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
* IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
* ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
* FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
* DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
* OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
* HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
* LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
* OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
* SUCH DAMAGE.
*
* The licence and distribution terms for any publically available version or
* derivative of this code cannot be changed.  i.e. this code cannot simply be
* copied and put under another distribution licence
* [including the GNU Public Licence.]
*/

import Foundation

public extension SockTalkServer {

	public func initialize(port: Int, cert: URL?, key: URL?) {
		if cert == nil || key == nil {
			ssl = nil
			status = .SUCCESS
		} else {
			ssl = SSLWrapper()
			status = ErrorCode(rawValue: Int((ssl!.initializeSSL(cert!.path, key: key!.path, isServer: true))))!
		}
		if status != .SUCCESS {
			return
		}
		serverSock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP)
		if serverSock! < 0 {
			status = .CREATE_SOCKET_FAILED
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
			status = .BIND_SOCKET_FAILED
			return
		}
		servinfo?.deallocate()

		var opt = 1
		setsockopt(serverSock!, SOL_SOCKET, SO_REUSEADDR, &opt, socklen_t(Int.bitWidth / UInt8.bitWidth))

		if listen(serverSock!, 5) < 0 {
			status = .LISTEN_SOCKET_FAILED
			return
		}

		acceptThread = AcceptThread(server: self, sock: serverSock!, ssl: ssl)
		handlers = [SockTalkClientHandler]()
		handleMessage("Hosting on port \(serverPort!)", type: .INFO, src: "Info")
	}

	public func addHandler(_ handler: SockTalkClientHandler) {
		handlers!.append(handler)
		handleMessage("Incoming connection...", type: .INFO, src: "Notice")
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

	public func isReservedName(_ username: String) -> Bool {
		return ["Server", "Info", "Error", "Notice", "TERM"].contains(username)
	}

	public func registerName(_ username: String, IP: String) -> Bool {
		checkHandlers()
		if isReservedName(username) {
			return false
		}
		for banned in banlist {
			if banned[1] == IP {
				return false
			}
		}
		for handler in handlers! {
			if handler.getUsername() == username {
				return false
			}
		}
		return true
	}

	public func broadcast(_ msg: String, src: String) {
		checkHandlers()
		for handler in handlers! {
			if handler.getUsername() != src {
				handler.send("\(src): \(msg)")
			}
		}
	}

	public func sendTo(_ msg: String, recipient: String) -> SockTalkClientHandler? {
		for handler in handlers! {
			if handler.getUsername() == recipient {
				handler.send(msg)
				return handler
			}
		}
		return nil
	}

	public func closeServer() {
		close(serverSock!)
		acceptThread!.running = false
		for handler in handlers! {
			handler.stop()
		}
		handlers!.removeAll()
		handleMessage("Server closed", type: .INFO, src: "Info")
	}

	public func kickUser(_ username: String, reason: String = "Kicked by server") -> SockTalkClientHandler? {
		let ch = sendTo("TERM: \(reason)", recipient: username)
		ch?.stop()
		return ch
	}

	public func banUser(_ username: String) {
		let ch = kickUser(username, reason: "Banned by server")
		banlist.append([username, ch!.ip])
	}

	public func unbanUser(username: String?, addr: String?) {
		var idx = 0
		for banned in banlist {
			if banned[0] == username || banned[1] == addr {
				break
			}
			idx += 1
		}
		banlist.remove(at: idx)
	}

}
