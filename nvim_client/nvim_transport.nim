import os, osproc, streams, sys/[handles, pipes]

type
  TransportKind* = enum
    tkPipe
    tkStdio
    tkSocket

  TransportLayer* = object
    case kind: TransportKind
    of tkPipe: file: File
    of tkStdio: process: Process
    of tkSocket: nil

func initTransportLayer*(kind: TransportKind): TransportLayer = discard

proc connectPipe(self: var TransportLayer, address: string, timeOut: int): bool =
  try:
    self.file = open(address, fmReadWriteExisting)
  except IOError:
    echo "Error connecting with pipe"

proc writePipe(self: var TransportLayer, data: string): bool =
  try:
    self.file.write(data)
  except IOError:
    return false

  result = true

proc readPipe(self: var TransportLayer, buffer: var string): int = discard

proc moreDataPipe(self: var TransportLayer): bool = discard

proc closePipe(self: var TransportLayer) =
  self.file.close()

proc connectStdio*(self: var TransportLayer, address: string, timeOut: int): bool =
  self.process = startProcess(address, "", [], nil, {poUsePath, poEvalCommand})
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

proc moreDataStdio(self: var TransportLayer): bool =
  result = self.process.outputStream.atEnd()

proc closeStdio*(self: var TransportLayer) =
  osproc.kill(self.process)

proc connectSocket*(self: var TransportLayer, address: string, timeOut: int): bool =
  discard

proc writeSocket*(self: var TransportLayer, data: string): bool =
  discard

proc readSocket*(self: var TransportLayer, buffer: var string): int =
  discard

proc moreDataSocket(self: var TransportLayer): bool =
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

proc moreData*(self: var TransportLayer): bool =
  case self.kind
  of tkPipe: result = self.moreDataPipe()
  of tkStdio: result = self.moreDataStdio()
  of tkSocket: result = self.moreDataSocket()

proc close*(self: var TransportLayer) =
  case self.kind
  of tkPipe: self.closePipe()
  of tkStdio: self.closeStdio()
  of tkSocket: self.closeSocket()
