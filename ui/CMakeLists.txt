# Parse in the list of all qml files to install from qml.qrc
set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS ui.qrc)

# For now we just hackily parse this with CMake but we should probably
# use a python script to parse it if we need anything more complicated.
file(STRINGS ui.qrc src_elems REGEX "^ *<file *(alias=\"[A-z0-9_]+\.+[A-z0-9]+\")*>")
set(sources)
foreach(src_elem IN LISTS src_elems)
    string(STRIP "${src_elem}" src_elem_strip)
    string(REGEX REPLACE "<[^>]*>" "" src "${src_elem_strip}")
    list(APPEND sources "${src}")
    message(STATUS "${src}")
endforeach()

install(
    FILES ${sources}
    DESTINATION ${ROOT_INSTALL_DIR}/usr/share/morepork_ui)
