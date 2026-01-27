extends Area2D

# Scegli qui il livello 2 dall'Inspector
@export_file("*.tscn") var livello_successivo

func _ready():
	# Colleghiamo il segnale "body_entered" a questo script
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Se chi entra è il Player...
	if body.name == "Player":
		print("Cambio livello!")
		call_deferred("cambia_scena")

func cambia_scena():
	if livello_successivo:
		get_tree().change_scene_to_file(livello_successivo)
	else:
		print("ERRORE: Non hai impostato il livello successivo nell'Inspector dell'Uscita!")
