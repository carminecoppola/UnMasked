extends StaticBody2D

var giocatore_vicino = false
var aperta = false
var posizione_chiusa : Vector2
# Sposta la porta di 100 pixel a destra (o cambia i numeri come vuoi tu)
var spostamento = Vector2(100, 0) 

func _ready():
	posizione_chiusa = position
	# Collegamento automatico
	if has_node("Area2D"):
		$Area2D.body_entered.connect(_on_area_entered)
		$Area2D.body_exited.connect(_on_area_exited)

func _process(delta):
	# Se premi E, la porta si apre
	if giocatore_vicino and Input.is_action_just_pressed("interact"):
		apri_chiudi()

func apri_chiudi():
	var tween = create_tween()
	if aperta:
		# Chiudi
		tween.tween_property(self, "position", posizione_chiusa, 0.5)
		aperta = false
	else:
		# Apri
		tween.tween_property(self, "position", posizione_chiusa + spostamento, 0.5)
		aperta = true

# --- SEGNALI ---
func _on_area_entered(body):
	if body.name == "Player":
		giocatore_vicino = true

func _on_area_exited(body):
	if body.name == "Player":
		giocatore_vicino = false
