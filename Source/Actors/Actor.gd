extends KinematicBody2D
class_name Actor

const FLOOR_NORMAL: = Vector2.UP
const RIGHT: = 1
const LEFT: = -1
const UP: = -1
const DOWN: = 1

export var speed: = Vector2(300.0, 1000.0)
export var gravity: = 10000.0
export var friction: = 1500.0
var _velocity: = Vector2.ZERO
