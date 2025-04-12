# simple_scene_loader.gd
extends Node

signal scene_loaded(scene)
signal scene_load_failed(error)

var thread: Thread
var mutex: Mutex
var resource: Resource
var scene_path: String

func _ready():
	thread = Thread.new()
	mutex = Mutex.new()

func load_scene(path: String, use_sub_threads: bool = false):
	scene_path = path
	
	# If already loading, cancel previous load
	if thread.is_active():
		thread.wait_to_finish()
	
	# Start new thread for loading
	thread.start(Callable(self, "_thread_load").bind(path, use_sub_threads))

func _thread_load(path, use_sub_threads):
	var loader = ResourceLoader.load_threaded_request(path, "", use_sub_threads)
	if loader == OK:
		while true:
			var status = ResourceLoader.load_threaded_get_status(path)
			match status:
				ResourceLoader.THREAD_LOAD_LOADED:
					mutex.lock()
					resource = ResourceLoader.load_threaded_get(path)
					mutex.unlock()
					call_deferred("_loading_done")
					break
				ResourceLoader.THREAD_LOAD_FAILED:
					call_deferred("_loading_failed")
					break
				ResourceLoader.THREAD_LOAD_IN_PROGRESS:
					OS.delay_msec(50)  # Wait before checking again

func _loading_done():
	emit_signal("scene_loaded", resource)
	
func _loading_failed():
	emit_signal("scene_load_failed", "Failed to load: " + scene_path)

func get_resource() -> Resource:
	mutex.lock()
	var res = resource
	mutex.unlock()
	return res

func reload_current_scene():
	var current_path = get_tree().current_scene.scene_file_path
	load_scene(current_path)

func _exit_tree():
	if thread.is_active():
		thread.wait_to_finish()
