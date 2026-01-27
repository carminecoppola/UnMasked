extends CanvasLayer

@export var vignette: Array[Texture2D] = []
@export var advance_action := "next_vignetta" # oppure "ui_accept"

@onready var vignetta_rect: TextureRect = $Vignetta

var index := 0
var attivo := false

func _ready():
	hide()

func start():
	if vignette.is_empty():
		return

	index = 0
	attivo = true
	show()
	vignetta_rect.texture = vignette[index]

	# blocca solo il player (se vuoi), NON tutto il gioco:
	# get_tree().paused = true  # <- per ora lasciamolo spento

func _unhandled_input(event):
	if not attivo:
		return

	if event.is_action_pressed(advance_action):
		_next()

func _next():
	index += 1
	if index >= vignette.size():
		finish()
	else:
		vignetta_rect.texture = vignette[index]

func finish():
	attivo = false
	hide()
	# get_tree().paused = false
