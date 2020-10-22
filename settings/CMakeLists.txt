if(NOT ${QT_CREATOR_BUILD})
    install(
        FILES "${CMAKE_CURRENT_SOURCE_DIR}/ui_settings.json"
        DESTINATION "${USER_EDITABLE_CONFIG_INSTALL_DIR}")
endif()
