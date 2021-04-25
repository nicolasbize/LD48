extends Node2D

onready var state_timer := $Timer

var initial_data := []
var shadow_data := []
var checkpoints_data := []
var prev_shadow_time := 0
var prev_state := []
var current_state := []
var next_state := []

func _process(delta):
	if prev_state.size() > 0 and next_state.size() > 0:
		var current_time = OS.get_system_time_msecs()
		var frame:float = (current_time - prev_shadow_time) / 100.0
		global_position = prev_state[0].linear_interpolate(next_state[0], frame)
		global_rotation = lerp_angle(prev_state[1], next_state[1], frame)		

func lerp_angle(from, to, weight):
	return from + short_angle_dist(from, to) * weight

func short_angle_dist(from, to):
	var max_angle = PI * 2
	var diff = fmod(to - from, max_angle)
	return fmod(2 * diff, max_angle) - diff

func _on_Timer_timeout():
	prev_shadow_time = OS.get_system_time_msecs()
	if shadow_data.size() > 0:
		prev_state = next_state.duplicate(true)
		next_state = shadow_data.pop_front()
		if prev_state.size() > 0:
			if prev_state[1] > 100 and next_state[1] < -100: # lerp won't work here
				next_state[1] += 360
			elif prev_state[1] < -100 and next_state[1] > 100:
				next_state[1] -= 360
			
	else:
		prev_state = []
		next_state = []
	state_timer.start()

func get_final_time():
	return checkpoints_data.back()

func init(data, checkpoints):
	shadow_data = data
	initial_data = shadow_data.duplicate(true)
	checkpoints_data = checkpoints
	prev_state = data[0]
	global_position = data[0][0]
	global_rotation = data[0][1]

func destroy():
	state_timer.stop()
	queue_free()
