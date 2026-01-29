extends StaticBody2D

@export var next_scene_path: String = "res://scenes/levels/win_room.tscn"
@export var tasto_interazione := "interact"

var giocatore_vicino := false
var unlocked := false

func _ready():
	# collega segnali area
	if has_node("Area2D"):
		$Area2D.body_entered.connect(_on_area_entered)
		$Area2D.body_exited.connect(_on_area_exited)

func _process(_delta):
	# non far nulla durante dialoghi
	if Global.in_dialogue:
		return

	# premi E solo se vicino e sbloccata
	if giocatore_vicino and unlocked and Input.is_action_just_pressed(tasto_interazione):
		if Engine.has_singleton("Transizione"):
			Transizione.cambia_scena(next_scene_path)
		else:
			get_tree().change_scene_to_file(next_scene_path)
			
			

# ✅ chiamala dal tuo NPC finale per sbloccare la porta
func unlock():
	unlocked = true

# --- SEGNALI ---
func _on_area_entered(body):
	# ✅ nel livello 2 il player non si chiama "Player", quindi usiamo il group
	if body.is_in_group("player"):
		giocatore_vicino = true

func _on_area_exited(body):
	if body.is_in_group("player"):
		giocatore_vicino = false
