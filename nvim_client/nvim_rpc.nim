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

import macros, msgpack4nim as msgpack, msgpack2any, nvim_transport, strutils

type
  MessageType = enum
    Request = 0
    Response = 1
    Notification = 2

type
  NvimRpc* = ref object
    io: TransportLayer
    msgId: int
    lastError*: string
    hasError*: bool
    errorCode*: int
    null: MsgAny
    notifyResponse*: bool

  NvimClient* = object
    rpc*: NvimRpc

  NvimBase* = object of RootObj
    id*: int
    value*: string
    rpc*: NvimRpc

  NvimWindow* = object of NvimBase

  NvimBuffer* = object of NvimBase

  NvimTabPage* = object of NvimBase

  BatchReturnKind* = enum
    brkSeqBuffer
    brkSeqWindow
    brkSeqTabPage
    brkSeqString
    brkObject
    brkVoid
    brkInt
    brkWindow
    brkBool
    brkString
    brkPos
    brkTabPage
    brkBuffer
    brkError

  CallSpec = object
    call: string
    returnKind: BatchReturnKind

  NvimBatch* = object
    calls*: seq[CallSpec]

  BatchResult* = object
    case kind*: BatchReturnKind
    of brkSeqBuffer: seqBufVal*: seq[NvimBuffer]
    of brkSeqWindow: seqWinVal*: seq[NvimWindow]
    of brkSeqTabPage: seqTabVal*: seq[NvimTabPage]
    of brkSeqString: seqStrVal*: seq[string]
    of brkObject: objVal*: MsgAny
    of brkInt: intVal*: int
    of brkBool: boolVal*: bool
    of brkString: strVal*: string
    of brkPos: posVal*: tuple[x, y: int]
    of brkWindow: winVal*: NvimWindow
    of brkTabPage: tabVal*: NvimTabPage
    of brkBuffer: bufVal*: NvimBuffer
    of brkError: errMsg*: string
    of brkVoid: nil

proc pack_base*(val: NvimBase): string =
  var s = initMsgStream()
  s.pack_ext(val.value.len, val.id.int8)
  s.write(val.value)
  result = s.data

proc pack*(val: NvimWindow): string = pack_base(val)
proc pack*(val: NvimBuffer): string = pack_base(val)
proc pack*(val: NvimTabPage): string = pack_base(val)
proc pack*(val: MsgAny): string = fromAny(val)

proc pack*(val: NvimBatch): string =
  var s = initMsgStream()
  s.pack_array(val.calls.len)
  for x in val.calls: s.write(x.call)
  result = s.data

proc pack_varargs*(args: varargs[string]): string =
  var s = initMsgStream()
  s.pack_array(args.len)
  for x in args: s.write(x)
  result = s.data

proc toInt*(msg: MsgAny): int =
  if msg.kind == msgInt: result = msg.intVal.int
  elif msg.kind == msgUint: result = msg.uintVal.int
  else: result = 0

proc toBool*(msg: MsgAny): bool =
  if msg.kind == msgBool: result = msg.boolVal
  else: result = false

proc toString*(msg: MsgAny): string =
  if msg.kind == msgString: result = msg.stringVal
  else: result = ""

proc toSeqString*(msg: MsgAny): seq[string] =
  if msg.kind == msgArray:
    result = newSeq[string](msg.len)
    for i in 0..<msg.len: result[i] = msg[i].stringVal
  else:
    result = @[]

proc toVoid*(msg: MsgAny) =
  assert(msg.kind == msgNull)

proc toBuffer*(msg: MsgAny, rpc: NvimRpc): NvimBuffer =
  if msg.kind == msgExt:
    assert msg.extType == 0
    result = NvimBuffer(id: msg.extType.int, value: msg.extData, rpc: rpc)

proc toWindow*(msg: MsgAny, rpc: NvimRpc): NvimWindow =
  if msg.kind == msgExt:
    assert msg.extType == 1
    result = NvimWindow(id: msg.extType.int, value: msg.extData, rpc: rpc)

proc toTabPage*(msg: MsgAny, rpc: NvimRpc): NvimTabPage =
  if msg.kind == msgExt:
    assert msg.extType == 2
    result = NvimTabPage(id: msg.extType.int, value: msg.extData, rpc: rpc)

proc toSeqBuffer*(msg: MsgAny, rpc: NvimRpc): seq[NvimBuffer] =
  if msg.kind == msgArray:
    result = newSeq[NvimBuffer](msg.len)
    for i in 0..<msg.len:  result[i] = msg[i].toBuffer(rpc)
  else:
    result = @[]

proc toSeqWindow*(msg: MsgAny, rpc: NvimRpc): seq[NvimWindow] =
  if msg.kind == msgArray:
    result = newSeq[NvimWindow](msg.len)
    for i in 0..<msg.len:  result[i] = msg[i].toWindow(rpc)
  else:
    result = @[]

proc toSeqTabPage*(msg: MsgAny, rpc: NvimRpc): seq[NvimTabPage] =
  if msg.kind == msgArray:
    result = newSeq[NvimTabPage](msg.len)
    for i in 0..<msg.len:  result[i] = msg[i].toTabPage(rpc)
  else:
    result = @[]

proc toPos*(msg: MsgAny): tuple[x, y: int] =
  if msg.kind == msgArray:
    result = (msg[0].toInt, msg[1].toInt)

proc toBatchResult*(msg: MsgAny, batch: NvimBatch, rpc: NvimRpc): seq[BatchResult] =
  if msg.kind != msgArray:
    result = @[]
    return

  assert msg.len == 2
  var resultLen = msg[0].len
  let error = msg[1].kind != msgNull
  result = newSeq[BatchResult](resultLen + error.int)
  let len = min(resultLen, batch.calls.len)

  if error:
    assert msg[1].kind == msgArray
    assert msg[1].len == 3
    result[^1] = BatchResult(kind: brkError, errMsg: msg[1][2].toString)

  for i in 0..<len:
    case batch.calls[i].returnKind
    of brkSeqBuffer: result[i] = BatchResult(kind: brkSeqBuffer, seqBufVal: msg[0][i].toSeqBuffer(rpc))
    of brkSeqWindow: result[i] = BatchResult(kind: brkSeqWindow, seqWinVal: msg[0][i].toSeqWindow(rpc))
    of brkSeqTabPage: result[i] = BatchResult(kind: brkSeqTabPage, seqTabVal: msg[0][i].toSeqTabPage(rpc))
    of brkSeqString: result[i] = BatchResult(kind: brkSeqString, seqStrVal: msg[0][i].toSeqString())
    of brkObject: result[i] = BatchResult(kind: brkObject, objVal: msg[0][i])
    of brkInt: result[i] = BatchResult(kind: brkInt, intVal: msg[0][i].toInt())
    of brkBool: result[i] = BatchResult(kind: brkBool, boolVal: msg[0][i].toBool())
    of brkString: result[i] = BatchResult(kind: brkString, strVal: msg[0][i].toString())
    of brkPos: result[i] = BatchResult(kind: brkPos, posVal: msg[0][i].toPos())
    of brkWindow: result[i] = BatchResult(kind: brkWindow, winVal: msg[0][i].toWindow(rpc))
    of brkTabPage: result[i] = BatchResult(kind: brkTabPage, tabVal: msg[0][i].toTabPage(rpc))
    of brkBuffer: result[i] = BatchResult(kind: brkBuffer, bufVal: msg[0][i].toBuffer(rpc))
    of brkVoid, brkError: discard

proc rpc_connect_pipe*(address: string, timeOut: int): NvimRpc =
  new(result)
  result.io = initTransportLayer(tkPipe)
  if result.io.connect(address, timeOut):
    result.null = anyNull()
    result.msgId = 0
    result.lastError = ""
    return result
  result = nil

proc rpc_connect_stdio*(address: string, timeOut: int): NvimRpc =
  new(result)
  result.io = initTransportLayer(tkStdio)
  if result.io.connect(address, timeOut):
    result.null = anyNull()
    result.msgId = 0
    result.lastError = ""
    return result
  result = nil

proc close*(self: NvimRpc) =
  self.io.close()

var debug* = false

proc process_packet*(self: NvimRpc, m: MsgAny): MsgAny =
  assert m.kind == msgArray
  assert m.len >= 3 and m.len <= 4

  case MessageType(m[0].toInt())
  of Notification:
    assert m[1].kind == msgString
    assert m[2].kind == msgArray

    if self.notifyResponse:      
      var input = ""
      self.notifyResponse = false
      if self.io.read(input) > 0:
        var m = toAny(input)
        return self.process_packet(m)

    return self.null
  of Request:
    assert m[1].kind in {msgInt, msgUint}
    assert m[2].kind == msgString
    assert m[3].kind == msgArray

    #var s = initMsgStream()
    #s.pack_array(4)
    #s.pack(Response)
    #s.pack(m[1].toInt)
    #s.write(pack_value_nil)
    ##s.pack((1, "no function defined"))
    #s.write(pack_value_nil)
    ##s.pack("hello from my friend")
    #discard self.io.write(s.data)
    return self.null
  of Response:
    assert(m[1].toInt == self.msgId - 1, $m[1].toInt & " " & $(self.msgId - 1))
    self.hasError = m[2].kind != msgNull
    if self.hasError:
      self.errorCode = m[2][0].toInt
      self.lastError = m[2][1].stringVal
      return self.null
    return m[3]
  else:
    self.hasError = true
    self.lastError = "packet error"
    self.errorCode = -2
    return self.null

proc make_request*(self: NvimRpc, methodName: string, args: varargs[string]): MsgAny =
  var output = initMsgStream()
  output.pack_array(4)
  output.pack(Request)
  output.pack(self.msgId)
  output.pack(methodName)
  output.pack_array(args.len)
  for x in args: output.write(x)
  inc(self.msgId)
  #echo stringify(output.data)

  if self.io.write(output.data):
    var input = ""
    if self.io.read(input) > 0:
      var m = toAny(input)
      if debug: echo m
      return self.process_packet(m)

  self.hasError = true
  self.errorCode = -1
  self.lastError = "io error"
  return self.null

proc request_aux*(self: NvimRpc, methodName: string, args: varargs[string]): MsgAny =
  if self == nil: return self.null
  self.hasError = false
  self.errorCode = 0
  self.lastError = ""
  result = self.make_request(methodName, args)

proc guessPacker(n: NimNode): string {.compileTime.} =
  let argT = getType(n)
  if argT.kind == nnkBracketExpr and $argT[0] == "varargs":
    result = "pack_varargs("
  else: result = "pack("

macro request*(self: NvimRpc, methodName: string, args: varargs[typed]): untyped =
  var callexpr = "request_aux(" & toStrLit(self).strVal & ", \"" & $methodName & "\""
  for i in 0..<args.len: callexpr.add(", " & guessPacker(args[i]) & toStrLit(args[i]).strVal & ")")
  callexpr.add(")")
  result = parseStmt(callexpr)

proc store_aux*(self: var NvimBatch, methodName: string, returnKind: BatchReturnKind, args: varargs[string]) =
  var s = initMsgStream()
  s.pack_array(2)
  s.pack(methodName)
  s.pack_array(args.len)
  for x in args: s.write(x)
  self.calls.add CallSpec(call: s.data, returnKind: returnKind)

macro store*(self: var NvimBatch, methodName: string, returnKind: BatchReturnKind, args: varargs[typed]): untyped =
  var callexpr = "store_aux(" & toStrLit(self).strVal & ", \"" & $methodName & "\", " & toStrLit(returnKind).strVal
  for i in 0..<args.len: callexpr.add(", " & guessPacker(args[i]) & toStrLit(args[i]).strVal & ")")
  callexpr.add(")")
  result = parseStmt(callexpr)
