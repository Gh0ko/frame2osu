extends Panel

@onready var Dialog = $FileButton/FileDialog
@onready var Output = $OutputButton/OutputDialogue
@onready var popup = $AcceptDialog
@onready var streamplayer = $VideoStreamPlayer
@onready var textedit = $Filename
var exportpath : String 
var filename : String 
var inputfile : String
var outputfile : String
var frames : Array = []

func _ready():
	Dialog.access = FileDialog.ACCESS_FILESYSTEM
	Dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	Dialog.filters = ["*.gif","*.mp4","*.avi","*.flv", "*.mov"]
	Dialog.connect("file_selected", Callable(self, "_on_file_selected"))
	
func _input(event):
	if textedit.has_focus():
		if event is InputEventKey and event.is_pressed():
			if event.key_label == KEY_SPACE or event.key_label == KEY_ENTER:
				get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	if streamplayer.is_playing():
		var tex = streamplayer.get_video_texture()
		if tex:
			var img = tex.get_image()
			if img and not img.is_empty():
				frames.append(img.duplicate())


func _on_file_dialog_file_selected(path: String) -> void:
	frames = []
	inputfile = path
	$FileLabel.text = inputfile
	outputfile = path.get_basename() + ".ogv"
	if !FileAccess.file_exists(outputfile):
		push_error("No se pudo convertir el archivo.")

func convert_gif_to_ogv(input_path: String, output_path: String):
	var ffmpeg_path = get_ffmpeg_path()
	var args = [
		"-y",
		"-i", input_path,
		"-c:v", "libtheora",
		"-q:v", "7",
		output_path
	]

	var result = OS.execute(ffmpeg_path, args,[], false)
	if result != 0:
		push_error("Error ejecutando FFmpeg (código " + str(result) + ")")

func get_ffmpeg_path() -> String:
	var os_name = OS.get_name()

	match os_name:
		"Windows":
			return ProjectSettings.globalize_path("res://bin/ffmpeg.exe")
		"Linux", "macOS":
			return ProjectSettings.globalize_path("res://bin/ffmpeg")  # Si querés agregar builds para esos SO también
		_:
			push_error("Sistema operativo no soportado")
			return ""

func _on_button_pressed() -> void:
	Dialog.popup_centered()



func _on_button_2_pressed() -> void:
	print(inputfile)
	print(outputfile)
	convert_gif_to_ogv(inputfile, outputfile)
	if FileAccess.file_exists(outputfile):
		streamplayer.stream = VideoStreamTheora.new()
		streamplayer.stream = load(outputfile)
		streamplayer.play()


func _on_output_button_pressed() -> void:
	Output.popup_centered()



func _on_output_dialogue_dir_selected(dir: String) -> void:
	exportpath = dir
	$OutputLabel.text = dir


func _on_filename_text_changed() -> void:
	filename = textedit.text


func _on_video_stream_player_finished() -> void:
	for x in frames.size():
		var texture = frames[x]
		if exportpath and filename:
			texture.save_png(exportpath + "/"+ filename + "-" + str(x)+ ".png")
		else:
			popup.title = "Error"
			popup.dialog_text = "You haven't specified an output path or filename"
			popup.ok_button_text = "Close"
			popup.popup_centered()
	
