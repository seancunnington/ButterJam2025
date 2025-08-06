extends Node

@export var play_on_start := false

@export var music_player: AudioStreamPlayer
@onready var sync_stream : AudioStreamSynchronized = music_player.stream
@onready var total_streams := sync_stream.stream_count

##@export var sfx_player: AudioStreamPlayer

## ------------
## World Music
## ------------
var volume_range := Vector2(0.0, 10.0)
var music_volume := 1.0
var sfx_volume := 1.0

var stream_fraction_in_total_time = 0.0
var stream_percent = 0.0
var stream_percent_tracker = 0.0
var stream_index_tracker = 0
var stream_volume_change_speed = 30.0

const MUSIC_TRACKS : Dictionary = {
	"What_if_Heaven_is_Hell" = 0,
	"Drums" = 1,
	"Arp" = 2
}


##----------------------------------------------
##                    Update                   |
##----------------------------------------------

func _ready() -> void:
	## signals setup
	Main.on_timers_reset.connect(audio_progress_reset)
	
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
	
	## Main music for world
	if Main.world_timer_active == true:
		## check to include next stream layer
		if stream_percent_tracker < (1 - Main.time_percent):
			stream_index_tracker = min(stream_index_tracker+1, total_streams)
			stream_percent_tracker += stream_percent
			##print("time percent: ", (1-Main.time_percent), " - stream percent tracker: ", stream_percent_tracker, " - index: ", stream_index_tracker)
			
		## lerp stream layer volume UP if below threshold
		var stream_volume = sync_stream.get_sync_stream_volume(stream_index_tracker)
		if stream_volume < 0:
			stream_volume = min(stream_volume + (delta * stream_volume_change_speed), 0)
			sync_stream.set_sync_stream_volume(stream_index_tracker, stream_volume)
			##print("index: ", stream_index_tracker, "--stream volume: ", stream_volume)
	
	elif Main.ghost_music_timer_active == true:
		var stream_volume
		## world music -> volume to silent
		stream_volume = max(sync_stream.get_sync_stream_volume(0) - delta * stream_volume_change_speed, -60)
		sync_stream.set_sync_stream_volume(MUSIC_TRACKS.What_if_Heaven_is_Hell, stream_volume)
		sync_stream.set_sync_stream_volume(MUSIC_TRACKS.Drums, stream_volume)
		sync_stream.set_sync_stream_volume(MUSIC_TRACKS.Arp, stream_volume)
		if $GhostMusicPlayer.playing == false:
			$GhostMusicPlayer.play()

func audio_progress_reset() -> void:
	stream_percent_tracker = 0.0
	stream_index_tracker = -1
