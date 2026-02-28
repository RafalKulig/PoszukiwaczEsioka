extends CharacterBody2D

@onready var shape_cast_up: ShapeCast2D = $ShapeCast2D
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var death_sound: AudioStreamPlayer2D = $DeathSound
@onready var hit_sound: AudioStreamPlayer2D = $HitSound

const SPEED = 50.0

var direction = 1
var is_dead = false
var lifes = 2
var is_hit = false

func move(delta: float):
	if is_dead or is_hit:
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if ray_cast_left.is_colliding():
		direction = 1
	elif ray_cast_right.is_colliding():
		direction = -1
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	move_and_slide()

func animations():
	if direction == 1:
		animated_sprite_2d.flip_h = false
	elif direction == -1:
		animated_sprite_2d.flip_h = true
		
	if not is_hit and not is_dead:
		animated_sprite_2d.play("default")

func death():
	if is_dead:
		return
		
	is_dead = true
	death_sound.play()
	animated_sprite_2d.play("death")
	hitbox.monitoring = false

func hit():
	if is_hit:
		return
		
	is_hit = true	
	lifes -= 1
	if lifes <= 0:
		death()
	else:
		hit_sound.play()
		animated_sprite_2d.play("hit")
	

func _physics_process(delta: float) -> void:
	move(delta)
	animations()
	
	if shape_cast_up.is_colliding() and not is_dead:
		death()
		


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.hit()
		direction *= -1

func _on_animated_sprite_2d_animation_finished() -> void:
	if is_dead:
		queue_free()
		
	if is_hit:
		is_hit = false
