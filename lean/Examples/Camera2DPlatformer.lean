import «Raylib»

import Examples.Camera2DPlatformer.Types
open Camera2DPlatformer.Types

namespace Camera2DPlatformer

private def screenWidth : Nat := 800
private def screenHeight : Nat := 450
private def fps : Nat := 60

private def gravity : Nat := 500
private def player_jump_speed : Float := 350
private def player_horizontal_speed : Float := 200
private def player_width : Float := 40
private def player_height : Float := 40

def initPlayer : Player := { position := {x := 400, y := 200}, speed := 0, canJump := false }

def initCamera : Camera2D := {
  target := initPlayer.position,
  offset := { x := screenWidth.toFloat / 2, y := screenHeight.toFloat / 2 }
  rotation := 0,
  zoom := 1
}

def initGameState : GameState := { player := initPlayer, camera := initCamera }

def initGameEnv : GameEnv := { items := [
  { rect := {x := 0, y := 0, width := 1000, height := 400 }
    blocking := false,
    color := Color.Raylib.lightgray },
  { rect := {x := 0, y := 400, width := 1000, height := 200 }
    blocking := true,
    color := Color.Raylib.gray },
  { rect := {x := 300, y := 200, width := 400, height := 10 }
    blocking := true,
    color := Color.Raylib.gray },
  { rect := {x := 250, y := 300, width := 100, height := 10 }
    blocking := true,
    color := Color.Raylib.gray },
  { rect := {x := 650, y := 300, width := 100, height := 10 }
    blocking := true,
    color := Color.Raylib.gray },
] }

def updatePlayer (delta : Float) : GameM Unit := do
  if (← isKeyDown Key.left) then modifyPositionX (· - player_horizontal_speed * delta)
  if (← isKeyDown Key.right) then modifyPositionX (· + player_horizontal_speed * delta)
  if (← isKeyDown Key.space) && (← get).player.canJump then do
    setSpeed player_jump_speed.neg
    setCanJump false

  -- Resolve collisions with environment. Result is none if an abstacle is hit
  let resolveCollisions : OptionT GameM Unit := do
    forM (← read).items fun item => do
      let player := (← get).player
      let position := player.position
      if item.blocking
         && item.rect.x <= position.x
         && item.rect.x + item.rect.width >= position.x
         && item.rect.y >= position.y
         && item.rect.y <= position.y + (player.speed * delta) then do
           setSpeed 0
           setPositionY item.rect.y
           failure

  let hitObstacle : Bool := (← resolveCollisions.run).isNone
  if not hitObstacle then
    modifyPositionY (· + (← get).player.speed * delta)
    modifySpeed (· + gravity.toFloat * delta)
    setCanJump false
  else
    setCanJump true

private def updateCameraCenter [Monad m] [MonadState GameState m] : m Unit := do
  setTarget (← get).player.position

private def renderEnvironment : GameM Unit := do
  forM (← read).items fun item => drawRectangleRec item.rect item.color

private def renderPlayer : GameM Unit := do
  let p := (← get).player
  drawRectangleRec
    { x := p.position.x - player_width / 2
    , y := p.position.y - player_height
    , width := player_width
    , height := player_height }
    Color.red

private def updateZoom [Monad m] [MonadState GameState m] (offset: Float) : m Unit := do
    modifyZoom (· + offset)
    if (← get).camera.zoom > 3 then setZoom 3
      else if (← get).camera.zoom < 0.25 then setZoom 0.25

private def doRender : GameM Unit := do
  while not (← windowShouldClose) do
    updatePlayer (← getFrameTime)
    updateZoom ((← getMouseWheelMove) * 0.05)
    updateCameraCenter
    renderFrame do
      clearBackground Color.Raylib.lightgray
      renderWithCamera2D (← get).camera do
        renderEnvironment
        renderPlayer
  closeWindow

def main : IO Unit := do
  initWindow screenWidth screenHeight "2d camera"
  setTargetFPS fps
  doRender
  |>.run' initGameState
  |>.run initGameEnv

end Camera2DPlatformer
