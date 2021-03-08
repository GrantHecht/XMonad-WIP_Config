import XMonad
import qualified XMonad.StackSet as W
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.WorkspaceHistory
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.SpawnOnce(spawnOnce)
import XMonad.Util.EZConfig(additionalKeys)
import System.IO

-- Define Defaults
myModMask = mod4Mask
myTerminal = "alacritty"

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

-- Startup Hook
myStartupHook :: X ()
myStartupHook = do
   spawnOnce "lxsession &"
   spawnOnce "nitrogen --restore &"
   spawnOnce "picom --experimental-backends &"

-- Layout Hook
myLayoutHook = avoidStruts $ layoutHook defaultConfig

-- Manage Hook
myManageHook = composeAll
    [ className =? "Gimp"    --> doFloat
    , className =? "zoom"    --> doFloat
    ]

-- Log Hook
myLogHook :: X()
myLogHook = fadeInactiveLogHook fadeAmount
    where fadeAmount = 1.0

main = do
    -- Spawn xmobar
    xmproc <- spawnPipe "xmobar"

    xmonad $ docks defaultConfig
        { terminal = myTerminal
        , modMask = myModMask
        , manageHook = myManageHook <+> manageHook defaultConfig
        , startupHook = myStartupHook
        , layoutHook = myLayoutHook
        , logHook = workspaceHistoryHook <+> myLogHook <+> dynamicLogWithPP xmobarPP
            { ppOutput = \x -> hPutStrLn xmproc x
            , ppCurrent = xmobarColor "#98be65" "" . wrap "[" "]"
            , ppVisible = xmobarColor "#98be65" ""
            , ppHidden = xmobarColor "#82AAFF" "" .wrap "*" ""
            , ppHiddenNoWindows = xmobarColor "#c792ea" ""
            , ppTitle = xmobarColor "#b3afc2" "" . shorten 60
            , ppSep = "<fc=#666666> | </fc>"
            , ppUrgent = xmobarColor "#C45500" "" . wrap "!" "!"
            , ppExtras = [windowCount]
            , ppOrder = \(ws:l:t:ex) -> [ws,l]++ex++[t]
            }
        } `additionalKeys`
        [ ((controlMask, xK_Print), spawn "sleep 0.2; scrot -s")
        , ((0, xK_Print), spawn "scrot")
        ]
