import winlean, os, osproc, streams

type
  TransportKind* = enum
    tkPipe
    tkStdio
    tkSocket

  TransportLayer* = object
    case kind: TransportKind
    of tkPipe: hPipe: Handle
    of tkStdio: process: Process
    of tkSocket: nil

proc initTransportLayer*(kind: TransportKind): TransportLayer =
  result.kind = kind
  case kind
  of tkPipe: result.hPipe = Handle(0)
  else: discard

proc waitNamedPipeW(name: WideCString, nTimeOut: DWORD): WINBOOL {.
  stdcall, dynlib: "kernel32", importc: "WaitNamedPipeW".}

proc connectPipe(self: var TransportLayer, address: string, timeOut: int): bool =
  const
    #PIPE_TYPE_MESSAGE      = 0x00000004'i32
    #PIPE_READMODE_MESSAGE  = 0x00000002'i32
    ERROR_PIPE_BUSY        = 231

  let pipeName = newWideCString(address)
  let openMode = GENERIC_READ or GENERIC_WRITE

  # Try to open a named pipe; wait for it, if necessary.
  while true:
    self.hPipe = createFileW(pipeName, openMode, 0, nil, OPEN_EXISTING, 0, 0.Handle)

    # Break if the pipe handle is valid.
    if self.hPipe != INVALID_HANDLE_VALUE: break

    # Exit if an error other than ERROR_PIPE_BUSY occurs.
    if getLastError() != ERROR_PIPE_BUSY:
       echo "Could not open pipe. GLE = ", getLastError()
       return false

    # All pipe instances are busy, so wait for 20 seconds.
    if waitNamedPipeW(pipeName, timeOut.DWORD) == 0:
       echo "Could not open pipe: " & $timeOut & "ms wait timed out."
       return false

  result = true

proc writePipe(self: var TransportLayer, data: string): bool =
  var dwWritten: int32
  if self.hPipe == INVALID_HANDLE_VALUE: return false
  let res = writeFile(self.hPipe, data.cstring, data.len.int32, dwWritten.addr, nil)
  result = res != 0 and dwWritten == data.len.int32

proc readPipe(self: var TransportLayer, buffer: var string): int =
  var
    bytesRead = 0'i32
    temp: array[2048, char]
    totalRead = 0
    success = false
    bytesAvail = 0'i32

  while true:
    success = readFile(self.hPipe, cast[cstring](temp[0].addr), temp.len.int32, bytesRead.addr, nil) == 1
    if buffer.len + bytesRead.int > buffer.len:
       buffer.setLen(buffer.len + bytesRead.int)

    copyMem(buffer[totalRead].addr, temp[0].addr, bytesRead.int)
    inc(totalRead, bytesRead.int)

    if peekNamedPipe(self.hPipe, nil, 0'i32, nil, bytesAvail.addr, nil) and bytesAvail == 0:
      break

    bytesRead = 0'i32

  result = totalRead

proc closePipe(self: var TransportLayer) =
  discard closeHandle(self.hPipe)

proc connectStdio*(self: var TransportLayer, address: string, timeOut: int): bool =
  self.process = startProcess("nvim.exe", "", [address], nil, {poUsePath})
  result = self.process.running()

proc writeStdio*(self: var TransportLayer, data: string): bool =
  self.process.inputStream.write(data)
  self.process.inputStream.flush()
  result = true

proc readStdio*(self: var TransportLayer, buffer: var string): int =
  while true:
    buffer = self.process.outputStream.readAll()
    result = buffer.len
    if result != 0: break

proc closeStdio*(self: var TransportLayer) =
  osproc.kill(self.process)

proc connectSocket*(self: var TransportLayer, address: string, timeOut: int): bool =
  discard

proc writeSocket*(self: var TransportLayer, data: string): bool =
  discard

proc readSocket*(self: var TransportLayer, buffer: var string): int =
  discard

proc closeSocket*(self: var TransportLayer) =
  discard

proc connect*(self: var TransportLayer, address: string, timeOut: int): bool =
  case self.kind
  of tkPipe: result = self.connectPipe(address, timeOut)
  of tkStdio: result = self.connectStdio(address, timeOut)
  of tkSocket: result = self.connectSocket(address, timeOut)

proc write*(self: var TransportLayer, data: string): bool =
  case self.kind
  of tkPipe: result = self.writePipe(data)
  of tkStdio: result = self.writeStdio(data)
  of tkSocket: result = self.writeSocket(data)

proc read*(self: var TransportLayer, buffer: var string): int =
  case self.kind
  of tkPipe: result = self.readPipe(buffer)
  of tkStdio: result = self.readStdio(buffer)
  of tkSocket: result = self.readSocket(buffer)

proc close*(self: var TransportLayer) =
  case self.kind
  of tkPipe: self.closePipe()
  of tkStdio: self.closeStdio()
  of tkSocket: self.closeSocket()
