extends CharacterBody2D

func _ready() -> void:
	velocity = Vector2.ZERO

func _physics_process(_delta: float) -> void:
	# niente gravità, niente movimento in questa scena
	velocity = Vector2.ZERO
