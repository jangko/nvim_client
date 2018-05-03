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
export nvim_rpc, msgpack4nim, msgpack2any

proc nvimClientConnectPipe*(address: string, timeOut = 5000): NvimClient =
  result.rpc = rpc_connect_pipe(address, timeOut)
  
proc nvimClientConnectStdio*(address: string, timeOut = 5000): NvimClient =
  result.rpc = rpc_connect_stdio(address, timeOut)

proc close*(self: NvimClient) =
  self.rpc.close()

proc listen*(self: NvimClient) =
  self.rpc.listen()

proc ui_attach*(self: NvimClient, width, height: int, options: MsgAny) =
  assert options.kind == msgMap
  self.rpc.request("nvim_ui_attach", width, height, options).toVoid

proc ui_try_resize*(self: NvimClient, width, height: int) =
  self.rpc.request("nvim_ui_try_resize", width, height).toVoid

proc ui_detach*(self: NvimClient) =
  self.rpc.request("nvim_ui_detach").toVoid

proc ui_set_option*[T](self: NvimClient, name: string, value: T) =
  self.rpc.request("nvim_ui_set_option", name, value).toVoid

proc get_current_buf*(self: NvimClient): NvimBuffer =
  self.rpc.request("nvim_get_current_buf").toBuffer(self.rpc)

proc get_current_win*(self: NvimClient): NvimWindow =
  self.rpc.request("nvim_get_current_win").toWindow(self.rpc)

proc get_current_tabpage*(self: NvimClient): NvimTabPage =
  self.rpc.request("nvim_get_current_tabpage").toTabPage(self.rpc)

proc command*(self: NvimClient, cmd: string) =
  self.rpc.request("nvim_command", cmd).toVoid

proc command_output*(self: NvimClient, cmd: string): string =
  self.rpc.request("nvim_command_output", cmd).toString

proc strwidth*(self: NvimClient, text: string): int =
  self.rpc.request("nvim_strwidth", text).toInt

proc list_runtime_paths*(self: NvimClient): seq[string] =
  self.rpc.request("nvim_list_runtime_paths").toSeqString

proc set_current_dir*(self: NvimClient, dir: string) =
  self.rpc.request("nvim_set_current_dir", dir).toVoid

proc set_current_line*(self: NvimClient, line: string) =
  self.rpc.request("nvim_set_current_line", line).toVoid

proc del_current_line*(self: NvimClient) =
  self.rpc.request("nvim_del_current_line").toVoid

proc get_current_line*(self: NvimClient): string =
  self.rpc.request("nvim_get_current_line").toString

proc get_var*(self: NvimClient, name: string): MsgAny =
  self.rpc.request("nvim_get_var", name)

proc get_vvar*(self: NvimClient, name: string): MsgAny =
  self.rpc.request("nvim_get_vvar", name)

proc set_var*[T](self: NvimClient, name: string, value: T) =
  self.rpc.request("nvim_set_var", name, value).toVoid

proc del_var*(self: NvimClient, name: string) =
  self.rpc.request("nvim_del_var", name).toVoid

proc get_option*(self: NvimClient, name: string): MsgAny =
  self.rpc.request("nvim_get_option", name)

proc set_option*[T](self: NvimClient, name: string, value: T) =
  self.rpc.request("nvim_set_option", name, value).toVoid

proc out_write*(self: NvimClient, str: string) =
  self.rpc.request("nvim_out_write", str).toVoid

proc err_write*(self: NvimClient, str: string) =
  self.rpc.request("nvim_err_write", str).toVoid

proc err_writeln*(self: NvimClient, str: string) =
  self.rpc.request("nvim_err_writeln", str).toVoid

proc subscribe*(self: NvimClient, event: string) =
  self.rpc.request("nvim_subscribe", event).toVoid

proc unsubscribe*(self: NvimClient, event: string) =
  self.rpc.request("nvim_unsubscribe", event).toVoid

proc get_color_by_name*(self: NvimClient, name: string): int =
  self.rpc.request("nvim_get_color_by_name", name).toInt

proc list_bufs*(self: NvimClient): seq[NvimBuffer] =
  self.rpc.request("nvim_list_bufs").toSeqBuffer(self.rpc)

proc list_wins*(self: NvimClient): seq[NvimWindow] =
  self.rpc.request("nvim_list_wins").toSeqWindow(self.rpc)

proc list_tabpages*(self: NvimClient): seq[NvimTabPage] =
  self.rpc.request("nvim_list_tabpages").toSeqTabPage(self.rpc)

proc set_current_buf*(self: NvimClient, buffer: NvimBuffer) =
  self.rpc.request("nvim_set_current_buf", buffer).toVoid

proc set_current_win*(self: NvimClient, window: NvimWindow) =
  self.rpc.request("nvim_set_current_win", window).toVoid

proc set_current_tabpage*(self: NvimClient, tabpage: NvimTabPage) =
  self.rpc.request("nvim_set_current_tabpage", tabpage).toVoid

proc input*(self: NvimClient, keys: string): int =
  self.rpc.request("nvim_input", keys).toInt

proc feedkeys*(self: NvimClient, keys, mode: string, escape_csi: bool) =
  self.rpc.request("nvim_feedkeys", keys, mode, escape_csi).toVoid

proc replace_termcodes*(self: NvimClient, str: string, from_part, do_it, special: bool): string =
  self.rpc.request("nvim_replace_termcodes", str, from_part, do_it, special).toString

proc execute_lua*(self: NvimClient, code: string, args: varargs[string, pack]): MsgAny =
  self.rpc.request("nvim_execute_lua", code, args)

proc call_function*(self: NvimClient, fname: string, args: varargs[string, pack]): MsgAny =
  self.rpc.request("nvim_call_function", fname, args)

proc eval*(self: NvimClient, expression: string): MsgAny =
  self.rpc.request("nvim_eval", expression)

proc get_hl_by_name*(self: NvimClient, name: string, rgb: bool): MsgAny =
  self.rpc.request("nvim_get_hl_by_name", name, rgb)

proc get_hl_by_id*(self: NvimClient, hl_id: int, rgb: bool): MsgAny =
  self.rpc.request("nvim_get_hl_by_id", hl_id, rgb)

proc get_color_map*(self: NvimClient): MsgAny =
  self.rpc.request("nvim_get_color_map")

proc get_mode*(self: NvimClient): MsgAny =
  self.rpc.request("nvim_get_mode")

proc get_proc_children*(self: NvimClient, pid: int): MsgAny =
  self.rpc.request("nvim_get_proc_children", pid)

proc get_proc*(self: NvimClient, pid: int): MsgAny =
  self.rpc.request("nvim_get_proc", pid)

proc get_api_info*(self: NvimClient): MsgAny =
  self.rpc.request("nvim_get_api_info")

proc get_keymap*(self: NvimClient, mode: string): MsgAny =
  self.rpc.request("nvim_get_keymap", mode)

proc list_uis*(self: NvimClient): MsgAny =
  self.rpc.request("nvim_list_uis")

proc parse_expression*(self: NvimClient, expression, flags: string, highlight: bool): MsgAny =
  self.rpc.request("nvim_parse_expression", expression, flags, highlight)

proc call_atomic*(self: NvimClient, calls: NvimBatch): seq[BatchResult] =
  self.rpc.request("nvim_call_atomic", calls).toBatchResult(calls, self.rpc)
