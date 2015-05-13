# Orbital dog fight
> I think it needs more lasers...

This game was originally developed by for T-624-CGDD (Computer Game Design and
Development) at Reykjavik University (2015):
- Fabio Alessandrelli <fabio.alessandrelli@gmail.com>
- Gunnar Páll Gunnarsson <pallimoon@gmail.com>
- Murray Tannock <murraytannock@gmail.com>

All the code (gd script) is released under GPLv3 License (you can find a copy
of the license in LICENSE.GPLv3). All assets and scenes are released
under CC-BY-SA (you can find a copy of the license in LICENSE.CC-BY-SA),
licenses for non-original assets can be found in the attributions section below.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

## Download Instructions

The `bin` directory of this repository contains OSX, Linux and Windows binaries
precompiled. These should run like any other application
-  OSX: it may be necessary to bypass Gatekeeper (by secondary clicking the icon and clicking open whilst holding the option key) in order to run the application.
- Linux: make the binary file executable by using `chmod +x <filename>`

## Build Instructions
To build this software the [GODOT](http://www.godotengine.org/) game
engine is required <sup>[1](#myfootnote1)</sup>, as well as the
[git](http://git-scm.com/) version control system.

Install the export templates
- that can be found on the godot download page
http://www.godotengine.org/wp/download/.
- if using the custom engine build the export templates also using the
following command from within the godot repository `scons platform=<platform>
tools=no target=release bits=64`. After building the desired templates compress
them into a '.zip' file and change the extension to `.tpz`.

The templates can be directly imported into the editor by clicking `Settings ->
Install Export Templates`

Clone this repository `git clone
https://github.com/Palli-Moon/orbital-dog-fight.git` and import the project into
godot. Then click the `Export` button, choose your target platform, set the
options as desired, then click `Export` to export the file to a `.zip`
containing the executable.

## Asset Attributation
###Music
####[Relix - 505](https://fiveofive.bandcamp.com/album/relix-1996-2013)
- Artist: 505
- License: CC BY-NC-SA
- Website: http://www.fiveofive-music.com/

    [From the [Free Music Archive](http://freemusicarchive.org)]
    
***

###Fonts
####[Press Start 2P](http://www.zone38.net/font/)
- Designer: codeman38
- License: [SIL Open Font License](http://scripts.sil.org/cms/scripts/page.php?site_id=nrsi&id=OFL)
- Website: http://www.zone38.net/

    [A minor derivative of the above font with additional characters is used.]

---

---
<a name="myfootnote1">[1]</a>: Some features require an experimental version of
the engine which can be found on the `gravity_distance_2d` branch at
https://github.com/Faless/godot. The game still runs with the standard build,
but gravity does not scale with distance.
