extends Area2D

@onready var sound_explosion: AudioStreamPlayer2D = $SoundExplosion


func _on_body_entered(body: Node2D) -> void:
	sound_explosion.play()
	body.dead()
	
