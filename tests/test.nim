import unittest, nvim, ospaths

proc main() =
  try:
    var nvim = nvimClientConnectStdio("nvim.exe --embed")

    #test "connection":
    #  check nvim.is_valid()
    #
    #test "tabpage":
    #  var tab = nvim.get_current_tabpage()
    #  check tab.is_valid()
    #  check tab.get_number() == 1
    #  var win = tab.get_win()
    #  check win.is_valid()
    #  tab.set_var("var_from_nim", 13)
    #  check tab.get_var("var_from_nim").toInt() == 13
    #  tab.del_var("var_from_nim")
    #  var x = tab.get_var("var_from_nim")
    #  check tab.has_error()
    #  check x.kind == msgNull
    #  var wins = tab.list_wins()
    #  check wins.len == 1
    #  check wins[0].is_valid()
    #
    #test "buffer":
    #  var buf = nvim.get_current_buf()
    #  check buf.is_valid()
    #  check buf.line_count() == 1
    #  let lines = ["hello", "from", "nim", "client"]
    #  buf.set_lines(1, lines.len + 1, false, lines)
    #  var z = buf.get_lines(1, lines.len + 1, true)
    #  check buf.line_count() == 5
    #  for i in 0..<lines.len:
    #    check z[i] == lines[i]
    #
    #  buf.set_var("var_from_nim", 13)
    #  check buf.get_var("var_from_nim").toInt() == 13
    #  buf.del_var("var_from_nim")
    #  var x = buf.get_var("var_from_nim")
    #  check buf.has_error()
    #  check x.kind == msgNull
    #
    #  buf.set_option("tabstop", 2)
    #  check buf.get_option("tabstop").toInt() == 2
    #  check buf.get_changedtick() == 3 # set_line, set_var, set_option
    #
    #  var keymap = buf.get_keymap("n")
    #  check keymap.kind == msgArray
    #
    #  buf.set_name("melancholia.txt")
    #  check buf.get_name().extractFilename() == "melancholia.txt"
    #
    #  check buf.get_mark("a") == (0,0)
    #
    #  let src = buf.add_highlight(0, "ErrorMsg", 2, 0, 3)
    #  buf.clear_highlight(src, 0, -1)
    #
    #test "window":
    #  var win = nvim.get_current_win()
    #  check win.is_valid()
    #  check win.get_position() == (0,0)
    #  check win.get_number() == 1
    #  var wtab = win.get_tabpage()
    #  var tab = nvim.get_current_tabpage()
    #  check wtab == tab
    #
    #  var wbuf = win.get_buf()
    #  var buf = nvim.get_current_buf()
    #  check wbuf == buf
    #
    #  win.set_var("var_from_nim", 13)
    #  check win.get_var("var_from_nim").toInt() == 13
    #  win.del_var("var_from_nim")
    #  var x = win.get_var("var_from_nim")
    #  check win.has_error()
    #  check x.kind == msgNull
    #  win.set_option("scroll", 13)
    #  check win.get_option("scroll").toInt() == 13
    #
    #  nvim.command(":sp") #split window horizontally
    #  win = nvim.get_current_win()
    #  let h = win.get_height()
    #  win.set_height(h + 1)
    #  check win.get_height() == (h + 1)
    #
    #  nvim.command(":vsp") #split window vertically
    #  win = nvim.get_current_win()
    #  let w = win.get_width()
    #  win.set_width(w + 1)
    #  check win.get_width() == (w + 1)
    #
    #  win.set_cursor(3, 3)
    #  check win.get_cursor() == (3,3)

    test "client":
      var opts = anyMap()
      opts["rgb"] = anyBool(true)

      nvim.ui_attach(20, 80, opts)
      echo nvim.last_error()

    nvim.close()
  except:
    echo getCurrentExceptionMsg()

main()
