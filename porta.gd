extends StaticBody2D

# Queste due caselle appariranno a destra nell'Inspector
@export var immagine_chiusa : Texture2D
@export var immagine_aperta : Texture2D

# Riferimenti ai nodi (devono chiamarsi così nella lista a sinistra!)
@onready var sprite = $Sprite2D
@onready var muro = $CollisionShape2D

var giocatore_vicino = false
var is_aperta = false

func _ready():
	# All'inizio mette l'immagine chiusa
	if immagine_chiusa != null:
		sprite.texture = immagine_chiusa

func _process(delta):
	# Se premi E (e sei vicino)
	if giocatore_vicino and Input.is_action_just_pressed("interact"):
		cambia_stato()

func cambia_stato():
	if is_aperta:
		# --- CHIUDI ---
		sprite.texture = immagine_chiusa
		muro.set_deferred("disabled", false) # Muro SOLIDO
		is_aperta = false
	else:
		# --- APRI ---
		sprite.texture = immagine_aperta
		muro.set_deferred("disabled", true) # Muro INVISIBILE (puoi passare)
		is_aperta = true

# --- SEGNALI AREA 2D ---
# Collega questi segnali dal nodo Area2D -> Inspector -> Node -> Signals
func _on_area_2d_body_entered(body):
	if body.name == "UomoRicco" or body.name == "Player":
		giocatore_vicino = true

func _on_area_2d_body_exited(body):
	if body.name == "UomoRicco" or body.name == "Player":
		giocatore_vicino = false
