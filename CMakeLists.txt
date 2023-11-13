cmake_minimum_required(VERSION 3.1.0)

project(MoreporkUI CXX)

set(CMAKE_CONFIGURATION_TYPES "Debug;Release" CACHE STRING "Configs" FORCE)
if("${CMAKE_BUILD_TYPE}" STREQUAL "")
    message(STATUS "CMAKE_BUILD_TYPE not set. Giving default value: Release")
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY VALUE Release)
else()
    # Handle QtCreator MinSizeRel type (opt for Release)
    if("${CMAKE_BUILD_TYPE}" STREQUAL "MinSizeRel")
        message(STATUS "CMAKE_BUILD_TYPE MinSizeRel not supported."
                       " Opting for value: Release")
        set_property(CACHE CMAKE_BUILD_TYPE PROPERTY VALUE Release)
    else()
        # Handle QtCreator RelWithDebInfo and other types (opt for Debug)
        if( NOT ( ("${CMAKE_BUILD_TYPE}" STREQUAL "Release") OR
                ("${CMAKE_BUILD_TYPE}" STREQUAL "Debug") ) )
            message(STATUS "Unsupported CMAKE_BUILD_TYPE value."
                           " Opting for value: Debug")
            set_property(CACHE CMAKE_BUILD_TYPE PROPERTY VALUE Debug)
        endif()
    endif()
endif()

find_package(MBCMakeTools QUIET)

if(${MBCMakeTools_FOUND})
    set(QT_CREATOR_BUILD false)
else()
    message(STATUS "Performing QtCreator build")
    #TODO(sam) temporarily checking if the artifact files exist. this should
    # be a call to a script that performs the artifact pull or at the very least
    # build and execute the morepork-ui-artifactory project right here.
    file(GLOB ARTIFACTS_LIST "${CMAKE_CURRENT_LIST_DIR}/morepork-ui-artifactory/artifacts/json-cpp-develop*"
                             "${CMAKE_CURRENT_LIST_DIR}/morepork-ui-artifactory/artifacts/libtinything-develop*"
                             "${CMAKE_CURRENT_LIST_DIR}/morepork-ui-artifactory/artifacts/MBCoreUtils-develop*")
    list(LENGTH ARTIFACTS_LIST ARTIFACTS_LIST_LENGTH)
    if (NOT ${ARTIFACTS_LIST_LENGTH} EQUAL 3)
        message(STATUS "ARTIFACTS_LIST: ${ARTIFACTS_LIST}")
        message(FATAL_ERROR "You don't have the necessary artifacts. You must build and run morepork-ui/morepork-ui-artifactory before building morepork-ui.")
    endif()
    set(QT_CREATOR_BUILD true)
endif()

if(NOT ${QT_CREATOR_BUILD})
    add_subdirectory(auther)
endif()

add_definitions(-DSETTINGS_FILE_DIR="${CMAKE_SOURCE_DIR}/settings")

if(${CMAKE_CROSSCOMPILING} OR ${QT_CREATOR_BUILD})
    if("${CMAKE_BUILD_TYPE}" STREQUAL "Release")
        add_definitions(-DQT_NO_DEBUG_OUTPUT)
        add_definitions(-DQT_MESSAGELOGCONTEXT)
    endif()
    add_subdirectory(src)
    add_subdirectory(settings)
else()
    enable_testing()
    find_package(PythonInterp REQUIRED)
    add_test(
        NAME test_prints_check
        COMMAND "${PYTHON_EXECUTABLE}"
            "${CMAKE_SOURCE_DIR}/test_prints/check_prints.py")
    add_test(
        NAME cal_prints_check
        COMMAND "${PYTHON_EXECUTABLE}"
            "${CMAKE_SOURCE_DIR}/calibration_prints/check_prints.py")
endif()

if(NOT ${QT_CREATOR_BUILD})
  generate_and_install_config(NAME MoreporkUI)
endif()

