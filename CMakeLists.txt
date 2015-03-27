cmake_minimum_required (VERSION 2.6)

project (ASPP3)

add_definitions(-std=c99 -Wall -Werror -g)

set(CMAKE_EXE_LINKER_FLAGS) 
set(CMAKE_INSTALL_PREFIX .)
#set(CMAKE_DOC_COMMAND doxygen ../Doxyfile.in)

#enable_testing()

# Crée une cible "doc" pour make. Cette cible génère la documentation
#add_custom_target(doc COMMAND ${CMAKE_DOC_COMMAND})

include_directories(include)

add_subdirectory(src)
add_subdirectory(include)
