extends Node

@export var play_on_start := false

@export var music_player: AudioStreamPlayer
@onready var sync_stream : AudioStreamSynchronized = music_player.stream
@onready var total_streams := sync_stream.stream_count - 1

##@export var sfx_player: AudioStreamPlayer


var volume_range := Vector2(0.0, 10.0)
var music_volume := 1.0
var sfx_volume := 1.0

var stream_fraction_in_total_time = 0.0
var stream_percent = 0.0
var stream_percent_tracker = 0.0
var stream_index_tracker = 0
var stream_volume_change_speed = 30.0

var play_final_song = false

## ------------
## Music Tracks
## ------------

## stream_0 = What if Heaven is Hell
## stream_1 = I'm gonna get ya


func _ready() -> void:
	##var total_streams := sync_stream.stream_count
	stream_fraction_in_total_time = float(Main.world_timer) / float(total_streams)
	stream_percent = stream_fraction_in_total_time / float(Main.world_timer)
	stream_percent_tracker = 0.0
	stream_index_tracker = -1
	##print("stream count: ", total_streams, " - stream fraction: ", stream_fraction_in_total_time, " - timer set: ", Main.world_timer, " - stream percent: ", stream_percent)
	for i in range(0, total_streams+1):
		sync_stream.set_sync_stream_volume(i, -60)

	if play_on_start:
		music_player.play()


func _process(delta: float) -> void:
	## check to include next stream layer
	if stream_percent_tracker < (1 - Main.time_percent):
		stream_index_tracker = min(stream_index_tracker+1, total_streams)
		##sync_stream.set_sync_stream_volume(stream_index_tracker, 0)
		stream_percent_tracker += stream_percent
		##print("time percent: ", (1-Main.time_percent), " - stream percent tracker: ", stream_percent_tracker, " - index: ", stream_index_tracker)
		
	## lerp stream layer volume if below threshold
	var stream_volume = sync_stream.get_sync_stream_volume(stream_index_tracker)
	if stream_volume < 0:
		stream_volume = min(stream_volume + (delta * stream_volume_change_speed), 0)
		sync_stream.set_sync_stream_volume(stream_index_tracker, stream_volume)
		##print("index: ", stream_index_tracker, "--stream volume: ", stream_volume)
	
	## end-of-world-timer song
	if Main.end_of_timer == true and play_final_song == false:
		play_final_song = true
		stream_index_tracker += 1
		print("end of timer!!: ", Main.time_percent) ##, " - index: ", stream_index_tracker)
