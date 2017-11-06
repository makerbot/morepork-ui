cmake_minimum_required(VERSION 3.1.0)
project(EnumParser CXX)

set(CMAKE_CONFIGURATION_TYPES "Debug;Release" CACHE STRING "Configs" FORCE)
if("${CMAKE_BUILD_TYPE}" STREQUAL "")
  message(STATUS "CMAKE_BUILD_TYPE was not set. Giving default value: Release")
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY VALUE Release)
endif()
set(CMAKE_CXX_FLAGS_RELEASE "-std=c++11 -DNDEBUG")
set(CMAKE_CXX_FLAGS_DEBUG "-std=c++11 -DDEBUG -D_DEBUG")

find_package(Boost COMPONENTS filesystem system regex REQUIRED)

add_executable(enum_parser ${CMAKE_CURRENT_SOURCE_DIR}/enum_parser.cpp)
target_link_libraries(enum_parser ${Boost_LIBRARIES})

