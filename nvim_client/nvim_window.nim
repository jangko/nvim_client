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

proc get_buf*(self: NvimWindow): NvimBuffer =
  self.rpc.request("nvim_win_get_buf", self).toBuffer(self.rpc)

proc get_cursor*(self: NvimWindow): tuple[x, y: int] =
  self.rpc.request("nvim_win_get_cursor", self).toPos

proc set_cursor*(self: NvimWindow, x, y: int) =
  self.rpc.request("nvim_win_set_cursor", self, [x, y]).toVoid

proc get_height*(self: NvimWindow): int =
  self.rpc.request("nvim_win_get_height", self).toInt

proc set_height*(self: NvimWindow, height: int): int =
  self.rpc.request("nvim_win_set_height", self, height).toVoid

proc get_width*(self: NvimWindow): int =
  self.rpc.request("nvim_win_get_width", self).toInt

proc set_width*(self: NvimWindow, width: int) =
  self.rpc.request("nvim_win_set_width", self, width).toVoid

proc get_var*(self: NvimWindow, name: string): MsgAny =
  self.rpc.request("nvim_win_get_var", self, name)

proc set_var*[T](self: NvimWindow, name: string, value: T) =
  self.rpc.request("nvim_win_set_var", self, name, value).toVoid

proc del_var*(self: NvimWindow, name: string) =
  self.rpc.request("nvim_win_del_var", self, name).toVoid

proc get_option*(self: NvimWindow, name: string): MsgAny =
  self.rpc.request("nvim_win_get_option", self, name)

proc set_option*[T](self: NvimWindow, name: string, value: T) =
  self.rpc.request("nvim_win_set_option", self, name, value).toVoid

proc get_tabpage*(self: NvimWindow): NvimTabPage =
  self.rpc.request("nvim_get_tabpage", self).toTabPage(self.rpc)

proc get_number*(self: NvimWindow): int =
  self.rpc.request("nvim_win_get_number", self).toInt

proc get_position*(self: NvimWindow): tuple[x, y: int] =
  self.rpc.request("nvim_win_get_position", self).toPos

proc is_valid*(self: NvimWindow): bool =
  self.rpc.request("nvim_win_is_valid", self).toBool
