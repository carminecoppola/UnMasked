extends Node2D

@export var npc_dialogue_1: Texture2D      # 1) parla NPC (right)
@export var player_reply: Texture2D        # 2) parla Player (left)
@export var npc_dialogue_2: Texture2D      # 3) parla NPC (right)
@export var npc_dialogue_3: Texture2D      # 3) parla NPC (right)

@export var tasto_interazione := "interact"

var player_in_range := false
var gia_parlato := false
var stage := "main"  # main / final

@onready var hint: Label = get_node_or_null("Visual/Label")
@onready var area: Area2D = $Area2D

var layer: VignetteLayer


func _ready():
	if hint:
		hint.visible = false
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)


func _process(_delta):
	if Global.in_dialogue or gia_parlato:
		return
	if player_in_range and Input.is_action_just_pressed(tasto_interazione):
		_start_dialogo()


func _start_dialogo():
	layer = get_tree().current_scene.get_node_or_null("VignetteLayer") as VignetteLayer
	if layer == null:
		push_error("VignetteLayer non trovato!")
		return

	if not layer.is_connected("dialogue_finished", Callable(self, "_on_dialogo_finito")):
		layer.connect("dialogue_finished", Callable(self, "_on_dialogo_finito"))

	var seq: Array[VignetteLayer.Vignetta] = []

	if npc_dialogue_1:
		seq.append(VignetteLayer.Vignetta.new(npc_dialogue_1, "right"))
	if player_reply:
		seq.append(VignetteLayer.Vignetta.new(player_reply, "left"))
	if npc_dialogue_2:
		seq.append(VignetteLayer.Vignetta.new(npc_dialogue_2, "right"))
	if npc_dialogue_3:
		seq.append(VignetteLayer.Vignetta.new(npc_dialogue_3, "right"))

	if seq.is_empty():
		push_error("NPC-VIP-Complete: nessuna vignetta assegnata.")
		return

	layer.choice_at_index = -1
	layer.vignette = seq

	stage = "final"
	gia_parlato = true
	if hint:
		hint.visible = false

	layer.start()


func _on_dialogo_finito():
	if stage != "final":
		return

	# pulizia connessione
	if layer and layer.is_connected("dialogue_finished", Callable(self, "_on_dialogo_finito")):
		layer.disconnect("dialogue_finished", Callable(self, "_on_dialogo_finito"))

	queue_free()


func _on_body_entered(body):
	if body.is_in_group("player") and not gia_parlato:
		player_in_range = true
		if hint:
			hint.visible = true
			hint.text = "Premi E per interagire"


func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		if hint:
			hint.visible = false
