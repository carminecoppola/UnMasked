class_name VignetteLayer
extends CanvasLayer

@export var fade_time := 0.25  # durata dissolvenza
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


func _ready():
	hide()
	left_rect.hide()
	right_rect.hide()
	left_rect.modulate.a = 1.0
	right_rect.modulate.a = 1.0



func start():
	if vignette.is_empty():
		return

	index = 0
	attivo = true
	Global.in_dialogue = true
	show()
	_show(vignette[index])


func _unhandled_input(event):
	if not attivo:
		return

	# ✅ Se siamo in modalità scelta, SPACE non fa niente, ascoltiamo 1/2/3 subito
	if awaiting_choice:
		if event is InputEventKey and event.pressed and not event.echo:
			match event.keycode:
				KEY_1, KEY_KP_1: _pick(1)
				KEY_2, KEY_KP_2: _pick(2)
				KEY_3, KEY_KP_3: _pick(3)

		get_viewport().set_input_as_handled()
		return

	# avanti con space
	if event.is_action_pressed(advance_action):
		get_viewport().set_input_as_handled()
		_next()


func _pick(n: int):
	awaiting_choice = false
	emit_signal("choice_selected", n)


func _next():
	index += 1
	if index >= vignette.size():
		finish()
	else:
		_show(vignette[index])


func _show(v: Vignetta):
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

	# FADE IN
	tween.tween_property(rect_to_use, "modulate:a", 1.0, fade_time)

	awaiting_choice = (index == choice_at_index)


func finish():
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


func _hide_all():
	hide()
	left_rect.hide()
	right_rect.hide()
	left_rect.modulate.a = 1.0
	right_rect.modulate.a = 1.0
