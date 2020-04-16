extends ImmediateGeometry

var m = SpatialMaterial.new()

func _ready():
# 	Called when the node enters the scene tree for the first time.
	m.flags_unshaded = true
	m.flags_use_point_size = true
	m.albedo_color = Color.white

func draw_path(path):
	set_material_override(m)
	clear()
	
	begin(Mesh.PRIMITIVE_LINE_STRIP, null)
	
	for x in path:
		add_vertex(x)
	end()
