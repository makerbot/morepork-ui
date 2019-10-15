install(
    DIRECTORY ${PROJECT_SOURCE_DIR}/auther DESTINATION "${PY34_MODULE_DIR}"
    FILES_MATCHING PATTERN "*.py"
    )

set(systemd_libpath ${LIB_INSTALL_DIR}/systemd/system)
set(systemd_linkpath
    ${CONFIG_INSTALL_DIR}/systemd/system/multi-user.target.wants)

function(install_enabled_service service)
    file(RELATIVE_PATH systemd_link
        /${systemd_linkpath} /${systemd_libpath}/${service})
    # Make the link at configure time since it has no
    # build time dependencies
    execute_process(COMMAND ln -sf ${systemd_link}
        ${CMAKE_CURRENT_BINARY_DIR}/${service})
    install(
        FILES ${CMAKE_CURRENT_BINARY_DIR}/${service}
        DESTINATION ${systemd_linkpath})
    install(FILES ${service} DESTINATION ${systemd_libpath})
endfunction()

function(install_disabled_service service)
    install(FILES ${service} DESTINATION ${systemd_libpath})
endfunction()

install_disabled_service(auther.service)
install_enabled_service(morepork_ui.service)

install(PROGRAMS use_new_display DESTINATION ${BIN_INSTALL_DIR})

