extends Node2D

onready var stick := $BouncyStick
onready var camera_target := $CameraTarget
onready var canvas_modulate := $CanvasModulate

func _process(delta):
	camera_target.global_position.y = stick.global_position.y
	var f:float = stick.global_position.y / 3200
	canvas_modulate.color = Color.white.linear_interpolate(Color(0.2,0.2,0.2), f)
