# SockTalk (Swift library and Cocoa frontend)

The [SockTalk library](https://github.com/Arc676/SockTalk) is a C++ library for network communication over sockets. Swift, not being a C-family language, cannot be linked to C++ libraries as easily as Objective-C can. This project's aim is to create a Cocoa framework written in Swift that conforms to the SockTalk protocol and thus allow the creation of Swift programs capable of communicating with C/C++ programs following SockTalk protocol. The framework also takes a slightly different approach, as C++ has multiple inheritance and Swift does not. 

The project also includes a second target which is a frontend to the library.

## Compiling

Compiling SockTalk requires that the OpenSSL be installed and that the static libraries (`.a`) are located in the OpenSSL directory in the project root. The OpenSSL libraries and header files are not included in this repository.

## SockTalk protocol

See the repository of the C++ library for a more detailed description of the SockTalk protocol.

## Licensing

Project available under GPLv3 with the exception that linking proprietary Apple libraries as well as the OpenSSL library is allowed. See `LICENSE` for full GPL text. See `opensslLicense.txt` for the full OpenSSL license.

This product includes software developed by the OpenSSL Project for use in the OpenSSL Toolkit (http://www.openssl.org/)
