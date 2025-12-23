extends RefCounted

class_name ThreadPool

# Singleton
static var _instance: ThreadPool = ThreadPool.new()
static func get_instance() -> ThreadPool:
    return _instance

class ThreadPoolJob:
    var id: int
    var callable: Callable
    var args: Array

    func _init(_id: int, _callable: Callable, _args: Array = []):
        id = _id
        callable = _callable
        args = _args

var _threads: Array = []
var _semaphore: Semaphore = Semaphore.new()
var _mutex: Mutex = Mutex.new()
var _job_queue: Array[ThreadPoolJob] = []
var _quit: bool = false
var _next_job_id: int = 1

# create and start N worker threads on this thread pool
func start(count: int = 4) -> void:
    # stop any existing threads first
    if _threads.size() > 0:
        shutdown(true)
    _quit = false
    _threads.clear()
    for i in count:
        var t := Thread.new()
        _threads.append(t)
        t.start(_worker)

# Submit a job: a Callable and optional Array of args.
# Returns an integer job id.
func submit(callable: Callable, args: Array = []) -> int:
    if not callable:
        push_error("ThreadPool.submit: callable is null")
        return -1
    _mutex.lock()
    var job_id = _next_job_id
    _next_job_id += 1
    _job_queue.append(ThreadPoolJob.new(job_id, callable, args))
    _mutex.unlock()

    # wake one worker
    _semaphore.post()
    
    return job_id

# worker entrypoint; runs in thread
func _worker() -> void:
    while true:
        # wait until there's a job or shut down
        _semaphore.wait()

        _mutex.lock()
        if _quit and _job_queue.is_empty():
            _mutex.unlock()
            break
        if _job_queue.is_empty():
            _mutex.unlock()
            continue
        var job = _job_queue.pop_front()
        _mutex.unlock()
        
        # execute the callable
        var c: Callable = job.callable
        var a: Array = job.get("args", [])
        var result = c.callv(a)
        
        # TODO: emit results (with a signal?)
        print(result)

# shut down the pool. if wait is true, joins threads before returning.
func shutdown(wait: bool = true) -> void:
    _mutex.lock()
    _quit = true
    _mutex.unlock()
    # post once per thread to wake them
    for i in _threads.size():
        _semaphore.post()
    if wait:
        # block until every thread completes
        for t in _threads:
            t.wait_to_finish()
    _threads.clear()

func get_queue_size() -> int:
    _mutex.lock()
    var s = _job_queue.size()
    _mutex.unlock()
    return s

func is_running() -> bool:
    _mutex.lock()
    var quit = _quit
    _mutex.unlock()

    return _threads.size() > 0 and not quit