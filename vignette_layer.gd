class_name VignetteLayer
extends CanvasLayer

# =======================
#  ANCHOR SOPRA LA TESTA
# =======================
@export var left_anchor: NodePath
@export var right_anchor: NodePath
@export var left_offset := Vector2(0, -80)
@export var right_offset := Vector2(0, -80)

@export var center_on_anchor := true # se true, centra la vignetta sull'anchor (consigliato)

var _left_anchor_node: Node2D
var _right_anchor_node: Node2D


# =======================
#  DIALOG SYSTEM
# =======================
@export var fade_time := 0.25
var tween: Tween

signal dialogue_finished
signal choice_selected(choice_number: int) # 1,2,3

@export var advance_action := "next_vignetta"

@onready var left_rect: TextureRect = $VignettaLeft
@onready var right_rect: TextureRect = $VignettaRight

class Vignetta:
	var texture: Texture2D
	var side: String   # "left" o "right"
	func _init(t: Texture2D, s: String):
		texture = t
		side = s

var vignette: Array[Vignetta] = []
var index := 0
var attivo := false

# scelta
var choice_at_index := -1
var awaiting_choice := false


func _ready() -> void:
	hide()
	left_rect.hide()
	right_rect.hide()
	left_rect.modulate.a = 1.0
	right_rect.modulate.a = 1.0

	_resolve_anchors()


func _process(_delta: float) -> void:
	# aggiorna posizione solo quando serve
	if attivo:
		_update_bubble_positions()


func _resolve_anchors() -> void:
	_left_anchor_node = null
	_right_anchor_node = null

	if left_anchor != NodePath("") and has_node(left_anchor):
		_left_anchor_node = get_node(left_anchor) as Node2D
	if right_anchor != NodePath("") and has_node(right_anchor):
		_right_anchor_node = get_node(right_anchor) as Node2D


func _world_to_canvas(p_world: Vector2) -> Vector2:
	# Con CanvasLayer: convertiamo il punto mondo in coordinate "canvas/schermo"
	# Funziona bene in 2D con camera e canvas transform del viewport
	return get_viewport().get_canvas_transform() * p_world


func _place_rect_over_anchor(rect: TextureRect, anchor: Node2D, offset: Vector2) -> void:
	if rect == null or anchor == null:
		return

	var p := _world_to_canvas(anchor.global_position) + offset

	if center_on_anchor:
		# centra orizzontalmente (e anche verticalmente se vuoi)
		# qui centriamo la vignetta sul punto -> top-left = p - size/2
		p -= rect.size * 0.5

	rect.global_position = p


func _update_bubble_positions() -> void:
	# se cambi path in inspector a runtime o istanzi dopo, riprova a risolvere
	if _left_anchor_node == null or _right_anchor_node == null:
		_resolve_anchors()

	# posiziona solo ciò che è visibile
	if left_rect.visible and is_instance_valid(_left_anchor_node):
		_place_rect_over_anchor(left_rect, _left_anchor_node, left_offset)

	if right_rect.visible and is_instance_valid(_right_anchor_node):
		_place_rect_over_anchor(right_rect, _right_anchor_node, right_offset)


func start() -> void:
	if vignette.is_empty():
		return

	index = 0
	attivo = true
	Global.in_dialogue = true
	show()
	_show(vignette[index])


func _unhandled_input(event: InputEvent) -> void:
	if not attivo:
		return

	# Se siamo in modalità scelta, SPACE non fa niente
	if awaiting_choice:
		if event is InputEventKey and event.pressed and not event.echo:
			match event.keycode:
				KEY_1, KEY_KP_1: _pick(1)
				KEY_2, KEY_KP_2: _pick(2)
				KEY_3, KEY_KP_3: _pick(3)

		get_viewport().set_input_as_handled()
		return

	# avanti con action (es. space)
	if event.is_action_pressed(advance_action):
		get_viewport().set_input_as_handled()
		_next()


func _pick(n: int) -> void:
	awaiting_choice = false
	emit_signal("choice_selected", n)


func _next() -> void:
	index += 1
	if index >= vignette.size():
		finish()
	else:
		_show(vignette[index])


func _show(v: Vignetta) -> void:
	var rect_to_use: TextureRect
	var rect_to_hide: TextureRect

	if v.side == "left":
		rect_to_use = left_rect
		rect_to_hide = right_rect
	else:
		rect_to_use = right_rect
		rect_to_hide = left_rect

	# ferma tween precedente
	if tween:
		tween.kill()

	tween = create_tween()

	# FADE OUT dell'altro lato se visibile
	if rect_to_hide.visible:
		tween.tween_property(rect_to_hide, "modulate:a", 0.0, fade_time)
		tween.tween_callback(rect_to_hide.hide)

	# prepara nuova vignetta
	rect_to_use.texture = v.texture
	rect_to_use.modulate.a = 0.0
	rect_to_use.show()

	# posiziona subito (evita un frame "sballato")
	_update_bubble_positions()

	# FADE IN
	tween.tween_property(rect_to_use, "modulate:a", 1.0, fade_time)

	awaiting_choice = (index == choice_at_index)


func finish() -> void:
	attivo = false
	awaiting_choice = false
	Global.in_dialogue = false

	if tween:
		tween.kill()

	tween = create_tween()

	if left_rect.visible:
		tween.tween_property(left_rect, "modulate:a", 0.0, fade_time)
	if right_rect.visible:
		tween.tween_property(right_rect, "modulate:a", 0.0, fade_time)

	tween.tween_callback(_hide_all)

	choice_at_index = -1
	emit_signal("dialogue_finished")


func _hide_all() -> void:
	hide()
	left_rect.hide()
	right_rect.hide()
	left_rect.modulate.a = 1.0
	right_rect.modulate.a = 1.0
