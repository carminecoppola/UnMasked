extends CharacterBody2D

@export var speed = 300.0
@export var jump_force = -500.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var anim = $AnimUomoRicco  # AnimatedSprite2D

func _ready():
	add_to_group("player")  # ✅ così gli NPC lo riconoscono sempre

	if Global.player_id == "":
		$NomeUomoRicco.text = "UomoRicco"
	else:
		$NomeUomoRicco.text = Global.player_id

	$NomeUomoRicco.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER


func _physics_process(delta):
	# 1) GRAVITÀ (sempre)
	if not is_on_floor():
		velocity.y += gravity * delta

	# ✅ BLOCCO INPUT durante dialoghi/vignette
	if Global.in_dialogue:
		# niente salto, niente movimento; puoi scegliere se fermarlo o lasciarlo “scivolare”
		velocity.x = move_toward(velocity.x, 0, speed)
		move_and_slide()

		# animazione idle mentre legge
		if anim.sprite_frames and anim.sprite_frames.has_animation("idle_ricchione"):
			if anim.animation != "idle_ricchione":
				anim.play("idle_ricchione")
		else:
			anim.stop()
			anim.frame = 0
		return

	# 2) SALTO (solo se non in dialogo)
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force

	# 3) MOVIMENTO
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()

	# Animazioni
	if direction != 0:
		anim.flip_h = direction < 0
		if anim.animation != "walk_uomo_ricco":
			anim.play("walk_uomo_ricco")
	else:
		if anim.sprite_frames and anim.sprite_frames.has_animation("idle_ricchione"):
			if anim.animation != "idle_ricchione":
				anim.play("idle_ricchione")
		else:
			anim.stop()
			anim.frame = 0
