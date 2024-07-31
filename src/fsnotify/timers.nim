import base

type
  Callback* = proc(args: var PathEventData) {.gcsafe.}

  TimerEvent* = ref object
    userData*: PathEventData
    cb*: Callback

  Timer* = ref object
    queue*: seq[TimerEvent]

proc initTimerEvent*(cb: Callback, userData: PathEventData): TimerEvent =
  TimerEvent(cb: cb, userData: userData)

proc initTimer*(): Timer =
  result = Timer(queue: newSeq[TimerEvent](0))

proc add*(timer: Timer, event: TimerEvent) =
  timer.queue.add(event)

proc execute*(t: TimerEvent) =
  if t.cb != nil:
    t.cb(t.userData)

proc process*(timer: Timer) =
  for event in timer.queue.mitems:
    if event.cb != nil:
      event.cb(event.userData)
