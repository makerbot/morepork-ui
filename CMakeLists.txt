cmake_minimum_required(VERSION 3.1.0)

project(MoreporkUI CXX)

find_package(MBCMakeTools REQUIRED)

add_subdirectory(auther)
if(${CMAKE_CROSSCOMPILING})
    add_subdirectory(src)
    add_subdirectory(qml)
endif()

generate_and_install_config(NAME MoreporkUI)
