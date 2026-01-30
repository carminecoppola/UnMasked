extends Node2D

signal monologue_finished

@export var tasto_interazione := "interact"
@export var vignette: Array[Texture2D] = []          # es: 6 immagini
@export var side := "right"                          # "right" per narratrice
@export var one_shot := true                         # parla una volta sola

var player_in_range := false
var started := false

@onready var hint: Label = get_node_or_null("Visual/Label") # opzionale
@onready var area: Area2D = $Area2D

var layer: VignetteLayer


func _ready() -> void:
	if hint:
		hint.visible = false

	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)


func _process(_delta: float) -> void:
	if started and one_shot:
		return

	if player_in_range and Input.is_action_just_pressed(tasto_interazione):
		_start_monologue()


func _start_monologue() -> void:
	layer = get_tree().current_scene.get_node_or_null("VignetteLayer") as VignetteLayer
	if layer == null:
		push_error("VignetteLayer non trovato nella scena corrente!")
		return

	if vignette.is_empty():
		push_error("narratrice_monologo: array 'vignette' vuoto!")
		emit_signal("monologue_finished")
		return

	# evita doppi connect
	if not layer.is_connected("dialogue_finished", Callable(self, "_on_dialogue_finished")):
		layer.connect("dialogue_finished", Callable(self, "_on_dialogue_finished"))

	var seq: Array[VignetteLayer.Vignetta] = []
	for tex in vignette:
		if tex:
			seq.append(VignetteLayer.Vignetta.new(tex, side))

	layer.choice_at_index = -1  # ✅ nessuna scelta
	layer.vignette = seq

	started = true
	if hint:
		hint.visible = false

	layer.start()


func _on_dialogue_finished() -> void:
	emit_signal("monologue_finished")
	if one_shot:
		queue_free()


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and (not started or not one_shot):
		player_in_range = true
		if hint:
			hint.visible = true
			hint.text = "Premi E per interagire"


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		if hint:
			hint.visible = false
