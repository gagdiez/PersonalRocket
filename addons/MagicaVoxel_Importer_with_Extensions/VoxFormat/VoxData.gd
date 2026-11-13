const Model = preload("./Model.gd");

var models = {0: Model.new()};
var current_index = -1;
var colors: Array;
var nodes = {};
var materials = {};
var layers = {};

func get_model():
	if (!models.has(current_index)):
		models[current_index] = Model.new();
	return models[current_index];
