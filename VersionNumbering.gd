@tool
extends Label

@export var _versionNumber: String

func _ready():
	if !Engine.is_editor_hint():
		text = _versionNumber
		print("Welcome to Digidestined Auto Patcher %. \nWhen submitting a bug report, be sure to include a link to the mod causing the problem, as well as a screenshot of the error displayed in console" %_versionNumber)
		set_script(null)

func _process(delta):
	if Engine.is_editor_hint():
		var exportConfig = ConfigFile.new()
		var export_config_path = "res://export_presets.cfg"
		var config_error = exportConfig.load(export_config_path)
		var versionNumber: String = exportConfig.get_value("preset.0.options", "application/product_version", "dynamic product version").trim_suffix(".0.0")
		text = "Ver.%s" % versionNumber
		_versionNumber = "Ver.%s" % versionNumber
