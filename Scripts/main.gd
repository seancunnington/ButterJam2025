extends Node


##----------------------------------------------
##                    Globals                  |
##----------------------------------------------

## ----------
## Lights
var global_light_scale := 1.0

##-----------
##Time
var time_percent = 0.0
var time_countdown = 0.0
var end_of_timer = false

const world_timer_set_mil = 1000
const world_timer_set_sec = 5
var world_timer_set = world_timer_set_mil * world_timer_set_sec
var world_timer = world_timer_set + Time.get_ticks_msec()

var ghost_timer = 0
var ghost_timer_tick = false
var ghost_timer_index = 0
var ghost_timer_start = 0
var ghost_timer_intervals = [
	1000,
	7000,
	13000,
	19000,
	25000
]


##----------------------------------------------
##               Init and Update               |
##----------------------------------------------

func _ready() -> void:
	global_light_scale = 1.0
	end_of_timer = false
	ghost_timer = 0
	ghost_timer_index = 0
	ghost_timer_tick = false


func _process(_delta: float) -> void:
	var time = Time.get_ticks_msec()
	ghost_timer_tick = false
	
	## World Timer
	if world_timer > time:
		time_percent = (world_timer - time) / float(world_timer_set)
		@warning_ignore("integer_division")
		time_countdown = (world_timer - time) / world_timer_set_mil + 1
		##print("world_timer: ", world_timer, " - time percent: ", time_percent, " - time countdown: ", time_countdown)
	
	## End of World Timer - single instance
	elif end_of_timer == false:
		time_percent = 0.0
		time_countdown = 0
		ghost_timer_start = Time.get_ticks_msec()
		end_of_timer = true
	
	## Ghost Timer - runs after world timer has fully elapsed.
	elif end_of_timer == true:
		ghost_timer = Time.get_ticks_msec() - ghost_timer_start
		if ghost_timer > ghost_timer_intervals[ghost_timer_index]:
			ghost_timer_tick = true
			ghost_timer_index = min(ghost_timer_index+1, ghost_timer_intervals.size()-1)
			print("ghost index: ", ghost_timer_index)
		##print("Ghost timer: ", ghost_timer, " - index: ", ghost_timer_index, " - current interval: ", ghost_timer_intervals[ghost_timer_index])




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
