extends Node2D

const Shadow = preload("res://Shadow.tscn")

onready var stick := $BouncyStick
onready var camera_target := $CameraTarget
onready var canvas_modulate := $CanvasModulate
onready var state_timer := $StateTimer
onready var time_label := $UI/Topbar/TimeLabel
onready var shadow_label := $UI/Topbar/BestTimeLabel
onready var checkpoints := $Checkpoints
onready var ui := $UI
onready var music_player := $MusicPlayer

var time_start := 0
var time_now := 0
var game_data := []
var checkpoint_data := []
var local_shadow = null
var won := false
var beat_local := false
var pending_request := true

func _ready() -> void:
	time_start = OS.get_unix_time()
	set_process(true)
	for check in checkpoints.get_children():
		check.connect("entered", self, "_on_checkpoint_enter")
	ui.connect("start_game", self, "_on_game_start")
	get_tree().paused = true

func _on_game_start() -> void:
	get_tree().paused = false
	music_player.play()
	reset_game()

func _on_checkpoint_enter(is_last):
	time_now = OS.get_unix_time()
	var elapsed := time_now - time_start
	checkpoint_data.append(elapsed)
	if local_shadow != null and local_shadow.checkpoints_data.size() >= checkpoint_data.size():
		shadow_label.visible = true
		local_shadow.checkpoints_data.size() >= checkpoint_data.size()
		var shadow_time = local_shadow.checkpoints_data[checkpoint_data.size() - 1]
		if shadow_time > elapsed:
			shadow_label.text = "BEST: -" + get_time_diff(elapsed, shadow_time)
			shadow_label.set("custom_colors/font_color", Color(0,1,0))
		else:
			shadow_label.text = "BEST: +" + get_time_diff(shadow_time, elapsed)
			shadow_label.set("custom_colors/font_color", Color(1,0,0))
	if is_last:
		var local_best = elapsed
		beat_local = true
		if local_shadow != null and local_shadow.checkpoints_data.back() < checkpoint_data.back():
			local_best = local_shadow.checkpoints_data.back()
			beat_local = false
		ui.show_score(elapsed, local_best)
		won = true
		
func _process(delta):
	if won == false:
		time_label.text = get_time_diff(time_start, OS.get_unix_time())
		camera_target.global_position.y = stick.global_position.y
	var f:float = stick.global_position.y / 3200
	canvas_modulate.color = Color.white.linear_interpolate(Color(0.2,0.2,0.2), f)
	if Input.is_action_just_pressed("ui_accept"):
		reset_game()
	
func get_time_diff(start:int, finish:int) -> String:
	var elapsed := finish - start
	var minutes = elapsed / 60
	var seconds = elapsed % 60
	return "%02d:%02d" % [ minutes, seconds]

func _on_StateTimer_timeout():
	game_data.append([stick.global_position, stick.global_rotation])
	state_timer.start()

func reset_game():
	time_start = OS.get_unix_time()
	stick.global_position = Vector2(20, 30)
	stick.global_rotation_degrees = 90
	stick.velocity = Vector2.ZERO
	ui.reset()
	if won and game_data.size() > 0: # and game_data is best local game
		var next_shadow_data = game_data.duplicate(true)
		var next_checkpoint_data = checkpoint_data.duplicate(true)
		if not beat_local and local_shadow != null:
			next_shadow_data = local_shadow.initial_data.duplicate(true)
			next_checkpoint_data = local_shadow.checkpoints_data.duplicate(true)
		if local_shadow != null:
			local_shadow.destroy()
		local_shadow = Shadow.instance()
		get_tree().current_scene.add_child(local_shadow)
		local_shadow.init(next_shadow_data, next_checkpoint_data)
		game_data = []
		checkpoint_data = []
	for child in checkpoints.get_children():
		child.reset()
	shadow_label.visible = false
	won = false
