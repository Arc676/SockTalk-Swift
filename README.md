# SockTalk (Swift library and Cocoa frontend)

The [SockTalk library](https://github.com/Arc676/SockTalk) is a C++ library for network communication over sockets. Swift, not being a C-family language, cannot be linked to C libraries the way Objective-C can. This project's aim is to create a Cocoa framework written in Swift that conforms to the SockTalk protocol and thus allow the creation of Swift programs capable of communicating with C programs following SockTalk protocol.

The project also includes a second target which is just such a program.

## SockTalk protocol

See the repository of the C++ library for a more detailed description of the SockTalk protocol.

## Licensing

Project available under GPLv3. See `LICENSE` for full license text.
