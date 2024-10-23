#version 330 core

// Silhouette shader

uniform mat4 P;      // Projection matrix
uniform mat4 MV;     // Model-View matrix
uniform mat4 MVit;   // Inverse transpose of the Model-View matrix for normals

in vec4 aPos;        // Vertex position in object space
in vec3 aNor;        // Vertex normal in object space

// Output variables to pass to the fragment shader
out vec3 cNor;       // Normal in camera space
out vec3 cPos;       // Position in camera space

void main() {
    // Transform vertex position into clip space
    gl_Position = P * (MV * aPos);

    // Transform normal into camera space using inverse-transpose matrix
    cNor = vec3(normalize(MVit * vec4(aNor, 0.0)));
    
    // Transform position into camera space
    cPos = vec3(MV * aPos);
}
