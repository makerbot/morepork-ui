# Build root installs the qt5 cmake configs to staging
# so this just magically works.
find_package(Qt5Gui REQUIRED)
find_package(Qt5Qml REQUIRED)

set(CMAKE_AUTOMOC ON)

add_executable(morepork_ui main.cpp)
target_link_libraries(morepork_ui Qt5::Gui Qt5::Qml)

# The qt5 cmake configs point to a copy of the qt5 libraries that live
# in staging, but all of the libraries that qt5 depends on still only
# live in rootfs.  Luckily there is an obscure linker option for this
# exact problem.
set_target_properties(morepork_ui PROPERTIES
    LINK_FLAGS "-Wl,-rpath-link=${CMAKE_INSTALL_PREFIX}/${LIB_INSTALL_DIR}")

install(
    TARGETS morepork_ui
    DESTINATION ${BIN_INSTALL_DIR})
