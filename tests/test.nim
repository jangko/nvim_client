import nvim, osproc

proc main() =
  try:
    var nvim = nvimClientConnectStdio("--embed")
    var paths = nvim.get_keymap("n")

    echo paths

    #nvim.command(":qa!")
    nvim.close()
  except:
    echo getCurrentExceptionMsg()

main()
