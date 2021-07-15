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

### Update translations on the UI.

The translation files and the scripts to generate them are located in /src//translations

1.) Run 'update_ts_files.sh' in /src/translations. This will generate/update the .ts files in the translations directory. One file per language will be generated. The .ts file is just a template file containing all the strings on the UI. It also has other metadata like the filename, line # for the strings.

2.) Hand over the .ts files to the translators who will add the actual translations to them and send back the updated files.

3.) Replace the old .ts files with the received files and run 'generate_qm_files.sh' to generate the .qm files. The qm files are runtime translation files in binary format which are used by qt internally for loading translations quickly. Qt cannot directly use the .ts files and requires the .qm files for translations support.

See https://doc.qt.io/qt-5/qtlinguist-index.html
