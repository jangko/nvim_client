import nvim_rpc, msgpack4nim, msgpack2any

proc initNvimBatch*(): NvimBatch =
  result.calls = @[]

proc list_wins*(self: var NvimBatch, tab: NvimTabPage) =
  self.store("nvim_tabpage_list_wins", brkSeqWindow, tab)

proc get_var*(self: var NvimBatch, tab: NvimTabPage, name: string) =
  self.store("nvim_tabpage_get_var", brkObject, tab, name)

proc set_var*[T](self: var NvimBatch, tab: NvimTabPage, name: string, value: T) =
  self.store("nvim_tabpage_set_var", brkVoid, tab, name, value)

proc del_var*(self: var NvimBatch, tab: NvimTabPage, name: string) =
  self.store("nvim_tabpage_del_var", brkVoid, tab, name)

proc get_win*(self: var NvimBatch, tab: NvimTabPage) =
  self.store("nvim_tabpage_get_win", brkWindow)

proc get_number*(self: var NvimBatch, tab: NvimTabPage) =
  self.store("nvim_tabpage_get_number", brkInt, tab)

proc is_valid*(self: var NvimBatch, tab: NvimTabPage) =
  self.store("nvim_tabpage_is_valid", brkBool, tab)

#---------------------------------------------------------

proc line_count*(self: var NvimBatch, buf: NvimBuffer) =
  self.store("nvim_buf_line_count", brkInt, buf)

proc get_lines*(self: var NvimBatch, buf: NvimBuffer, start, stop: int, strictIndexing: bool) =
  self.store("nvim_buf_get_lines", brkSeqString, buf, start, stop, strictIndexing)

proc set_lines*(self: var NvimBatch, buf: NvimBuffer, start, stop: int, strict_indexing: bool, replacement: openArray[string]) =
  self.store("nvim_buf_set_lines", brkVoid, buf, start, stop, strict_indexing, replacement)

proc get_var*(self: var NvimBatch, buf: NvimBuffer, name: string) =
  self.store("nvim_buf_get_var", brkObject, buf, name)

proc set_var*[T](self: var NvimBatch, buf: NvimBuffer, name: string, value: T) =
  self.store("nvim_buf_set_var", brkVoid, buf, name, value)

proc del_var*(self: var NvimBatch, buf: NvimBuffer, name: string) =
  self.store("nvim_buf_del_var", brkVoid, buf, name)

proc get_option*(self: var NvimBatch, buf: NvimBuffer, name: string) =
  self.store("nvim_buf_get_option", brkObject, buf, name)

proc set_option*[T](self: var NvimBatch, buf: NvimBuffer, name: string, value: T) =
  self.store("nvim_buf_set_option", brkVoid, buf, name, value)

proc get_changedtick*(self: var NvimBatch, buf: NvimBuffer) =
  self.store("nvim_buf_get_changedtick", brkInt, buf)

proc get_keymap*(self: var NvimBatch, buf: NvimBuffer, mode: string) =
  self.store("nvim_buf_get_keymap", brkObject, buf, mode)

proc get_name*(self: var NvimBatch, buf: NvimBuffer): string =
  self.store("nvim_buf_get_name", brkString, buf)

proc set_name*(self: var NvimBatch, buf: NvimBuffer, name: string) =
  self.store("nvim_buf_set_name", brkVoid, buf, name)

proc is_valid*(self: var NvimBatch, buf: NvimBuffer) =
  self.store("nvim_buf_is_valid", brkBool, buf)

proc get_mark*(self: var NvimBatch, buf: NvimBuffer, name: string) =
  self.store("nvim_buf_get_mark", brkPos, buf, name)

proc add_highlight*(self: var NvimBatch, buf: NvimBuffer, srcId: int, hlGroup: string, line, colStart, colEnd: int) =
  self.store("nvim_buf_add_highlight", brkInt, buf, srcId, hlGroup, line, colStart, colEnd)

proc clear_highlight*(self: var NvimBatch, buf: NvimBuffer, srcId: int, lineStart, lineEnd: int) =
  self.store("nvim_buf_clear_highlight", brkVoid, buf, srcId, lineStart, lineEnd)

#---------------------------------------------------------

proc get_buf*(self: var NvimBatch, win: NvimWindow) =
  self.store("nvim_win_get_buf", brkBuffer, win)

proc get_cursor*(self: var NvimBatch, win: NvimWindow) =
  self.store("nvim_win_get_cursor", brkPos, win)

proc set_cursor*(self: var NvimBatch, win: NvimWindow, x, y: int) =
  self.store("nvim_win_set_cursor", brkVoid, win, [x, y])

proc get_height*(self: var NvimBatch, win: NvimWindow) =
  self.store("nvim_win_get_height", brkInt, win)

proc set_height*(self: var NvimBatch, win: NvimWindow, height: int) =
  self.store("nvim_win_set_height", brkVoid, win, height)

proc get_width*(self: var NvimBatch, win: NvimWindow) =
  self.store("nvim_win_get_width", brkInt, win)

proc set_width*(self: var NvimBatch, win: NvimWindow, width: int) =
  self.store("nvim_win_set_width", brkVoid, win, width)

proc get_var*(self: var NvimBatch, win: NvimWindow, name: string) =
  self.store("nvim_win_get_var", brkObject, win, name)

proc set_var*[T](self: var NvimBatch, win: NvimWindow, name: string, value: T) =
  self.store("nvim_win_set_var", brkVoid, win, name, value)

proc del_var*(self: var NvimBatch, win: NvimWindow, name: string) =
  self.store("nvim_win_del_var", brkVoid, win, name)

proc get_option*(self: var NvimBatch, win: NvimWindow, name: string) =
  self.store("nvim_win_get_option", brkObject, win, name)

proc set_option*[T](self: var NvimBatch, win: NvimWindow, name: string, value: T) =
  self.store("nvim_win_set_option", brkVoid, win, name, value)

proc get_tabpage*(self: var NvimBatch, win: NvimWindow) =
  self.store("nvim_get_tabpage", brkTabPage, win)

proc get_number*(self: var NvimBatch, win: NvimWindow) =
  self.store("nvim_win_get_number", brkInt, win)

proc get_position*(self: var NvimBatch, win: NvimWindow) =
  self.store("nvim_win_get_position", brkPos, win)

proc is_valid*(self: var NvimBatch, win: NvimWindow) =
  self.store("nvim_win_is_valid", brkBool, win)

#---------------------------------------------------------

proc ui_attach*(self: var NvimBatch, width, height: int, options: MsgAny) =
  assert options.kind == msgMap
  self.store("nvim_ui_attach", brkVoid, width, height, options)

proc ui_try_resize*(self: var NvimBatch, width, height: int) =
  self.store("nvim_ui_try_resize", brkVoid, width, height)

proc ui_detach*(self: var NvimBatch) =
  self.store("nvim_ui_detach", brkVoid)

proc ui_set_option*[T](self: var NvimBatch, name: string, value: T) =
  self.store("nvim_ui_set_option", brkVoid, name, value)

proc get_current_buf*(self: var NvimBatch) =
  self.store("nvim_get_current_buf", brkBuffer)

proc get_current_win*(self: var NvimBatch) =
  self.store("nvim_get_current_win", brkWindow)

proc get_current_tabpage*(self: var NvimBatch) =
  self.store("nvim_get_current_tabpage", brkTabPage)

proc command*(self: var NvimBatch, cmd: string) =
  self.store("nvim_command", brkVoid, cmd)

proc command_output*(self: var NvimBatch, cmd: string) =
  self.store("nvim_command_output", brkString, cmd)

proc strwidth*(self: var NvimBatch, text: string) =
  self.store("nvim_strwidth", brkInt, text)

proc list_runtime_paths*(self: var NvimBatch) =
  self.store("nvim_list_runtime_paths", brkSeqString)

proc set_current_dir*(self: var NvimBatch, dir: string) =
  self.store("nvim_set_current_dir", brkVoid, dir)

proc set_current_line*(self: var NvimBatch, line: string) =
  self.store("nvim_set_current_line", brkVoid, line)

proc del_current_line*(self: var NvimBatch) =
  self.store("nvim_del_current_line", brkVoid)

proc get_current_line*(self: var NvimBatch) =
  self.store("nvim_get_current_line", brkString)

proc get_var*(self: var NvimBatch, name: string) =
  self.store("nvim_get_var", brkObject, name)

proc get_vvar*(self: var NvimBatch, name: string) =
  self.store("nvim_get_vvar", brkObject, name)

proc set_var*[T](self: var NvimBatch, name: string, value: T) =
  self.store("nvim_set_var", brkVoid, name, value)

proc del_var*(self: var NvimBatch, name: string) =
  self.store("nvim_del_var", brkVoid, name)

proc get_option*(self: var NvimBatch, name: string) =
  self.store("nvim_get_option", brkObject, name)

proc set_option*[T](self: var NvimBatch, name: string, value: T) =
  self.store("nvim_set_option", brkVoid, name, value)

proc out_write*(self: var NvimBatch, str: string) =
  self.store("nvim_out_write", brkVoid, str)

proc err_write*(self: var NvimBatch, str: string) =
  self.store("nvim_err_write", brkVoid, str)

proc err_writeln*(self: var NvimBatch, str: string) =
  self.store("nvim_err_writeln", brkVoid, str)

proc subscribe*(self: var NvimBatch, event: string) =
  self.store("nvim_subscribe", brkVoid, event)

proc unsubscribe*(self: var NvimBatch, event: string) =
  self.store("nvim_unsubscribe", brkVoid, event)

proc get_color_by_name*(self: var NvimBatch, name: string) =
  self.store("nvim_get_color_by_name", brkInt, name)

proc list_bufs*(self: var NvimBatch) =
  self.store("nvim_list_bufs", brkSeqBuffer)

proc list_wins*(self: var NvimBatch) =
  self.store("nvim_list_wins", brkSeqWindow)

proc list_tabpages*(self: var NvimBatch) =
  self.store("nvim_list_tabpages", brkSeqTabPage)

proc set_current_buf*(self: var NvimBatch, buffer: NvimBuffer) =
  self.store("nvim_set_current_buf", brkVoid, buffer)

proc set_current_win*(self: var NvimBatch, window: NvimWindow) =
  self.store("nvim_set_current_win", brkVoid, window)

proc set_current_tabpage*(self: var NvimBatch, tabpage: NvimTabPage) =
  self.store("nvim_set_current_tabpage", brkVoid, tabpage)

proc input*(self: var NvimBatch, keys: string) =
  self.store("nvim_input", brkInt, keys)

proc feedkeys*(self: var NvimBatch, keys, mode: string, escape_csi: bool) =
  self.store("nvim_feedkeys", brkVoid, keys, mode, escape_csi)

proc replace_termcodes*(self: var NvimBatch, str: string, from_part, do_it, special: bool) =
  self.store("nvim_replace_termcodes", brkString, str, from_part, do_it, special)

proc execute_lua*(self: var NvimBatch, code: string, args: varargs[string, pack]) =
  self.store("nvim_execute_lua", brkObject, code, args)

proc call_function*(self: var NvimBatch, fname: string, args: varargs[string, pack]) =
  self.store("nvim_call_function", brkObject, fname, args)

proc eval*(self: var NvimBatch, expression: string) =
  self.store("nvim_eval", brkObject, expression)

proc get_hl_by_name*(self: var NvimBatch, name: string, rgb: bool) =
  self.store("nvim_get_hl_by_name", brkObject, name, rgb)

proc get_hl_by_id*(self: var NvimBatch, hl_id: int, rgb: bool) =
  self.store("nvim_get_hl_by_id", brkObject, hl_id, rgb)

proc get_color_map*(self: var NvimBatch) =
  self.store("nvim_get_color_map", brkObject)

proc get_mode*(self: var NvimBatch) =
  self.store("nvim_get_mode", brkObject)

proc get_proc_children*(self: var NvimBatch, pid: int) =
  self.store("nvim_get_proc_children", brkObject, pid)

proc get_proc*(self: var NvimBatch, pid: int) =
  self.store("nvim_get_proc", brkObject, pid)

proc get_api_info*(self: var NvimBatch) =
  self.store("nvim_get_api_info", brkObject)

proc get_keymap*(self: var NvimBatch, mode: string) =
  self.store("nvim_get_keymap", brkObject, mode)

proc list_uis*(self: var NvimBatch) =
  self.store("nvim_list_uis", brkObject)

proc parse_expression*(self: var NvimBatch, expression, flags: string, highlight: bool) =
  self.store("nvim_parse_expression", brkObject, expression, flags, highlight)
