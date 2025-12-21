class _CallTime:
    var time: int
    func _init(initial_time: int):
        time = initial_time

## debouncee probably isn't a real word but at least it's fun
static func debounce(debouncee: Callable, delay_seconds: float) -> Callable:
    var debounce_usec = int(delay_seconds * 1_000_000)
    var last_call_time: _CallTime = _CallTime.new(Time.get_ticks_usec())

    return func(args: Array):
        var current_time: int = Time.get_ticks_usec()
        if current_time - last_call_time.time >= debounce_usec:
            last_call_time.time = current_time
            debouncee.callv(args)
