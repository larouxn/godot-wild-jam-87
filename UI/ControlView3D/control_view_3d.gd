@tool

class_name ControlView3D extends Node3D

@export_tool_button("Refresh Viewport", "Reload") var refresh_fn := sync_viewport

@onready var viewport := $Sprite3D/SubViewport as SubViewport


func _ready() -> void:
	# Set the viewport resolution to whatever the game viewport is set to.
	viewport.size = Vector2i(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height"),
	)

	# Sync the viewport with our child Control nodes.
	sync_viewport()

	# Listen for children entering/leaving the tree.
	child_entered_tree.connect(_on_child_added)
	child_exiting_tree.connect(_on_child_exiting)


## Get a control node from the viewport.
func get_control_node(path: NodePath) -> Control:
	if viewport != null:
		return viewport.get_node(path)
	return null


## If a child node is added and it is a Control node, sync the viewport.
func _on_child_added(node: Node) -> void:
	if node is Control:
		sync_viewport()


## If a child node is removed and it is a Control node, sync the viewport.
func _on_child_exiting(node: Node) -> void:
	if node is Control:
		# Call deferred so the exiting node will have exited the tree before syncing.
		sync_viewport.call_deferred()


## Move a child node from the ControlView3D into the viewport. Behaves differently
## depending on whether it's running in the editor or not.
func move_child_to_viewport(node: Control) -> void:
	if Engine.is_editor_hint():
		# Duplicate the node if we are running as an editor tool since we want the
		# child node to remain available in the editor to modify.
		viewport.add_child(node.duplicate())
	else:
		# Otherwise, just move the node to the viewport.
		remove_child(node)
		viewport.add_child(node)


## Remove all children from the viewport.
func clear_viewport() -> void:
	for child in viewport.get_children():
		viewport.remove_child(child)
		child.queue_free()


## Sync the viewport by clearing its children and moving our children that are
## Control nodes into the viewport.
func sync_viewport() -> void:
	clear_viewport()

	for child in get_children():
		if child is Control:
			move_child_to_viewport(child)


## Show in-editor warnings for misconfigurations.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := []

	var count := 0
	for child in get_children():
		if child is Control:
			count += 1

	if count < 1:
		warnings.append("Missing child Control. Nothing will be rendered.")

	return warnings
