extends Building

func _ready():
	$CollisionShape2D.set_deferred("disabled", true)
	modulate = Color.TRANSPARENT
	%Polygon2D.color = inner_color_converted
	%Polygon2D2.color = outer_color_converted

func _on_body_entered(minion: Minion):
	if minion.resource_held and minion.army == controlled_by:
		minion.drop_resource()

func capture_building(army: Army = null):
	$CollisionShape2D.set_deferred("disabled", false)
	super(army)

func _on_area_entered(area):
	if area.get_parent() and area.get_parent() is Minion:
		_on_body_entered(area.get_parent())
