import XMonad

import XMonad.Actions.CopyWindow
import XMonad.Actions.CycleWS
import XMonad.Actions.CycleWindows
import XMonad.Actions.GridSelect
import XMonad.Actions.MouseResize

import XMonad.Config.Desktop

import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks

import XMonad.Layout.LimitWindows
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), Toggle(..), (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import XMonad.Layout.NoBorders
import XMonad.Layout.PerWorkspace (onWorkspace) 
import XMonad.Layout.Reflect (reflectVert, reflectHoriz, REFLECTX(..), REFLECTY(..))
import XMonad.Layout.Renamed (renamed, Rename(CutWordsLeft, Replace))
import XMonad.Layout.ResizableTile
import XMonad.Layout.SimplestFloat
import XMonad.Layout.Spacing
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))
import XMonad.Layout.WindowArranger
import XMonad.Layout.WorkspaceDir

    -- Layouts
import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.SimplestFloat
import XMonad.Layout.OneBig
import XMonad.Layout.ThreeColumns
import XMonad.Layout.ResizableTile
import XMonad.Layout.ZoomRow (zoomRow, zoomIn, zoomOut, zoomReset, ZoomMessage(ZoomFullToggle))
import XMonad.Layout.IM (withIM, Property(Role))

import XMonad.Util.EZConfig
import XMonad.Util.Run
import XMonad.Util.SpawnOnce

import qualified XMonad.StackSet as W
import qualified Data.Map as M

-- The main function.import XMonad

-- main = xmonad =<< statusBar myBar xmobarPP toggleStrutsKey myConfig
main = do
  h <- spawnPipe myBar
  xmonad $ desktopConfig
    { logHook = dynamicLogWithPP $ xmobarPP {
        ppOutput = hPutStrLn h
        }
    , terminal = myTerminal
    , borderWidth = myBorderWidth
    , layoutHook = myLayoutHook
    , startupHook = myStartupHook
    , focusedBorderColor = "#800000"
    , modMask = mod4Mask
    , workspaces = myWorkspaces
      }
    `additionalKeysP` myKeysP
  
-- Command to launch the bar.
myBar = "xmobar ~/.xmobar/xmobar.hs --recompile"


-- Autostartup
myStartupHook = do
  spawnOnce "xbacklight -set 20 "
  -- spawnOnce "xbindkeys &"
  spawnOnce "/usr/bin/numlockx on "
  spawnOnce "nitrogen --restore "
  spawnOnce "xset r rate 500 40 "
  spawnOnce "pactl set-sink-volume @DEFAULT_SINK@ 0% "
  spawnOnce "pactl set-sink-mute @DEFAULT_SINK@ 0 "
  spawnOnce "picom "

-- Terminal
-- myTerminal = "alacritty"
myTerminal = "gnome-terminal"

-- List of workspaces
myWorkspaces = ["1","2","3","4","5","6","7","8","9","0"]

-- Border width
myBorderWidth = 2


-- -- Custom PP
-- myPP = xmobarPP { ppCurrent = xmobarColor "#429942" "" . wrap "<" ">" }

-- -- Key binding to toggle the gap for the bar.
-- toggleStrutsKey XConfig {XMonad.modMask = modMask} = (modMask, xK_b)
spawnSelected' :: [(String, String)] -> X ()
-- spawnSelected' lst = gridselect conf lst >>= flip whenJust spawn
--     where conf = defaultGSConfig
spawnSelected' lst = gridselect defaultGSConfig lst >>= flip whenJust spawn



-- Additional key bindings
-- myKeys =  
--   [ ((myModMask, xK_Left), prevWS)
--   , ((myModMask, xK_Right), nextWS)
--   , ((myModMask, xK_r), spawn "xmonad --restart")
--   , ((mod4Mask, xK_l), spawn "physlock")
--   , ((mod4Mask, xK_Left), shiftToPrev)
--   , ((mod4Mask, xK_Right), shiftToNext)
--   , ((mod4Mask, xK_c), kill)
--   , ((mod4Mask, xK_f), spawn "firefox")
--   , ((mod4Mask, xK_Return), spawn "emacs")
--   , ((mod4Mask, xK_space), spawn "compiz-boxmenu")
--   , ((mod4Mask .|. shiftMask, xK_space), sendMessage NextLayout)
--   ]

myKeysP =
  [ ("M-c", kill)
  , ("M-f", spawn "firefox")
  , ("M-j", shiftToPrev >> prevWS)
  , ("M-k", shiftToNext >> nextWS)
  , ("M-l", spawn "physlock")
  , ("M-<Left>", windows W.focusUp)
  , ("M-<Return>", spawn "emacs")
  , ("M-<Right>", windows W.focusDown)
  , ("M-<Space>", spawn "compiz-boxmenu")
  , ("M-<Tab>", sendMessage NextLayout)
  , ("M-C-c", windows $ copyToAll)
  , ("M-S-e", spawn "emacs")
  , ("M-S-f", spawn "firefox")
  , ("M-S-m", spawn "thunderbird")
  , ("M-S-p", spawn "firefox --private-window")
  , ("M-S-t", spawn "gnome-terminal")
  , ("M-S-v", spawn "virtualbox")
  , ("M1-C-<Left>", prevWS)
  , ("M1-C-<Right>", nextWS)
  , ("M1-C-r", spawn "xmonad --restart")
  , ("M1-C-!", spawnSelected'
    [ ("HDMI on", "~/.screenlayout/layout1.sh && nitrogen --restore")
    , ("HDMI off", "xrandr --output HDMI1 --off")
    ])
  , ("<XF86AudioMute>", spawn "pactl set-sink-mute @DEFAULT_SINK@ toggle")
  , ("<XF86AudioLowerVolume>", spawn "pactl set-sink-volume @DEFAULT_SINK@ -10%")
  , ("<XF86AudioRaiseVolume>", spawn "pactl set-sink-volume @DEFAULT_SINK@ +10%")
  , ("<XF86MonBrightnessUp>", spawn "xbacklight -inc 10")
  , ("<XF86MonBrightnessDown>", spawn "xbacklight -dec 10")
  ]


myLayoutHook = avoidStruts $ mouseResize $ windowArrange $ 
               mkToggle (NBFULL ?? NOBORDERS ?? EOT) $ myDefaultLayout
             where 
                 myDefaultLayout = tall ||| tall_0 ||| noBorders monocle ||| space

  
tall       = renamed [Replace "Tall"]     $ limitWindows 12 $ spacing 6 $ ResizableTall 1 (3/100) (1/2) []
tall_0     = renamed [Replace "Tall0"]    $ limitWindows 12 $ spacing 0 $ ResizableTall 1 (3/100) (1/2) []
grid       = renamed [Replace "Grid"]     $ limitWindows 12 $ spacing 6 $ mkToggle (single MIRROR) $ Grid (16/10)
threeCol   = renamed [Replace "ThreeCol"] $ limitWindows 3  $ ThreeCol 1 (3/100) (1/2) 
-- threeRow   = renamed [Replace "threeRow"] $ limitWindows 3  $ Mirror $ mkToggle (single MIRROR) zoomRow
oneBig     = renamed [Replace "OneBig"]   $ limitWindows 6  $ Mirror $ mkToggle (single MIRROR) $ mkToggle (single REFLECTX) $ mkToggle (single REFLECTY) $ OneBig (5/9) (8/12)
monocle    = renamed [Replace "Full"]  $ limitWindows 20 $ Full
space      = renamed [Replace "Space"]    $ limitWindows 4  $ spacing 12 $ Mirror $ mkToggle (single MIRROR) $ mkToggle (single REFLECTX) $ mkToggle (single REFLECTY) $ OneBig (2/3) (2/3)
-- floats     = renamed [Replace "floats"]   $ limitWindows 20 $ simplestFloat

