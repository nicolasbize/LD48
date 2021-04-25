extends Area2D

var entered := false

signal entered(last_checkpoint)

export(bool) var is_last_checkpoint := false

onready var sprite := $Sprite
onready var enter_sound := $EnterSound

func _on_Checkpoint_body_entered(body):
	if not entered:
		entered = true
		sprite.modulate = Color("a6ff90")
		enter_sound.play()
		emit_signal("entered", is_last_checkpoint)

func reset():
	entered = false
	sprite.modulate = Color.white
