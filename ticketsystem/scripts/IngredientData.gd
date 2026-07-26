extends Resource

class_name IngredientData

const MAX_COOK_VALUE: float = 150

enum COOK { RAW, BAKED, FRIED, MICROWAVED, TOASTED, NA }
enum DONENESS { RAW, RARE, MEDIUMRARE, MEDIUM, WELLDONE, BURNT, NA }
enum PREP { CHOPPED, SUNNYSIDEUP, NA }

@export_group("Meta")
@export var name: String
@export var image: Image
@export var mesh: Mesh

@export_group("Cooking")
@export_subgroup("Style")
@export var cook: Array[COOK]
@export var doneness: Array[DONENESS] = [DONENESS.RAW, DONENESS.WELLDONE]
@export var prep: Array[PREP]
@export_subgroup("CookLevel")
@export var cook_scale: float = 1
#@export var doneness_intervals: Array[float] = [50.0]
@export var cooked_colour: Color = Color.BLACK

@export_group("Specifics")
@export var bounding_box_size: Vector3 = Vector3.ONE
@export var flipped_position: Vector3
@export var laying_position: Vector3
@export var laying_rotation_degrees: Vector3
