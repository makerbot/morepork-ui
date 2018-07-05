## Morepork UI

The brand new GUI for sombrero!

### Developing with Qt Creator

This repo contains the Qt interface for sombrero. The root CMakeLists.txt file detects whether the repo is being built from within the morepork toolchain or stand alone from QtCreator. If using QtCreator, just open the root CMakeLists.txt file.

New QML files are automatically handled by the CMakeLists.txt, but new C++ files should be manually added to src/CMakeLists.txt. In addition to just using a normal git client, you can branch, commit and push from Qt creator (see Tools->Git).
