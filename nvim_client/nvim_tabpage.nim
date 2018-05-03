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

proc list_wins*(self: NvimTabPage): seq[NvimWindow] =
  self.rpc.request("nvim_tabpage_list_wins", self).toSeqWindow(self.rpc)

proc get_var*(self: NvimTabPage, name: string): MsgAny =
  self.rpc.request("nvim_tabpage_get_var", self, name)

proc set_var*[T](self: NvimTabPage, name: string, value: T) =
  self.rpc.request("nvim_tabpage_set_var", self, name, value).toVoid

proc del_var*(self: NvimTabPage, name: string) =
  self.rpc.request("nvim_tabpage_del_var", self, name).toVoid

proc get_win*(self: NvimTabPage): NvimWindow =
  self.rpc.request("nvim_tabpage_get_win").toWindow(self.rpc)

proc get_number*(self: NvimTabPage): int =
  self.rpc.request("nvim_tabpage_get_number", self).toInt

proc is_valid*(self: NvimTabPage): bool =
  self.rpc.request("nvim_tabpage_is_valid", self).toBool
