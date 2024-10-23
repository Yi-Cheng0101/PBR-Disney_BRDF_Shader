rm -r -f build
mkdir build 
export GLM_INCLUDE_DIR=/Users/yicheng/Desktop/A3/glm
export GLFW_DIR=/Users/yicheng/Desktop/A3/glfw
export GLEW_DIR=/Users/yicheng/Desktop/A3/glew
export IMGUI_DIR=/Users/yicheng/Desktop/A3/imgui
cd build
cmake ..
make
./A3 ../resources
