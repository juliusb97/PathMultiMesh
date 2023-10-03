@tool
extends Node3D

@export var m: Mesh

@onready var path = get_node("Path3D")
@onready var path_follow = get_node("Path3D/PathFollow3D")
@onready var curve = path.curve
@onready var multimesh_instance = get_node("MultiMeshInstance3D")

var curve_changed = false
var count = 0
var curve_length = 0

var mm : MultiMesh

func _ready():
	pass

func calculate_curve_array():
	if Engine.is_editor_hint(): # only run in engine
		# ensure path_follow is at origin of curve
		path_follow.position = Vector3.ZERO
		path_follow.h_offset = 0
		path_follow.v_offset = 0
		
		var size = (m as Mesh).get_aabb().size.z
		curve_length = curve.get_baked_length()
		count = floor(curve_length/size) + 1
		
		# set up MultiMesh
		mm = MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_3D
		# TODO: this is probably not necessary since Godot 4
		# mm.color_format = MultiMesh.COLOR_8BIT
		mm.mesh = m
		mm.instance_count = count
		
		# follow along path and set MultiMesh Transforms accordingly
		for i in range(0, count):
			path_follow.progress_ratio = (i + 0.5) / count
			var pf_t = path_follow.transform
			var t = Transform3D(pf_t)
			mm.set_instance_transform(i, pf_t)
			
		multimesh_instance.multimesh = mm
	
func _process(delta):
	if Engine.is_editor_hint():
		if curve_changed:
			calculate_curve_array()
		curve_changed = false

# detect change in curve to only recalculate if something was actually changed
func _on_Path_curve_changed():
	if Engine.is_editor_hint():
		curve_changed = true 
