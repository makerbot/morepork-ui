## Morepork UI

The brand new GUI for sombrero!

### Developing with Qt Creator

Just clone this repo and open morepork-ui.pro.  The first time you do this
Qt creator will ask you to "configure" the project -- just leave the
default settings of only building for Desktop and click `Configure Project`.
This will create a morepork-ui.pro.user file which will store this and any
other preferences that you set for the project.  This file is gitignored
and should not be checked in.

Any new qml files or even C++ source files you add here should automatically
get added to the project.  In addition to just using a normal git client,
you can branch, commit and push from Qt creator (see Tools->Git).
