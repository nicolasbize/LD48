extends RigidBody2D

export(int) var rotation_speed := 300

func _process(delta):
	var input_dir := Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	if input_dir == 0:
		angular_velocity = 0
	else:
		angular_velocity = delta * rotation_speed * sign(input_dir)
	
