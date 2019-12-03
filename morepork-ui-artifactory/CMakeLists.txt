cmake_minimum_required(VERSION 3.1.0)
project(MoreporkUiArtifacts CXX)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})
include(PlatformIntrospection)
_DETERMINE_MB_PLATFORM(MB_PLATFORM)
message(STATUS "MB_PLATFORM: ${MB_PLATFORM}")
add_definitions(-DLINUX_DISTRO="${MB_PLATFORM}")

set(CMAKE_AUTOMOC ON)
find_package(Qt5 COMPONENTS Core Gui Network REQUIRED)

add_definitions(-DPROJECT_SOURCE_DIR="${CMAKE_CURRENT_LIST_DIR}")
include_directories(${CMAKE_CURRENT_LIST_DIR})
add_executable(morepork_ui_artifactory main.cpp artifacts.cpp)
target_link_libraries(morepork_ui_artifactory Qt5::Core Qt5::Gui Qt5::Network)
