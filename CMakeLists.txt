cmake_minimum_required(VERSION 3.1.0)

project(MoreporkUI CXX)

set(CMAKE_CONFIGURATION_TYPES "Debug;Release" CACHE STRING "Configs" FORCE)
if("${CMAKE_BUILD_TYPE}" STREQUAL "")
  message(STATUS "CMAKE_BUILD_TYPE was not set. Giving default value: Release")
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY VALUE Release)
endif()

find_package(MBCMakeTools QUIET)

if(${MBCMakeTools_FOUND})
    set(QT_CREATOR_BUILD false)
else()
    message(STATUS "Performing QtCreator build")
    set(QT_CREATOR_BUILD true)
endif()

if(NOT ${QT_CREATOR_BUILD})
    add_subdirectory(auther)
endif()

if(${CMAKE_CROSSCOMPILING} OR ${QT_CREATOR_BUILD})
    if("${CMAKE_BUILD_TYPE}" STREQUAL "Release")
        add_definitions(-DQT_NO_DEBUG_OUTPUT)
    endif()
    add_subdirectory(src)
endif()

if(NOT ${QT_CREATOR_BUILD})
  generate_and_install_config(NAME MoreporkUI)
endif()

