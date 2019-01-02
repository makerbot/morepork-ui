## Morepork UI

The brand new GUI for sombrero!

### Developing with Qt Creator

This repo contains the Qt interface for sombrero. The root CMakeLists.txt file detects whether the repo is being built from within the morepork toolchain or stand alone from QtCreator. If using QtCreator, just open the root CMakeLists.txt file.

New QML files are automatically handled by the CMakeLists.txt, but new C++ files should be manually added to src/CMakeLists.txt. In addition to just using a normal git client, you can branch, commit and push from Qt creator (see Tools->Git).

### Instructions

(1) Open QtCreator

(2) In QtCreator, click File > Open File or Project...

(3) Select the file morepork-ui/morepork-ui-artifactory/morepork-ui-artifactory.pro

(4) On the left side, QtCreator should be on the Projects tab. On the right side, click the Configure Project button.

(5) QtCreator now goes to the Edit tab. Finally, click Build > Run

(6) A Terminal window then should open up to download the artifacts. Click Return on the resulting Terminal window to close it. 

(7) Verify that the following files were downloaded under morepork-ui/morepork-ui-artifactory/artifacts:
	json-cpp-develop-3.8.2.122-release-stable.tar.bz2
	libtinything-develop-3.8.0.230-release-stable.tar.bz2
	MBCoreUtils-develop-4.0.0.257-release-stable.tar.bz2


(8) Once the artifacts have been downloaded, click File > Close All Projects and Editors

(9) Now, click File > Open File or Project... and select the morepork-ui/CMakeLists.txt project

(10) Click Build > Build All to build the project
