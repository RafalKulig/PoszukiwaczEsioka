extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -300.0

var is_dead = false
var lifes = 3
var dead_called = false
var hit_playing = false
var is_attacking = false
var hitbox_offset: Vector2
var direction

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sound_jump: AudioStreamPlayer2D = $SoundJump
@onready var game_over_timer: Timer = $GameOverTimer
@onready var sound_hit: AudioStreamPlayer2D = $SoundHit
@onready var grace_timer: Timer = $GraceTimer
@onready var hitbox: Area2D = $Hitbox
@onready var health_anim: AnimationPlayer = $HealthAnim
@onready var coyote_timer: Timer = $CoyoteTimer

func hit():
	if hit_playing or not grace_timer.is_stopped():
		return
		
	hit_playing = true
	grace_timer.start()
	lifes -= 1
	match lifes:
		2:
			health_anim.play("health_2")
		1:
			health_anim.play("health_1")
		0:
			health_anim.play("health_0")
	if lifes <= 0:
		sound_hit.play()
		is_dead = true
	else:
		animated_sprite.play("hit")
		sound_hit.play()
	
func move(delta: float):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if is_dead or is_attacking:
		velocity = get_gravity() * delta
		move_and_slide()
		return
		
	# Handle jump.
	if Input.is_action_just_pressed("jump") and (is_on_floor() or !coyote_timer.is_stopped()):
		velocity.y = JUMP_VELOCITY
		sound_jump.play()
		
	# Get the input direction and handle the movement/deceleration.
	direction = Input.get_axis("move_left", "move_right")	
	
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	if is_on_floor() and hit_playing == false:
		if direction == 0:
			animated_sprite.play("idle")
		else: 
			animated_sprite.play("run")
	elif hit_playing == false:
		animated_sprite.play("jump")
		
	if direction:
		velocity.x = direction * SPEED
		update_hitbox_offset()
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	var was_on_floor = is_on_floor()
	
	move_and_slide()
	
	if was_on_floor and not is_on_floor():
		coyote_timer.start()
	
func dead():
	is_dead = true
	print("dead")
	animated_sprite.play("death")
	game_over_timer.start()
	Engine.time_scale = 0.5

func attack():
	hitbox.monitoring = true
	is_attacking = true
	animated_sprite.play("attack")
	print("attack")

func update_hitbox_offset():
	var x = hitbox_offset.x
	var y = hitbox_offset.y
	
	if direction > 0:
		hitbox.position = Vector2(x, y)
	elif direction < 0:
		hitbox.position = Vector2(-x, y)

func _ready() -> void:
	hitbox_offset = hitbox.position

func _physics_process(delta: float) -> void:
	hitbox.monitoring = false
	
	move(delta)
	if Input.is_action_just_pressed("attack") and not is_attacking:
		attack()
	
	if is_dead == true and dead_called == false:
		dead()
		dead_called = true

func _on_animated_sprite_2d_animation_finished() -> void:
	if hit_playing:
		hit_playing = false
	
	if is_attacking:
		is_attacking = false

func _on_game_over_timer_timeout() -> void:
	Engine.time_scale = 1
	get_tree().reload_current_scene()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if is_attacking and body.name.begins_with("enemy"):
		body.hit()
