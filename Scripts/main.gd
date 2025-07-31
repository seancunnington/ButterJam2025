extends Node


##----------------------------------------------
##                  Total Time                 |
##----------------------------------------------

var time_percent = 0.0
var time_countdown = 0.0

const world_timer_set_mil = 1000
const world_timer_set_sec = 45
var world_timer_set = world_timer_set_mil * world_timer_set_sec
var world_timer = world_timer_set + Time.get_ticks_msec()

func _process(_delta: float) -> void:
	var time = Time.get_ticks_msec()
	if world_timer > time:
		time_percent = (world_timer - time) / float(world_timer_set)
		@warning_ignore("integer_division")
		time_countdown = (world_timer - time) / world_timer_set_mil + 1
		##print("world_timer: ", world_timer, " - time percent: ", time_percent, " - time countdown: ", time_countdown)
	else:
		time_percent = 0.0
		time_countdown = 0



##----------------------------------------------
##                Space Loading                |
##----------------------------------------------

func load_next_space() -> void:
	var current_space_path := get_tree().current_scene.scene_file_path
	var split_path := current_space_path.split(".")
	var next_space_number := split_path[1].to_int() + 1
	split_path[1] = str(next_space_number).pad_zeros(3)
	var next_space_path = ".".join(split_path)
	
	if not ResourceLoader.exists(next_space_path):
		split_path[1] = "001"
		next_space_path = ".".join(split_path)
		
	ResourceLoader.load_threaded_request(next_space_path)
		
	get_tree().paused = true
	await SpaceTransition.play_exit_space()
	
	get_tree().change_scene_to_packed(
		ResourceLoader.load_threaded_get(next_space_path)
	)
	
	await SpaceTransition.player_enter_space()
	get_tree().paused = false
