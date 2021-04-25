extends KinematicBody2D
export(int) var rotation_speed := 300
export(float) var gravity_force := -.7
export(float) var bounce_force := 90

onready var left_bounce_area := $LeftBounceArea
onready var right_bounce_area := $RightBounceArea
onready var jump_sound := $JumpSound
onready var sprite := $Sprite

const Sparkles = preload("res://Sparkles.tscn")

enum {BOTH, LEFT, RIGHT}

var velocity := Vector2.ZERO
var max_velocity := 100.0
var active_light := BOTH
var active_collision_side = null

func _init():
	randomize()

func _process(delta) -> void:
	var input_dir := Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	if input_dir > 0:
		rotation_degrees += rotation_speed * delta
	elif input_dir < 0:
		rotation_degrees -= rotation_speed * delta
	
	apply_gravity()
	apply_dampening()
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.normal) * 0.6
		if active_collision_side == LEFT:# and active_light != RIGHT:
			velocity += transform.x * bounce_force
			active_light = RIGHT
			spark(left_bounce_area)
		elif active_collision_side == RIGHT:# and active_light != LEFT:
			velocity -= transform.x * bounce_force
			active_light = LEFT
			spark(right_bounce_area)
		if velocity.length() < 10:
			velocity -= transform.x * bounce_force / 2
			
	sprite.frame = BOTH#active_light
	
func spark(area):
	var sparkes = Sparkles.instance()
	get_tree().current_scene.add_child(sparkes)
	sparkes.global_position = area.global_position
	jump_sound.pitch_scale = rand_range(1, 1.4)
	jump_sound.play()

func apply_gravity() -> void:
	velocity -= Vector2.DOWN * gravity_force

func apply_dampening() -> void:
	velocity -= velocity * 0.001

func _on_LeftBounceArea_body_entered(body):
	active_collision_side = LEFT

func _on_LeftBounceArea_body_exited(body):
	active_collision_side = null

func _on_RightBounceArea_body_entered(body):
	active_collision_side = RIGHT

func _on_RightBounceArea_body_exited(body):
	active_collision_side = null
