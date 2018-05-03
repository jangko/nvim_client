# Cross Platform Neovim Client Library for Nim

### What is this?

* It is a Msgpack RPC API implementation
* You can use this library to write Neovim plugin in Nim
* You can use this library to embed Neovim in your application
* You can write Neovim GUI and communicate with Neovim using this library

### Features

* Supported OSes: Windows, Linux, MacOS
* Support batch mode a.k.a. call_atomic
* Communicate with Neovim using different channels:
  * stdio on windows/unix
  * named pipe on windows or unix domain socket on unix
  * tcp socket on windows/unix
* listen for Neovim ui events, sync request, async notify
* register plugin functions, commands, autocmds utilities

### Documentation

I already compiled a detailed technical documentation covering Neovim
plugin architecture, RPC transport layer, RPC API call, registering plugin host and functions,
from various sources, such as Neovim Go-Client, Racket-Client, Neovim rpc documentation, etc.

  * [Technical Reference](docs/explained.md) of this library internals, useful
    if you want to write your own client-library or hacking this library.
  * [Tutorial](docs/tutorial.md), for you who wants to write plugin, ui app, or embedding Neovim.

### How To Install

```text
nimble install nvim_client
```
