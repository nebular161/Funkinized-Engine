# Everlast Engine
A Friday Night Funkin' engine that makes using source code feel much more easier and will come with good ol' Hscript support! The engine also has organized assets making it easy to navigate them.

# Features (This section is not finished yet):
- Organized assets and source code
- Hscript support
- Higher framerate

# Building
To get started, you need the following programs:
- Haxe 4.2.5
- VS Community 2019
- VS Code (Optional)

Now we need to install some libraries, open up the 'Libraries' batch (.bat) file to make it install the required files.

Then we need to install some gits:
- Git https://git-scm.com/download (For the git setup, leave everything to its default settings)
- haxelib git faxe https://github.com/uhrobots/faxe
- haxelib git linc_luajit https://github.com/nebulazorua/linc_luajit.git
- haxelib git hxvm-luajit https://github.com/nebulazorua/hxvm-luajit

Finally we're going to install only 2 components in VS Community 2019:
- MSVC v142 - VS 2019 C++ x64/x86 build tools
- Windows SDK (10.0.17763.0)

# Build Commands
- Lime build [target] (Whichever platform you want to build: windows, mac, linux, html5)
- You can find the build at Everlast-Engine/export/release/[target]/bin including all the assets and an exe file that -  you've build the code with
- If you want to access debug mode, do lime build [target] -debug
- You can find the debug version of the build by simply going to Everlast-Engine/export/debug/[target]/bin
- Now you can make your own FNF mod, hope you enjoy!

# Credits
- NebulaZone: Creator, Programmer
- ThatOneFoxHX: Programmer
- AlexShadow: Additional Programming Help
- Yoshubs: Inspiration
- YoshiCrafter: Inspiration, Hscript improved git
