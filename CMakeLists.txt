cmake_minimum_required(VERSION 3.1.0)

project(MoreporkUI NONE)

find_package(MBCMakeTools REQUIRED)

add_subdirectory(auther)

generate_and_install_config(NAME Kaiten)
