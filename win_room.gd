extends Node2D

# 6 vignette SOLO narratrice a destra
@export var narratrice_vignette: Array[Texture2D] = []

@onready var player_static: Node = $PlayerStatic
@onready var narratrice_static: Node = $NarratriceStatic
@onready var victory_image: TextureRect = $VictoryImage
@onready var layer: VignetteLayer = $VignetteLayer


func _ready() -> void:
	# stato iniziale
	victory_image.visible = false

	# collega fine dialogo
	if not layer.is_connected("dialogue_finished", Callable(self, "_on_dialogue_finished")):
		layer.connect("dialogue_finished", Callable(self, "_on_dialogue_finished"))

	_start_dialogue()


func _start_dialogue() -> void:
	if narratrice_vignette.is_empty():
		push_error("win-scene: narratrice_vignette è vuoto. Metti 6 PNG in Inspector.")
		_on_dialogue_finished() # fallback: mostra vittoria comunque
		return

	var seq: Array[VignetteLayer.Vignetta] = []
	for tex in narratrice_vignette:
		if tex:
			seq.append(VignetteLayer.Vignetta.new(tex, "right"))

	layer.choice_at_index = -1
	layer.vignette = seq
	layer.start()


func _on_dialogue_finished() -> void:
	# spariscono player e narratrice
	if is_instance_valid(player_static):
		player_static.queue_free()
	if is_instance_valid(narratrice_static):
		narratrice_static.queue_free()

	_show_victory()


func _show_victory() -> void:
	victory_image.visible = true
	victory_image.modulate.a = 0.0   # parte trasparente

	var tween := create_tween()
	tween.tween_property(victory_image, "modulate:a", 1.0, 2.0) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)
