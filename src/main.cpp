#include <cassert>
#include <cstring>
#define _USE_MATH_DEFINES
#include <cmath>
#include <iostream>

#define GLEW_STATIC
#include <GL/glew.h>
#include <GLFW/glfw3.h>

#define GLM_FORCE_RADIANS
#include <glm/glm.hpp>

#include "imgui.h"
#include "imgui_impl_glfw_gl3.h"
#include "Camera.h"
#include "GLSL.h"
#include "MatrixStack.h"
#include "Program.h"
#include "Shape.h"

using namespace std;
using namespace glm;

GLFWwindow *window; // Main application window

int add_t = 0;
bool OFFLINE = false;
string RESOURCE_DIR = "./"; // Where the resources are loaded from

bool keyToggles[256] = {false}; // only for English keyboards!


shared_ptr<Camera> camera;
shared_ptr<Program> prog;

struct Light{
	vec3 lightPos;
	vec3 lightColor;
};


struct Material{
	vec3 ka;
	vec3 kd;
	vec3 ks;
	float s;
};


// This function is called when a GLFW error occurs
static void error_callback(int error, const char *description)
{
	cerr << description << endl;
}

// This function is called when a key is pressed
static void key_callback(GLFWwindow *window, int key, int scancode, int action, int mods)
{
	if(key == GLFW_KEY_ESCAPE && action == GLFW_PRESS) {
		glfwSetWindowShouldClose(window, GL_TRUE);
	}
}

// This function is called when the mouse is clicked
static void mouse_button_callback(GLFWwindow *window, int button, int action, int mods)
{
	// Do nothing for now
}

// This function is called when the mouse moves
static void cursor_position_callback(GLFWwindow* window, double xmouse, double ymouse)
{
	// Do nothing for now
}

static void char_callback(GLFWwindow *window, unsigned int key)
{
	keyToggles[key] = !keyToggles[key];
}

// If the window is resized, capture the new size and reset the viewport
static void resize_callback(GLFWwindow *window, int width, int height)
{
	glViewport(0, 0, width, height);
}

// This function is called once to initialize the scene and OpenGL
static void init()
{
	// Set background color.
	glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
}

// This function is called every frame to draw the scene.
static void render()
{
	// Clear framebuffer.
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

float some_float[4] = {0.0f, 0.0f, 0.0f, 0.0f};  // Initialize the float variable
bool show_window = false;  // Boolean variable to bind with the checkbox
float color[4] = {1.0f, 0.0f, 0.0f, 1.0f};  // Initialize the color variable (RGBA)

// Setup ImGui binding and context
void setupImGui() {
    ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO(); (void)io;
    
    // Initialize ImGui with GLFW + OpenGL3 backend
    ImGui_ImplGlfwGL3_Init(window, true);  // true: install callbacks, false if you handle them yourself
    
    // Setup ImGui style (optional)
    ImGui::StyleColorsDark();  // Dark theme
}

void renderImGui() {
    // Start the ImGui frame
    ImGui_ImplGlfwGL3_NewFrame();

    // Create ImGui windows here
    ImGui::Begin("ImGui Window");  // Create an ImGui window
    ImGui::Text("Hello from ImGui!");  // Example text
    ImGui::SliderFloat("Float slider", some_float, 0.0f, 1.0f);  // Example slider
	ImGui::SliderFloat("Foat slider", some_float+1, 0.0f, 1.0f);  // Example slider
	ImGui::SliderFloat("Fat slider", some_float+2, 0.0f, 1.0f);  // Example slider
	ImGui::SliderFloat("Float slider", some_float+3, 0.0f, 1.0f);  // Example slider
	ImGui::ColorEdit4("Choose Color (RGBA)", color);
	ImGui::Checkbox("Show Window", &show_window);
	
    ImGui::End();  // End ImGui window

    // Render ImGui draw data
    ImGui::Render();
    ImGui_ImplGlfwGL3_RenderDrawData(ImGui::GetDrawData());
}

int main(int argc, char **argv)
{
	// Set error callback.
	glfwSetErrorCallback(error_callback);
	// Initialize the library.
	if(!glfwInit()) {
		return -1;
	}

	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
	glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
	glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
	#ifdef __APPLE__
		glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);  
	#endif

	// Create a windowed mode window and its OpenGL context.
	window = glfwCreateWindow(640, 480, "ImGui Only Window", NULL, NULL);
	if(!window) {
		glfwTerminate();
		return -1;
	}
	// Make the window's context current.
	glfwMakeContextCurrent(window);
	// Initialize GLEW.
	glewExperimental = true;
	if(glewInit() != GLEW_OK) {
		cerr << "Failed to initialize GLEW" << endl;
		return -1;
	}
	glGetError(); // A bug in glewInit() causes an error that we can safely ignore.
	cout << "OpenGL version: " << glGetString(GL_VERSION) << endl;
	cout << "GLSL version: " << glGetString(GL_SHADING_LANGUAGE_VERSION) << endl;
	// Set vsync.
	glfwSwapInterval(1);

	// Set up ImGui
    setupImGui();

	// Set keyboard callback.
	glfwSetKeyCallback(window, key_callback);
	// Set char callback.
	glfwSetCharCallback(window, char_callback);
	// Set cursor position callback.
	glfwSetCursorPosCallback(window, cursor_position_callback);
	// Set mouse button callback.
	glfwSetMouseButtonCallback(window, mouse_button_callback);
	// Set the window resize call back.
	glfwSetFramebufferSizeCallback(window, resize_callback);
	// Initialize scene.
	init();
	// Loop until the user closes the window.
	while(!glfwWindowShouldClose(window)) {
		// Render scene.
		render();

		// Render ImGui (ImGui rendering)
        renderImGui();

		// Swap front and back buffers.
		glfwSwapBuffers(window);
		// Poll for and process events.
		glfwPollEvents();
	}

	// Cleanup ImGui before quitting
    ImGui_ImplGlfwGL3_Shutdown();
    ImGui::DestroyContext();
	
	// Quit program.
	glfwDestroyWindow(window);
	glfwTerminate();
	return 0;
}

/*


void initParameter(){

	lights[0].lightPos = vec3(1.0, 1.0, 1.0);
	lights[0].lightColor = vec3(0.8, 0.8, 0.8);

	lights[1].lightPos = vec3(-1.0, 1.0, 1.0);
	lights[1].lightColor = vec3(0.2, 0.2, 0.0);

	materials[0].ka = vec3(0.2, 0.2, 0.2);
	materials[0].kd = vec3(0.8, 0.7, 0.7);
	materials[0].ks = vec3(1.0, 0.9, 0.8);
	materials[0].s  = 200;

	materials[1].ka = vec3(0.1, 0.1, 0.1);
	materials[1].kd = vec3(0.1, 0.1, 1.0);
	materials[1].ks = vec3(0.1, 1.0, 0.1);
	materials[1].s  = 100;

	materials[2].ka = vec3(0.1, 0.1, 0.1);
	materials[2].kd = vec3(0.5, 0.5, 0.7);
	materials[2].ks = vec3(0.1, 0.1, 0.1);
	materials[2].s  = 200;
	return ;
}*/