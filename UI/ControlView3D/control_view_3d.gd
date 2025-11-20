@tool

class_name ControlView3D extends Node3D

@onready var viewport := $Sprite3D/SubViewport as SubViewport

func _ready() -> void:
	# Set the viewport resolution to whatever the game viewport is set to.
	viewport.size = Vector2i(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height"),
	)

	# If any of our children are Control nodes, move them into the viewport. Since
	# we've setup the viewport to only ever have one child control, the last one
	# takes precedence.
	for child in get_children():
		if child is Control:
			move_child_control_to_viewport(child)

	# Listen for new child nodes entering the tree.
	child_entered_tree.connect(_on_child_added)


# If a child node is added and it is a Control node, move it to the viewport.
func _on_child_added(node: Node) -> void:
	if node is Control:
		move_child_control_to_viewport(node)

# Move a child node from the ControlView3D into the viewport. Behaves differently
# depending on whether it's running in the editor or not.
func move_child_control_to_viewport(node: Control) -> void:
	# Remove other children of viewport first.
	for child in viewport.get_children():
		viewport.remove_child(child)
		child.queue_free()

	if Engine.is_editor_hint():
		# Duplicate the node if we are running as an editor tool since trying to
		# move it crashes the editor...
		viewport.add_child(node.duplicate())
	else:
		# Otherwise, just move the node to the viewport.
		remove_child(node)
		viewport.add_child(node)
