#Author: Alexandros-Charalampos Kyprianidis
#Email: alexkypr.ece@gmail.com
#Last Changed: 30.05.2017
# Minimum version for CMake
cmake_minimum_required(VERSION 2.8)

# Project name.
project(Tracking)

#Set the output folder
set(CMAKE_BINARY_DIR ${CMAKE_SOURCE_DIR}/bin)
set(EXECUTABLE_OUTPUT_PATH ${CMAKE_BINARY_DIR})
set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR})
include_directories("${PROJECT_SOURCE_DIR}")
link_directories(${CMAKE_BINARY_DIR}/)

# C++ flags.
  if    (CMAKE_COMPILER_IS_GNUCXX)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=gnu++0x")
  else  (CMAKE_COMPILER_IS_GNUCXX)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
  endif (CMAKE_COMPILER_IS_GNUCXX)

  # OpenCV.
  find_package(OpenCV REQUIRED)
  find_package(CUDA REQUIRED)
  include_directories(SYSTEM ${OpenCV_INCLUDE_DIRS})
  include_directories(${CUDA_INCLUDE_DIRS})
  if    (${OpenCV_VERSION_MAJOR} VERSION_LESS 3)
    find_package(OpenCV REQUIRED core highgui imgproc)
  else  ()
    find_package(OpenCV REQUIRED core highgui imgproc videoio)
    add_definitions(-DOPENCV_3)
  endif (${OpenCV_VERSION_MAJOR} VERSION_LESS 3)


add_executable(myTest DetectTracking.cpp)
add_executable(myDemo DetectTrackingdemonstration.cpp)

target_link_libraries(
	myTest
 	vibe++
      ${OpenCV_LIBS}
      ${Boost_LIBRARIES}
)
target_link_libraries(
	myDemo
 	vibe++
      ${OpenCV_LIBS}
      ${Boost_LIBRARIES}
)



