extends Node2D

@onready var player_node: Node = get_node_or_null("PlayerNoMask")   # ✅ player vero
@onready var narratrice_node: Node = get_node_or_null("NarratriceStatic")
@onready var victory_image: TextureRect = get_node_or_null("VictoryImage")

@onready var narratrice_monologo: Node = get_node_or_null("Narratrice") # nodo con script monologo


func _ready() -> void:
	# blocca fisica e input del player in win-room
	if player_node:
		player_node.set_physics_process(false)
		player_node.set_process_input(false)
		player_node.set_process_unhandled_input(false)
	
	# vittoria inizialmente nascosta
	if victory_image:
		victory_image.visible = false
		victory_image.modulate.a = 0.0
	else:
		push_error("Manca nodo VictoryImage")

	# collega fine monologo
	if narratrice_monologo and narratrice_monologo.has_signal("monologue_finished"):
		narratrice_monologo.connect("monologue_finished", Callable(self, "_on_monologue_finished"))
	else:
		push_error("Nodo Narratrice non trovato o non ha il segnale monologue_finished.")


func _on_monologue_finished() -> void:
	# ✅ sparisce player
	await _fade_out_and_free(player_node, 0.35)

	# ✅ sparisce narratrice
	await _fade_out_and_free(narratrice_node, 0.35)

	# poi appare vittoria
	_show_victory()


func _show_victory() -> void:
	if not victory_image:
		return

	victory_image.visible = true
	victory_image.modulate.a = 0.0

	var tween := create_tween()
	tween.tween_property(victory_image, "modulate:a", 1.0, 2.0) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)


func _fade_out_and_free(n: Node, duration: float) -> void:
	if not is_instance_valid(n):
		return

	var canvas_item := n as CanvasItem
	if canvas_item:
		var t := create_tween()
		t.tween_property(canvas_item, "modulate:a", 0.0, duration) \
			.set_trans(Tween.TRANS_SINE) \
			.set_ease(Tween.EASE_IN_OUT)
		await t.finished

	n.queue_free()
