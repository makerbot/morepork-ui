if(${QT_CREATOR_BUILD})
    add_definitions(-DMOREPORK_UI_QT_CREATOR_BUILD)
    add_definitions(-DMOREPORK_ROOT_DIR="${MoreporkUI_SOURCE_DIR}")
    add_definitions(-DQT_DISABLE_DEPRECATED_BEFORE=0x060000)
endif()

set(HAVE_LIBTINYTHING false)
# For Qt Creator builds check if we have a local libtinything artifact
if(${QT_CREATOR_BUILD} AND EXISTS "${MoreporkUI_SOURCE_DIR}/artifacts/cmake")
    set(TinyThing_DIR "${MoreporkUI_SOURCE_DIR}/artifacts/cmake")
    set(JsonCpp_DIR "${MoreporkUI_SOURCE_DIR}/artifacts/cmake")
    find_package(JsonCpp QUIET)
    find_package(TinyThing QUIET)
    if(TARGET JsonCpp::jsoncpp AND TARGET TinyThing::tinything)
        set(HAVE_LIBTINYTHING true)
        add_definitions(-DHAVE_LIBTINYTHING)
    endif()
endif()

if(NOT ${QT_CREATOR_BUILD})
    find_package(JsonCpp REQUIRED)
    find_package(JsonRpc REQUIRED)
    find_package(TinyThing REQUIRED)
    find_package(Boost
      REQUIRED
      CONFIG
      COMPONENTS
      log
      log_setup
      system
      filesystem
      date_time
      regex
      thread
      chrono
    )
    add_definitions(-DHAVE_LIBTINYTHING)
endif()

# Build root installs the qt5 cmake configs to staging
# so this just magically works.
find_package(Qt5 COMPONENTS Core Quick Multimedia Gui REQUIRED)
find_package(Qt5LinguistTools)
find_package(Qt5QuickCompiler)

# Model impl sources aren't built for Qt creator so they just live here
set(SOURCES
    main.cpp
    model/base_model.cpp
    model/bot_model.cpp
    model/net_model.cpp
    model/process_model.cpp
    model/logger.cpp
    model/network.cpp
    model/fre_tracker.cpp
    storage/storage.cpp
    settings_interface/settings_interface.cpp
    storage/disk_manager.cpp
    dfs/dfs_settings.cpp
    print_queue/print_queue.cpp
    print_queue/asyncimageprovider.cpp)

# These are not used QtCreator build
set(MODEL_IMPL_SOURCES
    model_impl/kaiten_net_model.cpp
    model_impl/kaiten_process_model.cpp
    model_impl/kaiten_bot_model.cpp
    model_impl/local_jsonrpc.cpp
    model_impl/bot_logger.cpp
    storage/makerbot_file_meta_reader.cpp)

# automoc cannot be reliably used when it relies
# on a dynamic header (ie. enum_parser)
include_directories(${CMAKE_CURRENT_SOURCE_DIR} model model_impl)
set(MOREPORK_UI_HEADERS
    logging.h
    ui_translator.h
    model/base_model.h
    model/logger.h
    model/bot_model.h
    model/net_model.h
    model/process_model.h
    model/network.h
    model/fre_tracker.h
    storage/storage.h
    storage/progress_copy.h
    settings_interface/settings_interface.h
    storage/disk_manager.h
    dfs/dfs_settings.h
    print_queue/print_queue.h
    print_queue/asyncimageprovider.h)

if(NOT ${QT_CREATOR_BUILD})
    list(APPEND SOURCES ${MODEL_IMPL_SOURCES})
    list(APPEND MOREPORK_UI_HEADERS model_impl/local_jsonrpc.h)
else()
    if(${HAVE_LIBTINYTHING})
        list(APPEND SOURCES storage/makerbot_file_meta_reader.cpp)
    endif()
endif()

# Call the enum parser if MOREPORK_UI_HEADERS or enum_parser.cmake changes
set(PARSED_ENUM_FILE_NAME "${CMAKE_CURRENT_BINARY_DIR}/parsed_qml_enums.h")
include_directories(${CMAKE_CURRENT_BINARY_DIR})
add_custom_command(
    OUTPUT ${PARSED_ENUM_FILE_NAME}
    COMMAND ${CMAKE_COMMAND}
    ARGS -DPARSED_ENUM_FILE_NAME="${PARSED_ENUM_FILE_NAME}"
         -DHEADER_FILE_LIST="${MOREPORK_UI_HEADERS}" -P enum_parser.cmake
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Running enum_parser.cmake to generate parsed_qml_enums.h"
    DEPENDS ${MOREPORK_UI_HEADERS} enum_parser.cmake)
set_property(SOURCE main.cpp
    APPEND PROPERTY OBJECT_DEPENDS
    ${PARSED_ENUM_FILE_NAME})

qt5_wrap_cpp(MOREPORK_UI_HEADERS_MOC
    ${MOREPORK_UI_HEADERS}
    ${PARSED_ENUM_FILE_NAME})

# Run the following to generate/update .ts files:
# $ cd src/translations
# $ ./morepork_ts_update.sh
file(GLOB TS_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/translations/*.ts")
qt5_add_translation(QM_FILES ${TS_SOURCES})

qtquick_compiler_add_resources(MOREPORK_UI_RESOURCES qml/media.qrc qml/qml.qrc)

# Take care of host code
if(${QT_CREATOR_BUILD})
    include_directories(host)
    qt5_add_resources(MOREPORK_HOST_UI_RESOURCES host/host.qrc)
    list(APPEND MOREPORK_UI_RESOURCES ${MOREPORK_HOST_UI_RESOURCES})
    list(APPEND SOURCES host/host_model.cpp)
endif()

add_executable(morepork_ui
    ${SOURCES}
    ${MOREPORK_UI_RESOURCES}
    ${QM_FILES}
    ${MOREPORK_UI_HEADERS_MOC})
target_link_libraries(morepork_ui
    Qt5::Core
    Qt5::Quick
    Qt5::Multimedia
)

if(NOT ${QT_CREATOR_BUILD})
    target_link_libraries(morepork_ui
        JsonCpp::jsoncpp
        JsonRpc::jsonrpc
        TinyThing::tinything
        Boost::log
        Boost::log_setup
        Boost::system
        Boost::filesystem
        Boost::regex
        Boost::date_time
        Boost::thread
        Boost::chrono
        pthread
      )
    target_compile_options(morepork_ui PRIVATE -g)
else()
    if(${HAVE_LIBTINYTHING})
        target_link_libraries(morepork_ui JsonCpp::jsoncpp TinyThing::tinything)
    endif()
endif()

if(NOT ${QT_CREATOR_BUILD})
    # The qt5 cmake configs point to a copy of the qt5 libraries that live
    # in staging, but all of the libraries that qt5 depends on still only
    # live in rootfs.  Luckily there is an obscure linker option for this
    # exact problem.
    set_target_properties(morepork_ui PROPERTIES
        LINK_FLAGS "-Wl,-rpath-link=${CMAKE_INSTALL_PREFIX}/${LIB_INSTALL_DIR}")

    # We compiled morepork_ui with debug symbols, but we only want to install
    # with debug symbols to staging.  The binary is also huge because of all
    # of the images/animations bundled into it, so we strip the rodata section
    # that contains all of these from staging and hope it doesn't affect debug.
    set(strip_path "${CMAKE_BINARY_DIR}/morepork_ui.strip")
    set(debug_path "${CMAKE_BINARY_DIR}/morepork_ui.debug")
    add_custom_command(TARGET morepork_ui POST_BUILD
        COMMAND ${CMAKE_STRIP} --strip-unneeded -o "${strip_path}"
            "$<TARGET_FILE:morepork_ui>"
        COMMAND ${CMAKE_OBJCOPY} -R .rodata
            "$<TARGET_FILE:morepork_ui>" "${debug_path}")
    install(
        FILES "${strip_path}"
        DESTINATION "${BIN_INSTALL_DIR}"
        RENAME morepork_ui
        PERMISSIONS
            OWNER_EXECUTE OWNER_WRITE OWNER_READ
            GROUP_EXECUTE GROUP_READ
            WORLD_EXECUTE WORLD_READ)
    install(
        FILES "${debug_path}"
        DESTINATION "${STAGING_BIN_INSTALL_DIR}"
        RENAME morepork_ui
        PERMISSIONS
            OWNER_EXECUTE OWNER_WRITE OWNER_READ
            GROUP_EXECUTE GROUP_READ
            WORLD_EXECUTE WORLD_READ)

    install(DIRECTORY "${MoreporkUI_SOURCE_DIR}/fonts" DESTINATION
        "${ROOT_INSTALL_DIR}/usr/lib")

    install(FILES ${QM_FILES}
        DESTINATION "${ROOT_INSTALL_DIR}/usr/share/morepork_ui/translations")

    install(
        DIRECTORY "${MoreporkUI_SOURCE_DIR}/test_prints/fire/"
	    DESTINATION
            "${CMAKE_INSTALL_PREFIX}/per_machine/fire/rootfs/usr/test_prints")
    install(
        DIRECTORY "${MoreporkUI_SOURCE_DIR}/test_prints/lava/"
	    DESTINATION
            "${CMAKE_INSTALL_PREFIX}/per_machine/lava/rootfs/usr/test_prints")
    # TODO(chris) Actually make test prints for magma.  These won't actually
    #             print so we will hopefully catch this before shipping...
    install(
        DIRECTORY "${MoreporkUI_SOURCE_DIR}/test_prints/lava/"
	    DESTINATION
            "${CMAKE_INSTALL_PREFIX}/per_machine/magma/rootfs/usr/test_prints")
endif()
