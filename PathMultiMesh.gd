tool
extends Spatial

export(Mesh) var m

onready var path = get_node("Path")
onready var path_follow = get_node("Path/PathFollow")
onready var curve = path.curve
onready var multimesh_instance = get_node("MultiMeshInstance")

var curve_changed = false
var count = 0
var curve_length = 0

var mm : MultiMesh

func _ready():
	if Engine.editor_hint:
		var size = (m as Mesh).get_aabb().size.z
		curve_length = curve.get_baked_length()
		count = floor(curve_length/size) + 1
		
		mm = MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_3D
		mm.color_format = MultiMesh.COLOR_8BIT
		mm.mesh = m
		mm.instance_count = count
		
		for i in range(0, count):
			path_follow.unit_offset = i/count
			var pf_t = path_follow.transform
			var t = Transform(pf_t.basis, pf_t.origin)
			mm.set_instance_transform(i, pf_t)
			
		multimesh_instance.multimesh = mm
	
func _process(delta):
	if Engine.editor_hint:
		if curve_changed:
			_ready()
		curve_changed = false

func _on_Path_curve_changed():
	if Engine.editor_hint:
		curve_changed = true
