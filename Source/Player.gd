extends KinematicBody2D

# Constants
const UP_DIRECTION: = Vector2.UP

export var id: = 0
# Movement
export var speed: = 200.0
export var gravity: = 400.0
export var maximum_jumps: = 2
export var jump_strength: = 200.0
export var double_jump_strenght: = 200.0
export var fast_fall_strength: = 50.0
export var max_fast_fall_speed: = 100.0
var _velocity: = Vector2.ZERO
var _jumps_made: = 0
# Attack
export var light_damage: = 50
export var knockback_up_strength: = 1.0
export var knockback_side_strength: = 1.0
export var knockback_decrease: = 0.1
var _is_attacking: = false
var _is_hit: = false
var _is_dodging: = false
var _damage_multiplier: = 0.0
var _knockback: = Vector2.ZERO
var _attack_side: = Vector2.ZERO

onready var _pivot: Sprite = $Sprite
onready var _animation: AnimationPlayer = $Animation
onready var _start_scale: = _pivot.scale


func _physics_process(delta: float) -> void:
	var _is_free: = _is_attacking == false and _is_hit == false and _is_dodging == false
	var _horizontal_direction = Input.get_action_strength("move_right_%s" % id) - Input.get_action_strength("move_left_%s" % id)
	
	_velocity.x = _horizontal_direction * speed
	_velocity.y += gravity * delta
	
	# Movement
	var _is_falling: = _velocity.y > 0.0 and not is_on_floor()
	var _is_fast_falling: = Input.is_action_pressed("move_down_%s" %id)
	var _is_jumping: = Input.is_action_just_pressed("jump_%s" % id) and is_on_floor()
	var _is_double_jumping: = Input.is_action_just_pressed("jump_%s" % id) and not is_on_floor()
	var _is_jump_cancelled: = Input.is_action_just_released("jump_%s" % id) and _velocity.y < 0.0
	var _is_idling: = is_on_floor() and is_zero_approx(_velocity.x)
	var _is_running: = is_on_floor() and not is_zero_approx(_velocity.x)
	var _is_knockback: = !(is_zero_approx(_knockback.x) and is_zero_approx(_knockback.y))
	
	if _is_dodging and is_zero_approx(_horizontal_direction):
		if _is_fast_falling:
			_velocity.x = 0
			_velocity.y += fast_fall_strength
		else:
			_velocity = Vector2.ZERO
	elif _is_knockback:
		_velocity += _knockback
		_knockback = lerp(_knockback, Vector2.ZERO, knockback_decrease)
	elif _is_jumping:
		_jumps_made += 1
		_velocity.y = -jump_strength
	elif _is_double_jumping:
		_jumps_made += 1
		if _jumps_made <= maximum_jumps:
			_velocity.y = -double_jump_strenght
	elif _is_jump_cancelled:
		_velocity.y = 0.0
	elif _is_fast_falling:
		_velocity.y += fast_fall_strength
	elif _is_idling or _is_running:
		_jumps_made = 0
	
	_velocity = move_and_slide(_velocity, UP_DIRECTION)
	
	# Animations
	if not is_zero_approx(_velocity.x):
		_pivot.scale.x = sign(_velocity.x) * _start_scale.x

	if _is_jumping or _is_double_jumping and _is_free:
		_animation.play("jump")
	elif _is_running and _is_free:
		_animation.play("run")
	elif _is_falling and _is_free:
		_animation.play("fall")
	elif _is_idling and _is_free:
		_animation.play("idle")
	
	# Attacks
	var _neutral_light: = Input.is_action_just_pressed("light_attack_%s" %id) and is_on_floor()
	var _down_light: = Input.is_action_just_pressed("light_attack_%s" %id) and Input.is_action_pressed("move_down_%s" %id) and is_on_floor()
	var _side_light: = Input.is_action_just_pressed("light_attack_%s" % id) and is_on_floor() and not is_zero_approx(_velocity.x)
	
	var _air_neutral_light: = Input.is_action_just_pressed("light_attack_%s" %id) and not is_on_floor()
	var _air_down_light: = Input.is_action_just_pressed("light_attack_%s" %id) and Input.is_action_pressed("move_down_%s" %id) and not is_on_floor()
	var _air_side_light: = Input.is_action_just_pressed("light_attack_%s" % id) and not is_on_floor() and not is_zero_approx(_velocity.x)
	
	var _dodge: = Input.is_action_just_pressed("dodge_%s" %id)
	
	if _neutral_light or _down_light or _side_light:
		_is_attacking = true
		print_debug("Player %s is attacking" %id)
		_attack_side = Vector2(_horizontal_direction, 0)
		print_debug(_attack_side)
		_animation.current_animation = "Slight"
		yield(_animation, "animation_finished")
		_is_attacking = false

	if _air_neutral_light or _air_down_light or _air_side_light:
		_is_attacking = true
		print_debug("Player %s is attacking" %id)
		_attack_side = Vector2(_horizontal_direction, 0)
		print_debug(_attack_side)
		_animation.current_animation = "Slight"
		yield(_animation, "animation_finished")
		_is_attacking = false

	if _dodge:
		_is_dodging = true
		_animation.current_animation = "dodge"
		yield(_animation, "animation_finished")
		_is_dodging = false


func take_damage(damage: float) -> void:
	_is_hit = true
	_damage_multiplier += damage
	_animation.current_animation = "hit"
	_knockback = Vector2(
		_attack_side.x * _damage_multiplier * knockback_side_strength,
		_damage_multiplier * knockback_up_strength * -1
	)
	print_debug("Player %s is hit and at " %id, _damage_multiplier)
	print_debug(_attack_side.x)
	yield(_animation, "animation_finished")
	_is_hit = false
