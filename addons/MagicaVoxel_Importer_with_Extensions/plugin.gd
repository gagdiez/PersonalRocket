@tool
extends EditorPlugin

var pluginToMesh
var pluginToMeshLibrary

func _enter_tree():
	pluginToMesh = preload('vox-importer-mesh.gd').new()
	pluginToMeshLibrary = preload('vox-importer-meshLibrary.gd').new()
	add_import_plugin(pluginToMesh)
	add_import_plugin(pluginToMeshLibrary)
	add_custom_type("FramedMeshInstance", "MeshInstance3D",
			preload("framed_mesh_instance.gd"), preload("framed_mesh_instance.png"))

func _exit_tree():
	remove_import_plugin(pluginToMesh)
	remove_import_plugin(pluginToMeshLibrary)
	pluginToMesh = null
	pluginToMeshLibrary = null
	remove_custom_type("FramedMeshInstance")

func _get_priority() -> float:
	return 1.0
