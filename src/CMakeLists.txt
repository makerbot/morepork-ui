find_package(MBCoreUtils REQUIRED)
find_package(JsonCpp REQUIRED)
find_package(JsonRpc REQUIRED)

set(CMAKE_AUTOMOC ON)
include_directories(${CMAKE_CURRENT_SOURCE_DIR})

# Build root installs the qt5 cmake configs to staging
# so this just magically works.
find_package(Qt5 COMPONENTS Core Quick Multimedia REQUIRED)
find_package(Qt5LinguistTools)

# Parse src.pri to find the sources to compile
# This only builds on linux so we can just assume python is on the path
set_property(
    DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS parse_pri.py src.pri)
execute_process(
    COMMAND
        python "${CMAKE_CURRENT_SOURCE_DIR}/parse_pri.py"
        "${CMAKE_CURRENT_SOURCE_DIR}/src.pri" -d src -v SOURCES
    OUTPUT_VARIABLE SOURCES OUTPUT_STRIP_TRAILING_WHITESPACE)

# Model impl sources aren't built for Qt creator so they just live here
set(MODEL_IMPL_SOURCES
    model_impl/kaiten_net_model.cpp
    model_impl/kaiten_process_model.cpp
    model_impl/kaiten_bot_model.cpp
    model_impl/local_jsonrpc.cpp)

# Run the following to generate .ts files:
# lupdate qml/MoreporkUI.qml -ts morepork_de.ts morepork_it.ts etc
file(GLOB TS_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/translations/*.ts")
qt5_add_translation(QM_FILES ${TS_SOURCES})
qt5_add_resources(MOREPROK_UI_RESOURCES
    "${CMAKE_CURRENT_SOURCE_DIR}/qml/media.qrc")
add_executable(morepork_ui
    ${SOURCES}
    ${MODEL_IMPL_SOURCES}
    ${MOREPROK_UI_RESOURCES}
    ${QM_FILES}
    ui_translator.h)
target_link_libraries(morepork_ui
    Qt5::Core
    Qt5::Quick
    Qt5::Multimedia
    JsonRpc::jsonrpc)

# The qt5 cmake configs point to a copy of the qt5 libraries that live
# in staging, but all of the libraries that qt5 depends on still only
# live in rootfs.  Luckily there is an obscure linker option for this
# exact problem.
set_target_properties(morepork_ui PROPERTIES
    LINK_FLAGS "-Wl,-rpath-link=${CMAKE_INSTALL_PREFIX}/${LIB_INSTALL_DIR}")

install(TARGETS morepork_ui DESTINATION ${BIN_INSTALL_DIR})

install(DIRECTORY "${MoreporkUI_SOURCE_DIR}/fonts" DESTINATION
    "${ROOT_INSTALL_DIR}/usr/lib")

install(FILES ${QM_FILES}
    DESTINATION "${ROOT_INSTALL_DIR}/usr/share/morepork_ui/translations")

add_subdirectory(qml)

