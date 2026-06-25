extends Node

@export var hover_sound: AudioStream

var audio_player: AudioStreamPlayer

func _ready():
	# Create Audio Player
	audio_player = AudioStreamPlayer.new()
	audio_player.bus = "SFX"
	audio_player.volume_db = -5
	add_child(audio_player)
	
	# Find all buttons in the scene and connect the signal
	await get_tree().process_frame
	_connect_all_buttons(get_tree().current_scene)
	
func _connect_all_buttons(node: Node):
	for child in node.get_children():
		if child is Button:
			child.mouse_entered.connect(_on_hover)
		_connect_all_buttons(child)
		
func _on_hover():
	if hover_sound and audio_player:
		audio_player.stream = hover_sound
		audio_player.play()
