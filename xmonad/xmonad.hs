
import XMonad hiding (Tall)
import XMonad.Util.Run
import XMonad.Util.EZConfig
import XMonad.Util.Themes
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Actions.CycleWS
import XMonad.Actions.CopyWindow
import XMonad.Layout.HintedGrid
import XMonad.Layout.HintedTile
import XMonad.Layout.LayoutHints
import XMonad.Layout.NoBorders
import XMonad.Layout.PerWorkspace
--import XMonad.Layout.TwoPane
import XMonad.Layout.Tabbed
import Graphics.X11.ExtraTypes.XF86

import qualified XMonad.StackSet as W

myWorkspaces = ["1","2","3","4","5","6","7","8","9","10","11","12"]
myTerminal   = "urxvtc"
myMod        = mod4Mask

-- Mod+Shift+Space reloads theme
myTheme = defaultTheme { activeColor         = "orange"
                       , activeBorderColor   = "orange"
                       , activeTextColor     = "black"
                       , inactiveColor       = "black"
                       , inactiveBorderColor = "orange"
                       , inactiveTextColor   = "white"
                       , urgentColor         = "red"
                       , urgentBorderColor   = "black"
                       , urgentTextColor     = "white"
                       , decoHeight          = 18
                       , fontName            = "xft:terminus:bold:size=12" }

myLayouts = smartBorders
          $ onWorkspace "12:wne" wineLayout
          $ avoidStruts
          $ basicLayout
    where
        wineLayout  = Full
        --basicLayout = layoutHintsToCenter $ tabbed ||| full ||| grid ||| two ||| horiz ||| vert
        basicLayout = layoutHintsToCenter $ tab ||| full ||| grid ||| horiz ||| vert
        --tab         = simpleTabbed
        tab         = tabbedAlways shrinkText myTheme
        full        = Full
        grid        = Grid False
        --two         = TwoPane delta ratio
        horiz       = HintedTile nmaster delta ratio Center Wide
        vert        = HintedTile nmaster delta ratio Center Tall
        nmaster     = 1
        delta       = 3/100
        ratio       = 1/2

myManageHook = composeAll $
    [ (className =? i                                 ) --> doFloat  | i <- myFloats ]
    ++
    [ (className =? i                                 ) --> doIgnore | i <- myIgnore ]
    ++
    [ (isFullscreen                                   ) --> doFullFloat

    , (className =? "Chromium"                        ) --> doShift "1"
    , (className =? "Lanikai"                         ) --> doShift "1"
    , (className =? "Miramar"                         ) --> doShift "1"

    , (className =? "Opera"                           ) --> doShift "2"
    , (className =? "Shredder"                        ) --> doShift "2"
    , (className =? "URxvt" <&&> title =? "media"     ) --> doShift "2"
    , (className =? "URxvt" <&&> title =? "ncmpc"     ) --> doShift "2"

    , (className =? "Xchm"                            ) --> doShift "3"
    , (className =? "Kchmviewer"                      ) --> doShift "3"
    , (className =? "Xpdf"                            ) --> doShift "3"
    , (className =? "Acroread"                        ) --> doShift "3"
    , (className =? "Apvlv"                           ) --> doShift "3"
    , (className =? "Evince"                          ) --> doShift "3"
    , (className =? "Lyx"                             ) --> doShift "3"
    , (className =? "Inkscape"                        ) --> doShift "3"
    , (className =? "OpenOffice"                      ) --> doShift "3"
    , (className =? "OpenOffice.org 3.2"              ) --> doShift "3"
    , (className =? "freemind-main-FreeMindStarter"   ) --> doShift "3"

    , (className =? "rdesktop"                        ) --> doShift "5"
    --, (className =? "Vncviewer"                       ) --> doShift "5"

    , (className =? "VirtualBox"                      ) --> doShift "6"

    , (className =? "Mangler"                         ) --> doShift "8"

    , (className =? "URxvt" <&&> title =? "screen"    ) --> doShift "9"

    --, (className =? "URxvt" <&&> title =? "jackshrimp") --> doShift "10"
    --, (className =? "URxvt" <&&> title =? "insanum"   ) --> doShift "10"
    --, (className =? "URxvt" <&&> title =? "ifpg"      ) --> doShift "10"

    , (className =? "Wireshark"                       ) --> doShift "11"
    , (className =? "P4v.bin"                         ) --> doShift "11"
    , (className =? "weka-gui-GUIChooser"             ) --> doShift "11"

    , (className =? "Wine"                            ) --> doShift "12"
    ]
    where
        --myFloats = [ "Gxmessage", "Gimp", "Vncviewer", "rdesktop", "Mplayer", "Smplayer", "Wine", "weka-gui-GUIChooser", "Mangler", "VirtualBox", "feh", "Calendar" ]
        myFloats = [ "Gxmessage", "Gimp", "rdesktop", "Mplayer", "Smplayer", "Wine", "weka-gui-GUIChooser", "Mangler", "VirtualBox", "feh", "Calendar" ]
        myIgnore = [ "Gxmessage" ]

myKeys =
    [ ((myMod,                 xK_p),                    spawn "dwm_launch prog")
    , ((myMod .|. shiftMask,   xK_p),                    spawn "dwm_launch mpc")
    , ((myMod .|. controlMask, xK_p),                    spawn "gmrun")
    , ((myMod,                 xK_o),                    spawn "osdsys")
    --, ((0,                     xF86XK_Calculator),       spawn "xautolock -locknow")
    --, ((0,                     xF86XK_AudioPlay),        spawn "xautolock -locknow")
    , ((0,                     xF86XK_AudioPrev),        spawn "amixer sset Master 2-")
    , ((0,                     xF86XK_AudioNext),        spawn "amixer sset Master 2+")
    , ((0,                     xF86XK_AudioLowerVolume), spawn "amixer sset Master 2-")
    , ((0,                     xF86XK_AudioRaiseVolume), spawn "amixer sset Master 2+")
    , ((myMod,                 xK_Up),                   spawn "amixer sset Master 2+")
    , ((myMod,                 xK_Down),                 spawn "amixer sset Master 2-")
    , ((myMod,                 xK_Right),                nextWS)
    , ((myMod,                 xK_Left),                 prevWS)
    , ((myMod .|. shiftMask,   xK_Right),                shiftToNext >> nextWS)
    , ((myMod .|. shiftMask,   xK_Left),                 shiftToPrev >> prevWS)
    , ((myMod,                 xK_Escape),               toggleWS)
    , ((myMod,                 xK_Escape),               toggleWS)
    , ((myMod,                 xK_Escape),               toggleWS)
    , ((myMod,                 xK_v),                    windows copyToAll)  -- Make focused window always visible
    , ((myMod .|. shiftMask,   xK_v),                    killAllOtherCopies) -- Toggle window state back
    ]
    ++
    -- M-F[N]     -> Switch to workspace N
    -- M-S-F[N]   -> Move client to workspace N
    -- M-C-S-F[N] -> Copy client to workspace N
    [((m .|. myMod, k), windows $ f i)
        | (i, k) <- zip myWorkspaces [xK_F1..xK_F12]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
        -- , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask), (copy, shiftMask .|. controlMask)]]

myMouse =
    [ ((myMod, button4), (\_ -> moveTo Next NonEmptyWS))
    , ((myMod, button5), (\_ -> moveTo Prev NonEmptyWS))
    ]

main = do
    --dzen_status <- spawnPipe "dzen_status"
    --dzen_bar <- spawnPipe "dzen2 -p -e '' -y -1 -ta l -fn 'xft:terminus:bold:size=10'"
    xmobar_status <- spawnPipe "xmobar $HOME/.xmobar_status"
    xmobar_bar <- spawnPipe "xmobar $HOME/.xmobar_xmonad"
    xmonad $ defaultConfig
        { manageHook         = manageDocks <+> myManageHook <+> manageHook defaultConfig
        , layoutHook         = myLayouts
        , borderWidth        = 1
        , normalBorderColor  = "grey"
        , focusedBorderColor = "orange"
        , workspaces         = myWorkspaces
        , terminal           = myTerminal
        , modMask            = myMod
          , logHook = dynamicLogWithPP $ defaultPP { ppOutput  = hPutStrLn xmobar_bar
                                                   , ppTitle   = xmobarColor "green" ""
                                                   , ppLayout  = xmobarColor "orange" ""
                                                   , ppSep     = xmobarColor "grey" "" " | "
                                                   , ppWsSep   = " "
                                                   , ppCurrent = xmobarColor "yellow" "" . wrap "<" ">"
                                                   , ppHidden  = xmobarColor "cyan" ""
                                                   --, ppHiddenNoWindows = xmobarColor "grey" ""
                                                   }
        --, logHook = dynamicLogWithPP $ defaultPP { ppOutput  = hPutStrLn dzen_bar
        --                                         , ppTitle   = dzenColor "green" ""
        --                                         , ppLayout  = dzenColor "orange" ""
        --                                         , ppSep     = dzenColor "grey" "" " | "
        --                                         , ppWsSep   = " "
        --                                         , ppCurrent = dzenColor "yellow" "" . wrap "<" ">"
        --                                         , ppHidden  = dzenColor "cyan" ""
        --                                         --, ppHiddenNoWindows = dzenColor "grey" ""
        --                                         --, ppOrder   = reverse
        --                                         }
        }
        `additionalKeys`          myKeys
        `additionalMouseBindings` myMouse
        `removeKeysP`             ["M-" ++ [n]   | n <- ['1'..'9']]
        `removeKeysP`             ["M-S-" ++ [n] | n <- ['1'..'9']]

