extends CharacterBody2D


const SPEED = 40

func movement():
	var x_mov = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y_mov = Input.get_action_strength("down") - Input.get_action_strength("up")
	var mov = Vector2(x_mov, y_mov)
	velocity = mov.normalized() * SPEED
	print(velocity)
	move_and_slide()

func _physics_process(delta: float) -> void:
	movement()
