import nvim

proc main() =
  var nvim = nvimClientConnect("\\\\.\\pipe\\nvim-4492-0")
  var win = nvim.get_current_win()
  #var buf = win.get_buf()
  #let line_count = buf.line_count()
  #var lines = buf.get_lines(1, line_count, false)
  #echo lines
  #echo line_count
  #buf.set_name("megalomania.txt")

  #buf.set_lines(0, 4, false, ["new line 2", "hello world", "ni hao", "sayonara"])
  #echo win.get_cursor()
  #win.set_cursor(1, 3)
  #echo win.get_width()
  #echo win.get_height()
  #echo win.is_valid()
  #echo win.get_position()
  #nvim.command(":echo 'hello there'")

  #echo nvim.command_output(":echo 'hello there'")
  #echo nvim.list_runtime_paths
  #var res = nvim.execute_lua("print('hello from nim nvim-client')")
  #var res = nvim.call_function("cursor", 10, 10)
  #var res = nvim.get_api_info()
  #nvim.set_var("nim_channel_id", res[0].toInt)
  #win.set_cursor(1, 3)
  #nvim.listen()

  var b = initNvimBatch()
  b.get_current_buf()
  b.get_current_win()
  b.get_current_tabpage()
  b.get_current_line()

  var res = nvim.call_atomic(b)
  for c in res:
    echo c.kind
    if c.kind == brkString: echo c.strVal

  nvim.close()
main()