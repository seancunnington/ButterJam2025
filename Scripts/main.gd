extends Node


##----------------------------------------------
##                    Globals                  |
##----------------------------------------------

## ----------
## Lights
var global_light_scale := 1.0

##-----------
##Time
signal ghost_timer_tick()
signal on_timers_reset()

var world_timer_active = false
var ghost_music_timer_active = false
var ghost_chase_timer_active = false

var time_percent = 0.0
var time_countdown = 0.0

const world_timer_set_mil = 1000
const world_timer_set_sec = 60
const world_timer_set = world_timer_set_mil * world_timer_set_sec
var world_timer = world_timer_set + Time.get_ticks_msec()

var ghost_timer = 0
var ghost_timer_index = 0
var ghost_timer_start = 0

## The milliseconds between each string section in "I'm Gonna Get Ya"
var ghost_timer_intervals = [
	650, 2600, 4600, 6700, 8900, 
	10900, 13000, 15000, 17200, 19200, 
	21200, 23300, 25400, 27500, 29500
]

var ghost_chase_timer = 0
var ghost_chase_timer_set = 1000 * 5    ## mil * sec


##----------------------------------------------
##               Init and Update               |
##----------------------------------------------

func _ready() -> void:
	global_light_scale = 1.0
	reset_all_world_timers()


func _process(_delta: float) -> void:
	var time = Time.get_ticks_msec()
	
	## World Timer
	if world_timer_active == true:
		if world_timer > time:
			time_percent = (world_timer - time) / float(world_timer_set)
			@warning_ignore("integer_division")
			time_countdown = (world_timer - time) / world_timer_set_mil + 1
			##print("world_timer: ", world_timer, " - time percent: ", time_percent, " - time countdown: ", time_countdown)
		
		## End of World Timer - single instance
		else:
			time_percent = 0.0
			time_countdown = 0
			ghost_timer_start = Time.get_ticks_msec()
			world_timer_active = false
			ghost_music_timer_active = true
			print(" -- WORLD TIMER END -- ")
	
	## Ghost Music Timer - plays ghost music with boolean 'ticks' at set points in milliseconds
	elif ghost_music_timer_active == true:
		if ghost_timer_index < ghost_timer_intervals.size():
			ghost_timer = Time.get_ticks_msec() - ghost_timer_start
			if ghost_timer > ghost_timer_intervals[ghost_timer_index]:
				ghost_timer_tick.emit()
				ghost_timer_index += 1
		else:
			ghost_music_timer_active = false
			ghost_chase_timer_active = true
			ghost_chase_timer = ghost_chase_timer_set + Time.get_ticks_msec()
			print(" -- GHOST MUSIC TIMER END -- ")
		##print("Ghost timer: ", ghost_timer, " - index: ", ghost_timer_index, " - current interval: ", ghost_timer_intervals[ghost_timer_index])
	
	## Timer for ghost chasing player - once finished, resets all timers and starts world timer again.
	elif ghost_chase_timer_active == true:
		if ghost_chase_timer <= time:
			reset_all_world_timers()
			on_timers_reset.emit()
			print(" -- GHOST CHASE TIMER END -- ")




##----------------------------------------------
##               Time Management               |
##----------------------------------------------

func reset_all_world_timers() -> void:
	world_timer = world_timer_set + Time.get_ticks_msec()
	world_timer_active = true
	
	ghost_music_timer_active = false
	ghost_timer = 0
	ghost_timer_index = 0
	
	ghost_chase_timer_active = false
	ghost_chase_timer = 0


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
