#version 330 core

uniform mat4 P;    // Projection matrix
uniform mat4 MV;   // ModelView matrix
uniform mat4 MVit; // Inverse transpose of the MV matrix for normals

in vec4 aPos; // in object space (替換 attribute 為 in)
in vec3 aNor; // in object space (替換 attribute 為 in)

// add the varying members for camera space
out vec3 cNor; // in camera space (使用 out 替換 varying)
out vec3 cPos; // in camera space (使用 out 替換 varying)

void main()
{
	// Transform the vertex position from object space to camera space
    cPos = vec3(MV * aPos);

    // Transform the normal vector into camera space using the inverse-transpose of the MV matrix
    cNor = normalize(vec3(MVit * vec4(aNor, 0.0)));

    // Transform the vertex position into clip space for rendering
    gl_Position = P * (MV * aPos);
}
