tool
extends EditorPlugin

var nodeName = "talkit"
var baseNode = "Node2D"
var script = preload("talkit_code.gd")
var icon = preload("icon.png")

func _enter_tree():
    # Initialization of the plugin goes here
    # Add the new type with a name, a parent type, a script and an icon
    add_custom_type(nodeName, baseNode, script, icon)

func _exit_tree():
    # Clean-up of the plugin goes here
    # Always remember to remove it from the engine when deactivated
    remove_custom_type(nodeName)