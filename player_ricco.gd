extends CharacterBody2D

@export var speed = 300.0
@export var jump_force = -500.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var anim = $AnimUomoRicco  # Questo è AnimatedSprite2D

func _ready():
	if Global.player_id == "":
		$NomeUomoRicco.text = "UomoRicco"
	else:
		$NomeUomoRicco.text = Global.player_id
	
	$NomeUomoRicco.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER


func _physics_process(delta):
	# 1. GRAVITÀ
	if not is_on_floor():
		velocity.y += gravity * delta

	# 2. SALTO
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force

	# 3. MOVIMENTO ORIZZONTALE
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()


	if direction != 0:
		# Specchia sprite quando vai a sinistra
		anim.flip_h = direction < 0
		
		# Avvia camminata se non è già attiva
		if anim.animation != "walk_uomo_ricco":
			anim.play("walk_uomo_ricco")
	else:
		# Se fermo → idle (se esiste)
		if anim.sprite_frames and anim.sprite_frames.has_animation("idle_ricchione"):
			if anim.animation != "idle_ricchione":
				anim.play("idle_ricchione")
		else:
			anim.stop()
			anim.frame = 0
