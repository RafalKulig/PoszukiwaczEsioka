extends StaticBody2D

@onready var area_2d: Area2D = $Area2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer
@onready var game_manager: Node = %GameManager

const SPEED = -100

var is_active : bool = false
var timeout : bool= false
var starting_position : int

func _ready() -> void:
	starting_position = position.y

func _physics_process(delta: float) -> void:
	if is_active == true:
		if not timeout:
			position.y += SPEED * delta
		elif timeout:
			if position.y != starting_position:
				position.y += -SPEED * delta



func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not timeout:
		is_active = true
		animation_player.play("new_animation")
		timer.start()
		game_manager.add_point()

func _on_timer_timeout() -> void:
	timeout = true
