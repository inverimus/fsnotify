import base
import times, os


proc init(data: var PathEventData) =
  data.exists = true
  data.name = expandFilename(data.name)
  data.uniqueId = getUniqueFileId(data.name)
  data.lastModificationTime = getLastModificationTime(data.name)

proc init(data: ptr PathEventData) =
  data.exists = true
  data.name = expandFilename(data.name)
  data.uniqueId = getUniqueFileId(data.name)
  data.lastModificationTime = getLastModificationTime(data.name)

proc initFileEventData*(name: string, cb: EventCallback): PathEventData =
  result = PathEventData(kind: PathKind.File, name: name)
  result.cb = cb

  if fileExists(name):
    init(result)

# proc initFileEventData*(args: seq[tuple[name: string, cb: EventCallback]]): seq[FileEventData] =
#   result = newSeq[FileEventData](args.len)
#   for idx in 0 ..< args.len:
#     result[idx].name = args[idx].name
#     result[idx].cb = args[idx].cb

#     if dirExists(result[idx].name):
#       init(result[idx])

proc close*(data: PathEventData) =
  discard

proc filecb*(data: var PathEventData) =
  if data.exists:
    try:
      let now = getLastModificationTime(data.name)
      if now != data.lastModificationTime:
        data.lastModificationTime = now
        call(data, @[initPathEvent(data.name, FileEventAction.Modify)])
    except:
      data.exists = false
      var event = initPathEvent(data.name, FileEventAction.Remove)

      let dir = parentDir(data.name)
      for kind, name in walkDir(dir):
        if kind == pcFile and getUniqueFileId(name) == data.uniqueId:
          data.exists = true
          data.lastModificationTime = getLastModificationTime(name)
          event = initPathEvent(data.name, FileEventAction.Rename, name)
          data.name = name
          break

      call(data, @[event])
  else:
    if fileExists(data.name):
      init(data)
      call(data, @[initPathEvent(data.name, FileEventAction.Create)])
