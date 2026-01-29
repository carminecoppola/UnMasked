extends Node2D

signal npc_finished

@export var player_intro: Texture2D
@export var npc_intro: Texture2D
@export var npc_riddle_block: Array[Texture2D] = []   # 4 vignette, ultima = indovinello
@export var correct_key := 2
@export var npc_correct: Texture2D
@export var npc_wrong: Texture2D
@export var tasto_interazione := "interact"

var player_in_range := false
var gia_parlato := false
var stage := "main"  # main / wrong / final

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
	if not layer.is_connected("choice_selected", Callable(self, "_on_choice_selected")):
		layer.connect("choice_selected", Callable(self, "_on_choice_selected"))

	var seq: Array[VignetteLayer.Vignetta] = []

	if player_intro:
		seq.append(VignetteLayer.Vignetta.new(player_intro, "left"))
	if npc_intro:
		seq.append(VignetteLayer.Vignetta.new(npc_intro, "right"))

	for tex in npc_riddle_block:
		if tex:
			seq.append(VignetteLayer.Vignetta.new(tex, "right"))

	layer.vignette = seq
	layer.choice_at_index = seq.size() - 1

	stage = "main"
	gia_parlato = true
	if hint:
		hint.visible = false

	layer.start()


func _on_choice_selected(choice_number: int):
	var finale: Array[VignetteLayer.Vignetta] = []

	if choice_number == correct_key:
		if npc_correct:
			finale.append(VignetteLayer.Vignetta.new(npc_correct, "right"))
		stage = "final"
	else:
		if npc_wrong:
			finale.append(VignetteLayer.Vignetta.new(npc_wrong, "right"))
		stage = "wrong"

	layer.choice_at_index = -1
	layer.vignette = finale
	layer.start()


func _on_dialogo_finito():
	if stage == "wrong":
		_restart_choice()
		return

	if stage == "final":
		var vip2 = get_tree().current_scene.get_node_or_null("NPC-VIP-2")
		if vip2 and vip2.has_method("activate"):
			vip2.activate()

		emit_signal("npc_finished")
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
			
			
func _restart_choice():
	if npc_riddle_block.is_empty():
		push_error("VIP1: npc_riddle_block vuoto, non posso ripetere l'indovinello.")
		return

	var indovinello_tex: Texture2D = npc_riddle_block[npc_riddle_block.size() - 1]

	var seq: Array[VignetteLayer.Vignetta] = []
	if indovinello_tex:
		seq.append(VignetteLayer.Vignetta.new(indovinello_tex, "right"))

	layer.vignette = seq
	layer.choice_at_index = 0
	stage = "main"
	layer.start()
