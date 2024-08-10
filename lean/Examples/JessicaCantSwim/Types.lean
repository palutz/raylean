import Raylib.Types

namespace JessicaCantSwim.Types

structure Player where
  position : Vector2

structure GameState where
  player : Player
  camera : Camera2D

abbrev GameM : Type -> Type := StateT GameState IO

def modifyPlayer [MonadState GameState m] (f : Player → Player) : m Unit :=
  modify (fun s => { s with player := f s.player })

def modifyPosition [MonadState GameState m] (f : Vector2 → Vector2) : m Unit :=
  modifyPlayer (fun p => { p with position := f p.position })

def modifyPositionX [MonadState GameState m] (f : Float → Float) : m Unit :=
  modifyPosition (fun v => { v with x := f v.x })

def modifyPositionY [MonadState GameState m] (f : Float → Float) : m Unit :=
  modifyPosition (fun v => { v with y := f v.y })

def setPosition [MonadState GameState m] (p : Vector2) : m Unit :=
  modifyPosition (fun _ => p)

def setPositionX [MonadState GameState m] (px : Float) : m Unit :=
  modifyPositionX (fun _ => px)

def setPositionY [MonadState GameState m] (py : Float) : m Unit :=
  modifyPositionY (fun _ => py)

def modifyCamera [MonadState GameState m] (f : Camera2D -> Camera2D) : m Unit :=
  modify (fun s => { s with camera := f s.camera })

def setTarget [MonadState GameState m] (v : Vector2) : m Unit :=
  modifyCamera (fun c => { c with target := v })

end JessicaCantSwim.Types
