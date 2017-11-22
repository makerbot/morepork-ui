if(${QT_CREATOR_BUILD})
    add_definitions(-DMOREPORK_UI_QT_CREATOR_BUILD)
    add_definitions(-DMOREPORK_ROOT_DIR="${MoreporkUI_SOURCE_DIR}")
    add_definitions(-DQT_DISABLE_DEPRECATED_BEFORE=0x060000)
endif()

if(NOT ${QT_CREATOR_BUILD})
    find_package(JsonCpp REQUIRED)
    find_package(JsonRpc REQUIRED)
    find_package(TinyThing REQUIRED)
endif()

# Build root installs the qt5 cmake configs to staging
# so this just magically works.
find_package(Qt5 COMPONENTS Core Quick Multimedia Gui REQUIRED)
find_package(Qt5LinguistTools)

# Model impl sources aren't built for Qt creator so they just live here
set(SOURCES
    main.cpp
    model/base_model.cpp
    model/bot_model.cpp
    model/net_model.cpp
    model/process_model.cpp
    storage/storage.cpp)

# These are not used QtCreator build
set(MODEL_IMPL_SOURCES
    model_impl/kaiten_net_model.cpp
    model_impl/kaiten_process_model.cpp
    model_impl/kaiten_bot_model.cpp
    model_impl/local_jsonrpc.cpp
    #gui_helpers.cpp
    storage/makerbot_file_meta_reader.cpp)

# automoc cannot be reliably used when it relies
# on a dynamic header (ie. enum_parser)
include_directories(${CMAKE_CURRENT_SOURCE_DIR} model model_impl)
set(MOREPORK_UI_HEADERS
    ui_translator.h
    model/base_model.h
    model/bot_model.h
    model/net_model.h
    model/process_model.h
    storage/storage.h)

if(NOT ${QT_CREATOR_BUILD})
    list(APPEND SOURCES ${MODEL_IMPL_SOURCES})
    list(APPEND MOREPORK_UI_HEADERS model_impl/local_jsonrpc.h)
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

qt5_add_resources(MOREPROK_UI_RESOURCES qml/media.qrc qml/qml.qrc)

# Take care of host code
if(${QT_CREATOR_BUILD})
    include_directories(host)
    qt5_add_resources(MOREPROK_HOST_UI_RESOURCES host/host.qrc)
    list(APPEND MOREPROK_UI_RESOURCES ${MOREPROK_HOST_UI_RESOURCES})
    list(APPEND SOURCES host/host_model.cpp)
endif()

add_executable(morepork_ui
    ${SOURCES}
    ${MOREPROK_UI_RESOURCES}
    ${QM_FILES}
    ${MOREPORK_UI_HEADERS_MOC})
target_link_libraries(morepork_ui
    Qt5::Core
    Qt5::Quick
    Qt5::Multimedia)
if(NOT ${QT_CREATOR_BUILD})
    target_link_libraries(morepork_ui JsonRpc::jsonrpc TinyThing::tinything)
endif()

if(NOT ${QT_CREATOR_BUILD})
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
endif()

# Read qml qrc file, parse out all qml file names, and install them
add_subdirectory(qml)

