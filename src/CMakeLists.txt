add_subdirectory(test)

#add_subdirectory(dir1)


add_executable(main main.c)                                                       
                                                                                  
#target_link_libraries(main lib1 lib2)

install(TARGETS main DESTINATION bin)
