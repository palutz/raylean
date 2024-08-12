import Raylib.Types

namespace Collision

-- detect if there is a collision between two rectangles
def detect(rect1: Rectangle) (rect2: Rectangle): Bool :=
  rect1.x < rect2.x + rect2.width &&
  rect1.x + rect1.width > rect2.x &&
  rect1.y < rect2.y + rect2.height &&
  rect1.y + rect1.height > rect2.y

def detects {EntityID: Type} (entities: List (EntityID × Rectangle)): Id (List (EntityID × EntityID)) := do
  let mut collisions := #[]
  for src in entities do
    for dst in entities do
      if detect src.2 dst.2 then
        collisions := collisions.push (src.1, dst.1)
  return collisions.toList

end Collision
