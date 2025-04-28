extends Panel

@onready var Dialog = $MarginContainer/HSplitContainer/l/VBoxContainer/MarginContainer/VBoxContainer2/ScrollContainer/VBoxContainer/input/FileButton/FileDialog
@onready var Output = $MarginContainer/HSplitContainer/l/VBoxContainer/MarginContainer/VBoxContainer2/ScrollContainer/VBoxContainer/output/OutputButton/OutputDialogue
@onready var popup = $AcceptDialog
@onready var streamplayer = $VideoStreamPlayer
@onready var textedit = $MarginContainer/HSplitContainer/l/VBoxContainer/MarginContainer/VBoxContainer2/ScrollContainer/VBoxContainer/VBoxContainer/Filename
@onready var filelabel = $MarginContainer/HSplitContainer/l/VBoxContainer/MarginContainer/VBoxContainer2/ScrollContainer/VBoxContainer/input/ColorRect/MarginContainer/FileLabel
@onready var output_label: Label = $MarginContainer/HSplitContainer/l/VBoxContainer/MarginContainer/VBoxContainer2/ScrollContainer/VBoxContainer/output/ColorRect/MarginContainer/OutputLabel

var exportpath : String 
var filename : String = "mania-stage-bottom"
var inputfile : String
var outputfile : String
var framerate : String
var stage_side : int = 1
var stage_bottom : bool = false

func _ready():
	print("hola")
	Dialog.access = FileDialog.ACCESS_FILESYSTEM
	Dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	Dialog.filters = ["*.gif","*.mp4","*.avi","*.flv", "*.mov"]
	Dialog.connect("file_selected", Callable(self, "_on_file_selected"))
	
func _input(event):
	if textedit.has_focus():
		if event is InputEventKey and event.is_pressed():
			if event.key_label == KEY_SPACE or event.key_label == KEY_ENTER:
				get_viewport().set_input_as_handled()


func _on_file_dialog_file_selected(path: String) -> void:
	inputfile = path
	filelabel.text = inputfile

func convert_gif_to_ogv(input_path: String, output_path: String):
	var ffmpeg_path = get_ffmpeg_path()
	var padding = get_padding()
	var args = [
		"-r", "1",
		"-i", input_path,
		"-vf", padding,
		"-r", framerate,
		"-start_number", 0,
		output_path
	]
	var result = OS.execute(ffmpeg_path, args,[], false)
	if result != 0:
		push_error("Error ejecutando FFmpeg (código " + str(result) + ")")

func get_padding():
	if stage_bottom:
		if stage_side == 0:
			return "pad=width=iw+620:height=ih+200:x=0:y=200:color=0x00000000"
		else:
			return "pad=width=iw+620:height=ih+200:x=620:y=200:color=0x00000000"
	else:
		return "pad=width=iw:height=ih:x=0:y=0"

func get_ffmpeg_path() -> String:
	var os_name = OS.get_name()
	var executable = OS.get_executable_path() 
	match os_name:
		"Windows":
			return ProjectSettings.globalize_path(executable.get_base_dir()+"/ffmpeg.exe")
		"Linux", "macOS":
			return ProjectSettings.globalize_path(executable.get_base_dir()+"/ffmpeg") 
		_:
			push_error("Sistema operativo no soportado")
			return ""

func _on_convert_button_pressed() -> void:
	if !inputfile:
		popup.title = "Error"
		popup.dialog_text = "You haven't specified a file to convert"
		popup.ok_button_text = "Close"
		popup.popup_centered()
	if !exportpath:
		popup.title = "Error"
		popup.dialog_text = "You haven't specified an output path"
		popup.ok_button_text = "Close"
		popup.popup_centered()
	elif !filename:
		popup.title = "Error"
		popup.dialog_text = "You haven't specified a filename"
		popup.ok_button_text = "Close"
		popup.popup_centered()
	elif !framerate:
		popup.title = "Error"
		popup.dialog_text = "You haven't specified a framerate"
		popup.ok_button_text = "Close"
		popup.popup_centered()
	else:
		outputfile = exportpath + "/" + filename + "-%d.png"
		print(inputfile)
		print(outputfile)
		convert_gif_to_ogv(inputfile, outputfile)
		
func _on_button_pressed() -> void:
	Dialog.popup_centered()
func _on_output_button_pressed() -> void:
	Output.popup_centered()
func _on_output_dialogue_dir_selected(dir: String) -> void:
	exportpath = dir
	output_label.text = dir
func _on_filename_text_changed() -> void:
	filename = textedit.text
func _on_frameratebox_value_changed(value: float) -> void:
	framerate = str(value)
func _on_stageoptions_item_selected(index: int) -> void:
	stage_side = index
func _on_check_button_toggled(toggled_on: bool) -> void:
	stage_bottom = toggled_on
	if toggled_on:
		$MarginContainer/HSplitContainer/l/VBoxContainer/MarginContainer/VBoxContainer2/ScrollContainer/VBoxContainer/stageside/Stageoptions.disabled = false
	else:
		$MarginContainer/HSplitContainer/l/VBoxContainer/MarginContainer/VBoxContainer2/ScrollContainer/VBoxContainer/stageside/Stageoptions.disabled = true
