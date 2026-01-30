extends StaticBody2D

var giocatore_vicino = false
var aperta = false
var posizione_chiusa : Vector2
var spostamento = Vector2(100, 0) 

func _ready():
	posizione_chiusa = position
	if has_node("Area2D"):
		$Area2D.body_entered.connect(_on_area_entered)
		$Area2D.body_exited.connect(_on_area_exited)

func _process(delta):
	if giocatore_vicino and Input.is_action_just_pressed("interact"):
		apri_chiudi()

func apri_chiudi():
	var tween = create_tween()
	if aperta:
		tween.tween_property(self, "position", posizione_chiusa, 0.5)
		aperta = false
	else:
		tween.tween_property(self, "position", posizione_chiusa + spostamento, 0.5)
		aperta = true

func _on_area_entered(body):
	# CORREZIONE QUI SOTTO:
	if body.name == "UomoRicco": 
		print("Ciao UomoRicco!") # Debug
		giocatore_vicino = true

func _on_area_exited(body):
	# E ANCHE QUI SOTTO:
	if body.name == "UomoRicco":
		giocatore_vicino = false
