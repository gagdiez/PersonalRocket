var properties = null;
var material: StandardMaterial3D = null;

var type:
	get:
		return properties.get("_type", "diffuse");

var weight:
	get:
		return float(properties.get("_weight", 0));

var specular:
	get:
		return float(properties.get("spec"));

var roughness:
	get:
		return float(properties.get("rough"));

var flux:
	get:
		return float(properties.get("flux"));

var refraction:
	get:
		return float(properties.get("ior"));

func _init(properties):
	self.properties = properties;

func is_glass():
	return self.type == "_glass";

func get_material(color: Color):
	if (material != null): return material;
	
	material = StandardMaterial3D.new();
	material.vertex_color_is_srgb = true;
	material.vertex_color_use_as_albedo = true;
	
	match (self.type):
		"_metal":
			material.metallic = self.weight;
			material.metallic_specular = self.specular;
			material.roughness = self.roughness;
		"_emit":
			material.emission_enabled = true;
			material.emission = Color(color.r, color.g, color.b, self.weight);
			material.emission_energy = self.flux;
		"_glass":
			material.flags_transparent = true;
			material.albedo_color = Color(1, 1, 1, 1 - self.weight);
			material.refraction_enabled = true;
			material.refraction_scale = self.refraction * 0.01;
			material.roughness = self.roughness;
		"_diffuse", _:
			material.roughness = 1;
	return material;
