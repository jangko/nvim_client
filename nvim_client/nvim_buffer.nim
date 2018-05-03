# Neovim Client Library -- MsgPack RPC API
#
# Copyright (c) 2018 Andri Lim
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#-------------------------------------

import nvim_rpc, msgpack4nim, msgpack2any

proc line_count*(self: NvimBuffer): int =
  self.rpc.request("nvim_buf_line_count", self).toInt

proc get_lines*(self: NvimBuffer, start, stop: int, strictIndexing: bool): seq[string] =
  self.rpc.request("nvim_buf_get_lines", self, start, stop, strictIndexing).toSeqString

proc set_lines*(self: NvimBuffer, start, stop: int, strict_indexing: bool, replacement: openArray[string]) =
  self.rpc.request("nvim_buf_set_lines", self, start, stop, strict_indexing, replacement).toVoid

proc get_var*(self: NvimBuffer, name: string): MsgAny =
  self.rpc.request("nvim_buf_get_var", self, name)

proc set_var*[T](self: NvimBuffer, name: string, value: T) =
  self.rpc.request("nvim_buf_set_var", self, name, value).toVoid

proc del_var*(self: NvimBuffer, name: string) =
  self.rpc.request("nvim_buf_del_var", self, name).toVoid

proc get_option*(self: NvimBuffer, name: string): MsgAny =
  self.rpc.request("nvim_buf_get_option", self, name)

proc set_option*[T](self: NvimBuffer, name: string, value: T) =
  self.rpc.request("nvim_buf_set_option", self, name, value).toVoid

proc get_changedtick*(self: NvimBuffer): int =
  self.rpc.request("nvim_buf_get_changedtick", self).toInt

proc get_keymap*(self: NvimBuffer, mode: string): MsgAny =
  self.rpc.request("nvim_buf_get_keymap", self, mode)

proc get_name*(self: NvimBuffer): string =
  self.rpc.request("nvim_buf_get_name", self).toString

proc set_name*(self: NvimBuffer, name: string) =
  self.rpc.request("nvim_buf_set_name", self, name).toVoid

proc is_valid*(self: NvimBuffer): bool =
  self.rpc.request("nvim_buf_is_valid", self).toBool

proc get_mark*(self: NvimBuffer, name: string): tuple[x, y: int] =
  self.rpc.request("nvim_buf_get_mark", self, name).toPos

proc add_highlight*(self: NvimBuffer, srcId: int, hlGroup: string, line, colStart, colEnd: int): int =
  self.rpc.request("nvim_buf_add_highlight", self, srcId, hlGroup, line, colStart, colEnd).toInt

proc clear_highlight*(self: NvimBuffer, srcId: int, lineStart, lineEnd: int) =
  self.rpc.request("nvim_buf_clear_highlight", self, srcId, lineStart, lineEnd).toVoid
