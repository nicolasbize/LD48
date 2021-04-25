extends CanvasLayer

onready var tween := $Tween
onready var highscore_panel := $HighScoreControl/HighScorePanel
onready var run_time_label := $HighScoreControl/HighScorePanel/RunTimeLabel
onready var local_best_label := $HighScoreControl/HighScorePanel/LocalBestLabel
onready var welcome_control := $WelcomeControl
onready var cup_sprite := $HighScoreControl/HighScorePanel/CupSprite

signal start_game

var game_started := false

func _ready():
	reset()

func _process(delta):
	if Input.is_action_just_pressed("ui_accept") and not game_started:
		emit_signal("start_game")
		welcome_control.visible = false

func reset():
	highscore_panel.modulate = Color(1,1,1,0)

func show_score(current, local_best):
	if current < 60*3:
		cup_sprite.frame = 1
	elif current < 60*6:
		cup_sprite.frame = 2
	elif current < 60 * 12:
		cup_sprite.frame = 3
	else:
		cup_sprite.frame = 0
	run_time_label.text = "Time: " + get_time_diff(current)
	local_best_label.text = "Local Best: " + get_time_diff(local_best)
	tween.interpolate_property(highscore_panel, "modulate", Color(1,1,1,0), Color(1,1,1,1), 1, Tween.TRANS_CUBIC, Tween.EASE_IN)
	tween.interpolate_property(highscore_panel, "rect_position", Vector2(90, 40), Vector2(90, 100), 2, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()

func get_time_diff(elapsed:int) -> String:
	var minutes = elapsed / 60
	var seconds = elapsed % 60
	return "%02d:%02d" % [ minutes, seconds]
