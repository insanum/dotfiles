/* See LICENSE file for copyright and license details. */

/* appearance */
//static const char font[]            = "-*-terminus-medium-r-normal-*-14-*-*-*-*-*-*-*";
static const char font[]            = "-*-terminus-bold-r-*-*-20-*-*-*-*-*-*-*";
static const char normbordercolor[] = "#000";
static const char normbgcolor[]     = "#000";
static const char normfgcolor[]     = "#FA0";
//static const char selbordercolor[]  = "#0066ff";
static const char selbordercolor[]  = "#FA0";
static const char selbgcolor[]      = "#000";
static const char selfgcolor[]      = "#0F0";
static const unsigned int borderpx  = 1;        /* border pixel of windows */
static const unsigned int gappx     = 4;        /* gap pixel between windows */
static const unsigned int snap      = 32;       /* snap pixel */
static const Bool showbar           = True;     /* False means no bar */
static const Bool topbar            = True;     /* False means bottom bar */

/* tagging */
static const char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9" };

static const Rule rules[] = {
    /* class                instance    title           tags mask    isfloating    monitor */

    { "Chromium",           NULL,       NULL,           1<<0,       False,         -1 },
    { "Miramar",            NULL,       NULL,           1<<0,       False,         -1 },
    { "Opera",              NULL,       NULL,           1<<0,       False,         -1 },
    { "Arora",              NULL,       NULL,           1<<0,       False,         -1 },
    { "Uzbl",               NULL,       NULL,           1<<0,       False,         -1 },
    { "surf",               NULL,       NULL,           1<<0,       False,         -1 },

    { "Thunderbird",        NULL,       NULL,           1<<1,       False,         -1 },
    { "luvcview",           NULL,       NULL,           1<<1,       True,          -1 },
    { "Cheese",             NULL,       NULL,           1<<1,       True,          -1 },
    { "URxvt",              NULL,       "media",        1<<1,       False,         -1 },
    { "URxvt",              NULL,       "ncmpc",        1<<1,       False,         -1 },

    { "Firefox",            NULL,       NULL,           1<<2,       False,         -1 },
    { "Xchm",               NULL,       NULL,           1<<2,       False,         -1 },
    { "Xpdf",               NULL,       NULL,           1<<2,       False,         -1 },
    { "Kchmviewer",         NULL,       NULL,           1<<2,       False,         -1 },
    { "Acroread",           NULL,       NULL,           1<<2,       False,         -1 },
    { "Evince",             NULL,       NULL,           1<<2,       False,         -1 },
    { "FoxitReader",        NULL,       NULL,           1<<2,       False,         -1 },
    { "Apvlv",              NULL,       NULL,           1<<2,       False,         -1 },
    { "Lyx",                NULL,       NULL,           1<<2,       False,         -1 },
    { "Inkscape",           NULL,       NULL,           1<<2,       False,         -1 },

    { "Wine",               NULL,       NULL,           1<<3,       True,          -1 },

    { "rdesktop",           NULL,       NULL,           1<<4,       True,          -1 },
 /* { "Vncviewer",          NULL,       NULL,           1<<4,       False,         -1 }, */

    { "VirtualBox",         NULL,       NULL,           1<<5,       True,          -1 },

    { "Mangler",            NULL,       NULL,           1<<6,       True,          -1 },
    { "Wireshark",          NULL,       NULL,           1<<6,       False,         -1 },
    { "P4v",                NULL,       NULL,           1<<6,       False,         -1 },

    { "URxvt",              NULL,       "maka",         1<<7,       False,         -1 },

    { "URxvt",              NULL,       "tmux",         1<<8,       False,         -1 },

    { "URxvt",              NULL,       "org",          ~0,         True,         -1 },
    { "Gxmessage",          NULL,       NULL,           ~0,         True,          -1 },
    { "Zenity",             NULL,       NULL,           ~0,         True,          -1 },
    { "Yad",                NULL,       NULL,           ~0,         True,          -1 },

    { "SpiderOak",          NULL,       NULL,           0,          True,          -1 },
    { "Gimp",               NULL,       NULL,           0,          True,          -1 },
    { "Xloadimage",         NULL,       NULL,           0,          True,          -1 },
    { "MPlayer",            NULL,       NULL,           0,          True,          -1 },
    { "Smplayer",           NULL,       NULL,           0,          True,          -1 },
    { "Gkrellm",            NULL,       NULL,           0,          True,          -1 },
    { "Conky",              NULL,       NULL,           0,          True,          -1 },
    { "feh",                NULL,       NULL,           0,          True,          -1 },
    { "Cinelerra",          NULL,       NULL,           0,          True,          -1 },
};

/* layout(s) */
static const float mfact      = 0.55; /* factor of master area size [0.05..0.95] */
//static const Bool resizehints = True; /* True means respect size hints in tiled resizals */
static const Bool resizehints = False;

static const Layout layouts[] = { /* first entry is default */
	/* symbol     arrange function */
	{ "###",      gaplessgrid },
	{ "[]=",      tile },
	{ "><>",      NULL },
	{ "[M]",      monocle },
};

/* key definitions */
//#define MODKEY Mod1Mask
#define MODKEY Mod4Mask

#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
static const char *dmenucmd[] = { "dmenu_run", "-fn", font, "-nb", normbgcolor, "-nf", normfgcolor, "-sb", selbgcolor, "-sf", selfgcolor, NULL };
static const char *termcmd[]  = { "urxvtc", NULL };
static const char *orgcmd[]   = { "urxvtc", "-title", "org", "+sb", "-tr", "-sh", "10", "-g", "120x45+40-40", "-e", "vim", "Dropbox/insanum.org", NULL };
static const char *launcher[] = { "dwm_launch", "prog", NULL };
static const char *mpc[]      = { "dwm_launch", "mpc", NULL };
static const char *gmrun[]    = { "gmrun", NULL };
static const char *volu[]     = { "amixer", "-q", "sset", "Master", "1+", NULL };
static const char *vold[]     = { "amixer", "-q", "sset", "Master", "1-", NULL };
//static const char *osdsys[]  = { "osdsys", NULL };

static Key keys[] = {
    /* modifier             key         function        argument */
 /* { MODKEY,               XK_p,       spawn,          {.v = dmenucmd} }, */
    { MODKEY|ShiftMask,     XK_Return,  spawn,          {.v = termcmd} },

    /* application launcher (Mod-[Shift|Control]-p) */
    { MODKEY,               XK_p,       spawn,          {.v = launcher} },
    { MODKEY|ShiftMask,     XK_p,       spawn,          {.v = mpc} },
    { MODKEY|ControlMask,   XK_p,       spawn,          {.v = gmrun} },
    { MODKEY,               XK_Up,      spawn,          {.v = volu} },
    { MODKEY,               XK_Down,    spawn,          {.v = vold} },
    //{ MODKEY,               XK_o,       spawn,          {.v = osdsys} },

    /* hide/view bar (Mod-b) */
 /* { MODKEY,               XK_b,       togglebar,      {0} }, */

    /* focues next/prev client (Mod-j / Mod-k) (up/down) */
    { MODKEY,               XK_j,       focusstack,     {.i = +1} },
    { MODKEY,               XK_k,       focusstack,     {.i = -1} },

    /* increase/decrease master space (Mod-h / Mod-l) (left/right) */
    { MODKEY,               XK_h,       setmfact,       {.f = -0.02} },
    { MODKEY,               XK_l,       setmfact,       {.f = +0.02} },

    /* move client to master in tiled mode (Mod-Return) */
    { MODKEY,               XK_Return,  zoom,           {0} },

    /* view last? (Mod-Tab) */
    { MODKEY,               XK_Escape,  view,           {0} },

    /* kill client (Mod-Shift-c) */
    { MODKEY|ShiftMask,     XK_c,       killclient,     {0} },

    /* change layout */
    { MODKEY|ControlMask,   XK_1,       setlayout,      {.v = &layouts[0]} },
    { MODKEY|ControlMask,   XK_2,       setlayout,      {.v = &layouts[1]} },
    { MODKEY|ControlMask,   XK_3,       setlayout,      {.v = &layouts[2]} },
    { MODKEY|ControlMask,   XK_4,       setlayout,      {.v = &layouts[3]} },
    { MODKEY|ControlMask,   XK_space,   setlayout,      {0} },

    /* toggle floating (Mod-Shift-space) */
    { MODKEY|ShiftMask,     XK_space,   togglefloating, {0} },

    /* view more that one tag (Mod-#) (0 = VIEW ALL TAGS) */
    /* view more that one tag (Mod-Ctrl-#) */
    /* give/move client on a specific tag (Mod-Shift-#) (0 = PUT ON ALL TAGS) */
    /* make client sticky (toggle) on more than one tag (Mod-Ctrl-Shift-#) */
    //{ MODKEY,               XK_F11,     spawn,          {.v = orgcmd} },
    { MODKEY,               XK_F12,     view,           {.ui = ~0} },
    { MODKEY|ShiftMask,     XK_F12,     tag,            {.ui = ~0} },
    { MODKEY,               XK_w,       focusmon,       {.ui = 0 } },
    { MODKEY,               XK_e,       focusmon,       {.ui = 1 } },
    { MODKEY|ShiftMask,     XK_w,       tagmon,         {.ui = 0 } },
    { MODKEY|ShiftMask,     XK_e,       tagmon,         {.ui = 1 } },
    TAGKEYS(                XK_F1,                      0)
    TAGKEYS(                XK_F2,                      1)
    TAGKEYS(                XK_F3,                      2)
    TAGKEYS(                XK_F4,                      3)
    TAGKEYS(                XK_F5,                      4)
    TAGKEYS(                XK_F6,                      5)
    TAGKEYS(                XK_F7,                      6)
    TAGKEYS(                XK_F8,                      7)
    TAGKEYS(                XK_F9,                      8)

    /* quit dwm */
    { MODKEY|ShiftMask,     XK_q,       quit,           {0} },
};

/* button definitions */
/* click can be ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static Button buttons[] = {
	/* click                event mask      button          function        argument */
	{ ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
	{ ClkLtSymbol,          0,              Button3,        setlayout,      {.v = &layouts[2]} },
	{ ClkWinTitle,          0,              Button2,        zoom,           {0} },
	{ ClkStatusText,        0,              Button2,        spawn,          {.v = termcmd } },
	{ ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
	{ ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
	{ ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
	{ ClkTagBar,            0,              Button1,        view,           {0} },
	{ ClkTagBar,            0,              Button3,        toggleview,     {0} },
	{ ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
	{ ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
};

