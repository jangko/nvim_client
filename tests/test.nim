import unittest, nvim, ospaths, os

proc main() =
  try:
    var nvim = nvimClientConnectStdio("nvim.exe --embed")
    #var nvim = nvimClientConnectPipe("\\\\.\\pipe\\nvim-7072-0")
    test "connection":
      check nvim.is_valid()

    test "tabpage":
      var tab = nvim.get_current_tabpage()
      check tab.is_valid()
      check tab.get_number() == 1
      var win = tab.get_win()
      check win.is_valid()
      tab.set_var("var_from_nim", 13)
      check tab.get_var("var_from_nim").toInt() == 13
      tab.del_var("var_from_nim")
      var x = tab.get_var("var_from_nim")
      check tab.has_error()
      check x.kind == msgNull
      var wins = tab.list_wins()
      check wins.len == 1
      check wins[0].is_valid()

    test "buffer":
      var buf = nvim.get_current_buf()
      check buf.is_valid()
      check buf.line_count() == 1
      let lines = ["hello", "from", "nim", "client"]
      buf.set_lines(1, lines.len + 1, false, lines)
      var z = buf.get_lines(1, lines.len + 1, true)
      check buf.line_count() == 5
      for i in 0..<lines.len:
        check z[i] == lines[i]

      buf.set_var("var_from_nim", 13)
      check buf.get_var("var_from_nim").toInt() == 13
      buf.del_var("var_from_nim")
      var x = buf.get_var("var_from_nim")
      check buf.has_error()
      check x.kind == msgNull

      buf.set_option("tabstop", 2)
      check buf.get_option("tabstop").toInt() == 2
      check buf.get_changedtick() == 3 # set_line, set_var, set_option

      var keymap = buf.get_keymap("n")
      check keymap.kind == msgArray

      buf.set_name("melancholia.txt")
      check buf.get_name().extractFilename() == "melancholia.txt"

      check buf.get_mark("a") == (0,0)

      let src = buf.add_highlight(0, "ErrorMsg", 2, 0, 3)
      buf.clear_highlight(src, 0, -1)

    test "window":
      var win = nvim.get_current_win()
      check win.is_valid()
      check win.get_position() == (0,0)
      check win.get_number() == 1
      var wtab = win.get_tabpage()
      var tab = nvim.get_current_tabpage()
      check wtab == tab

      var wbuf = win.get_buf()
      var buf = nvim.get_current_buf()
      check wbuf == buf

      win.set_var("var_from_nim", 13)
      check win.get_var("var_from_nim").toInt() == 13
      win.del_var("var_from_nim")
      var x = win.get_var("var_from_nim")
      check win.has_error()
      check x.kind == msgNull
      win.set_option("scroll", 13)
      check win.get_option("scroll").toInt() == 13

      nvim.command(":sp") #split window horizontally
      win = nvim.get_current_win()
      let h = win.get_height()
      win.set_height(h + 1)
      check win.get_height() == (h + 1)

      nvim.command(":vsp") #split window vertically
      win = nvim.get_current_win()
      let w = win.get_width()
      win.set_width(w + 1)
      check win.get_width() == (w + 1)

      win.set_cursor(3, 3)
      check win.get_cursor() == (3,3)

    test "client":
      var opts = anyMap()
      opts["rgb"] = anyBool(true)

      nvim.ui_attach(40, 20, opts)
      #echo nvim.last_error()

#nvim.ui_try_resize(width, height: int)
#nvim.ui_detach()
#nvim.ui_set_option(name: string, value: T)
      debug = true
      check nvim.get_current_win().is_valid()
      check nvim.get_current_buf().is_valid()
      debug = false

      check nvim.get_current_tabpage().is_valid()

      nvim.command(":let apple='hello apple'")
      check nvim.has_error() == false
      check nvim.get_var("apple").toString() == "hello apple"
      check nvim.command_output(":echo apple") == "hello apple"
      check nvim.strwidth("hello apple") == 11
      var paths = nvim.list_runtime_paths()
      check paths.len > 0

      nvim.set_current_dir(getAppDir())
      check nvim.has_error() == false

      nvim.set_current_line("hello from nim")

      debug = true
      check nvim.get_current_line() == "hello from nim"
      
      debug = false
      nvim.del_current_line()
      check nvim.has_error() == false

      nvim.set_var("apple", 17)
      check nvim.get_var("apple").toInt() == 17

      nvim.del_var("apple")
      check nvim.has_error() == false

      let fileName = nvim.get_vvar("progname").toString()
      check fileName.splitFile().name == "nvim"

      nvim.set_option("tabstop", 2)
      check nvim.get_option("tabstop").toInt() == 2

      nvim.out_write("123")
      check nvim.has_error() == false
      nvim.err_write("123")
      check nvim.has_error() == false
      nvim.err_writeln("123")
      check nvim.has_error() == false

      nvim.subscribe("test")
      check nvim.has_error() == false

      nvim.unsubscribe("test")
      check nvim.has_error() == false

      check nvim.get_color_by_name("ErrorMsg") != 0
      var lbuf = nvim.list_bufs()
      var lwin = nvim.list_wins()
      var ltab = nvim.list_tabpages()
      check lbuf.len == 1
      check lwin.len == 3 # we split window from prev test
      check ltab.len == 1

      nvim.set_current_buf(lbuf[0])
      check nvim.has_error() == false
      nvim.set_current_win(lwin[0])
      check nvim.has_error() == false
      nvim.set_current_tabpage(ltab[0])
      check nvim.has_error() == false

      check nvim.input("a<ESC>") == 6
      check nvim.has_error() == false

      nvim.feedkeys("i<ESC>", "m", false)
      check nvim.has_error() == false
      #echo nvim.get_vvar("errmsg").toString()

      var res = nvim.execute_lua("vim.api.nvim_set_var(\"megaloman\", \"megaloman\")")
      check res.kind == msgNull
      check nvim.get_var("megaloman").toString() == "megaloman"

      check nvim.call_function("cursor", 3, 4).toInt() == 0

      var win = nvim.get_current_win()
      check win.get_cursor() == (3, 3)

      check nvim.eval("10+10").toInt() == 20

      var hl = nvim.get_hl_by_name("ErrorMsg", true)
      check hl.kind == msgMap
      check hl["foreground"].toInt() > 0

      var hlm = nvim.get_hl_by_id(2, true)
      check hlm.kind == msgMap

      var cm = nvim.get_color_map()
      check cm.kind == msgMap

      check nvim.input("<ESC>") == 5 # return to normal mode
      var mode = nvim.get_mode()
      check mode.kind == msgMap
      check mode["mode"].toString() == "n"

      #proc get_proc_children*(self: NvimClient, pid: int): MsgAny =
      #proc get_proc*(self: NvimClient, pid: int): MsgAny =

      var api = nvim.get_api_info()
      check api.kind == msgArray

      var keys = nvim.get_keymap("n")
      check keys.kind == msgArray

      var uis = nvim.list_uis()
      check uis.kind == msgArray

      var ast = nvim.parse_expression("10+10", "m", false)
      check ast.kind == msgMap

    test "atomic":
      var b = initNvimBatch()
      b.get_current_buf()
      b.get_current_win()
      b.get_current_tabpage()
      b.get_current_line()

      var zz = nvim.call_atomic(b)
      var xbuf = zz[0].bufVal
      var xwin = zz[1].winVal
      var xtab = zz[2].tabVal
      var xstr = zz[3].strVal

      check xwin.is_valid()
      check xtab.is_valid()
      check xbuf.is_valid()
      check xstr == "ni<ESC>m"

    nvim.close()
  except:
    echo getCurrentExceptionMsg()

main()
