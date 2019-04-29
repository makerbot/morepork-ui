# Copy over the settings file and then install it
function(install_settings machine_name)
    configure_file(${CMAKE_SOURCE_DIR}/settings/ui_settings.json
      ${CMAKE_CURRENT_BINARY_DIR}/${machine_name}/ui_settings.json COPYONLY)
    install(
        FILES
            "${CMAKE_CURRENT_BINARY_DIR}/${machine_name}/ui_settings.json"
        DESTINATION
            per_machine/${machine_name}/${USER_EDITABLE_CONFIG_INSTALL_DIR})
endfunction()

install_settings(fire dual lava)
