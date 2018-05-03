# Neovim Client Library
## A Nim Msgpack RPC API
---

### What is this?

* You can use this library to write Neovim plugin in Nim
* You can use this library to embed Neovim in your application
* You can write Neovim GUI and communicate with Neovim using this library

### Features

* Support batch mode a.k.a. call_atomic
* Communicate with Neovim using different channels:
  * stdio on windows/unix
  * named pipe on windows or unix domain socket on unix
  * tcp socket on windows/unix
* listen for Neovim ui events, sync request, async notify
* register plugin functions, commands, autocmd utilities

### Documentation

I already compiled a detailed technical documentation covering Neovim
plugin architecture, RPC transport layer, RPC API call, registering plugin host and functions,
from various sources, such as Neovim Go-Client, Racket-Client, Neovim rpc documentation, etc.
You can start writing your plugin or application by reading these materials:
  * [Technical Reference](docs/explained.md)
  * [Tutorial](docs/tutorial.md)

### How To Install

```text
nimble install nvim_client
```
