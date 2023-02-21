extends KinematicBody2D

const UP_DIRECTION := Vector2.UP

export var speed := 200

export var light_damage := 10

export var jump_stenght := 200
export var maximum_jumps := 2
export var gravity := 400
export var double_jump_strenght := 200

export var id: = 0


var attack = false
var is_hit = false
var _jumps_made := 0
var _velocity := Vector2.ZERO

onready var _pivot: Node2D = $PlayerSkin
onready var _animation: AnimationPlayer = $PlayerSkin/Animation

onready var _start_scale: Vector2 = _pivot.scale

func _physics_process(delta: float) -> void:
	var _horizontal_direction = (
		Input.get_action_strength("move_right_%s" % id)
		 - Input.get_action_strength("move_left_%s" % id)
	)
	
	_velocity.x = _horizontal_direction * speed
	_velocity.y += gravity * delta
	
	var is_falling := _velocity.y > 0.0 and not is_on_floor()
	var is_jumping := Input.is_action_just_pressed("jump_%s" % id) and is_on_floor()
	var is_double_jumping := Input.is_action_just_pressed("jump_%s" % id) and is_falling
	var is_jump_cancelled := Input.is_action_just_released("jump_%s" % id) and _velocity.y < 0.0
	var is_idling := is_on_floor() and is_zero_approx(_velocity.x)
	var is_running := is_on_floor() and not is_zero_approx(_velocity.x)
	var atk_slight := Input.is_action_just_pressed("light_attack_%s" % id) and is_on_floor()
	
	if is_jumping:
		_jumps_made += 1
		_velocity.y = -jump_stenght
	elif is_double_jumping:
		_jumps_made += 1
		if _jumps_made <= maximum_jumps:
			_velocity.y = -double_jump_strenght
	elif is_jump_cancelled:
		_velocity.y = 0.0
	elif is_idling or is_running:
		_jumps_made = 0
	
	_velocity = move_and_slide(_velocity, UP_DIRECTION)
	
	
	if not is_zero_approx(_velocity.x):
		_pivot.scale.x = sign(_velocity.x) * _start_scale.x
	
		attack = true
		print("%s" % id, " attacking")
		_animation.current_animation = "Slight"
		yield(_animation, "animation_finished")
		attack = false
	
	if is_jumping or is_double_jumping:
		_animation.play("jump")
	elif is_running and (attack == false and is_hit == false):
		_animation.play("run")
	elif is_falling:
		_animation.play("fall")
	elif is_idling and (attack == false and is_hit == false):
		_animation.play("idle")

func take_damage(amount: int) -> void:
	is_hit = true
	_animation.current_animation = "hit"
	print("Damage: ", amount, " at %s" % id)
	yield(_animation, "animation_finished")
	is_hit = false
