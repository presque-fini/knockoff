extends Actor

# Destructible tiles
var tilemap: TileMap
var cell: Vector2
# Movement variables
var can_double_jump: = false
var can_triple_jump: = false
var idle_direction: = RIGHT
var down_speed: = DOWN * 5.0
# Attack variables
export var attack_range: = 100.0
var attack_cooldown_time: = 1000.0
var next_attack_time: = 0.0
var light_attack_dmg: = 300.0
var heavy_attack_dmg: = 1000.0
var knockback: = Vector2.ZERO
# Damage management
export var damage_multiplier: = 0.0
var break_point: = 10
# Multiple players
export var id: = 0

func _ready():
	tilemap = get_parent().get_node("TileMap")


func _physics_process(delta):
	#var is_jump_interrupted: = Input.is_action_just_released('jump_%s' % id) and _velocity.y < 0.0
	var is_jump_interrupted: = false
	var direction: = get_direction()
	if direction.x != 0:
		idle_direction = direction.x

	# Flipping a KinematicBody2D is not officially supported.
	# See: https://github.com/godotengine/godot/issues/12335#issuecomment-364775924 for a workaround
	if idle_direction == RIGHT and scale != Vector2(1, 1):
		#apply_scale(Vector2(1, 1))
		set_global_transform(Transform2D(Vector2(1,0),Vector2(0,1),Vector2(position.x,position.y)))
	elif idle_direction == LEFT and scale != Vector2(-1, 1):
		#apply_scale(Vector2(-1, 1))
		set_global_transform(Transform2D(Vector2(-1,0),Vector2(0,1),Vector2(position.x,position.y)))

	_velocity = calculate_move_velocity(_velocity, speed, direction, is_jump_interrupted)
	attack(idle_direction)
	if knockback != Vector2.ZERO:
		_velocity += knockback
		knockback = lerp(knockback, Vector2.ZERO, 0.1)
		for i in get_slide_count():
			var collision: = get_slide_collision(i)
			if collision.collider.name == "TileMap" and knockback.length() > 100:
				cell = tilemap.world_to_map(collision.position - collision.normal)
				tilemap.set_cellv(cell, -1)

	_velocity = move_and_slide(_velocity, FLOOR_NORMAL)


func get_direction() -> Vector2:
	var jump_val: = 1.0
	if Input.is_action_just_pressed('jump_%s' % id):
		if is_on_floor() or is_on_wall():
			can_double_jump = true
			can_triple_jump = true
			jump_val = -1.0
		else:
			if can_double_jump:
				can_double_jump = false
				can_triple_jump = true
				jump_val = -1.0
			elif can_triple_jump:
				can_triple_jump = false
				jump_val = -1.0

	return Vector2(
		Input.get_action_strength('move_right_%s' % id) - Input.get_action_strength('move_left_%s' % id),
		jump_val + Input.get_action_strength('down_%s' % id) * down_speed
	)


func calculate_move_velocity(
		linear_velocity: Vector2,
		speed: Vector2,
		direction: Vector2,
		is_jump_interrupted: bool
	) -> Vector2:
	var out: = linear_velocity
	out.x = speed.x * direction.x
	out.y += gravity * get_physics_process_delta_time() * direction.y

	if direction.y == UP:
		out.y = speed.y * direction.y
	if is_jump_interrupted:
		out.y = 0

	return out


func attack(direction: float) -> Vector2:
	# Turn the weapon toward movement direction
	var attack_dir: = Vector2(direction, 0)
	var attack_side: = Vector2(direction, 0).normalized()
	#$WeaponDefault.transform(position) = attack_dir.normalized() * attack_range
	#if Input.is_action_just_pressed('attack_light_%s' % id) or Input.is_action_just_pressed('attack_heavy_%s' % id):
	#	var target = $RayCast2D.get_collider()
	#	if target != null:
	#		var dmg: = light_attack_dmg if Input.is_action_just_pressed('attack_light_%s' % id) else heavy_attack_dmg
	#		return target.hit(dmg, attack_side)

	return Vector2.ZERO


func hit(damage: float, side: Vector2):
	damage_multiplier += damage
	# We send the player slightly up if they are hit while being on the floor
	knockback = side * damage_multiplier if !is_on_floor() else Vector2(side.x * damage_multiplier, -55)
	print_debug(knockback)


func take_damage(damage: float) -> void:
	damage_multiplier += damage
	print_debug(damage)
	# We send the player slightly up if they are hit while being on the floor
	#knockback = side * damage_multiplier if !is_on_floor() else Vector2(side.x * damage_multiplier, -55)
	#print_debug(knockback)
