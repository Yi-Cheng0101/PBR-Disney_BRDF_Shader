#version 330 core

// PBR fragment shader

uniform vec3 lightPos;
uniform vec3 ka;
uniform vec3 kd;
uniform vec3 ks;
uniform float s;
uniform vec3 light0Pos;
uniform vec3 light1Pos;
uniform vec3 light0Color;
uniform vec3 light1Color;

// 接收頂點着色器傳遞過來的變量
in vec3 cNor;
in vec3 cPos;

// Camera position
uniform vec3 camPos; // Camera position in world space

// Material properties
uniform vec3 albedo;      // Base color
uniform float metallic;   // Metallic factor
uniform float roughness;  // Roughness factor
uniform float ao;         // Ambient occlusion

out vec4 fragColor;  // 最終片段顏色

const float PI = 3.14159265359;

// Fresnel-Schlick approximation
vec3 fresnelSchlick(float cosTheta, vec3 F0) {
    return F0 + (1.0 - F0) * pow(1.0 - cosTheta, 5.0);
}

// GGX normal distribution function (NDF)
float DistributionGGX(vec3 N, vec3 H, float roughness) {
    float a = roughness * roughness;
    float a2 = a * a;
    float NdotH = max(dot(N, H), 0.0);
    float NdotH2 = NdotH * NdotH;

    float num = a2;
    float denom = (NdotH2 * (a2 - 1.0) + 1.0);
    denom = PI * denom * denom;

    return num / denom;
}

// Geometry function for GGX
float GeometrySchlickGGX(float NdotV, float roughness) {
    float r = (roughness + 1.0);
    float k = (r * r) / 8.0;

    float num = NdotV;
    float denom = NdotV * (1.0 - k) + k;

    return num / denom;
}

// Smith's method to calculate geometry
float GeometrySmith(vec3 N, vec3 V, vec3 L, float roughness) {
    float NdotV = max(dot(N, V), 0.0);
    float NdotL = max(dot(N, L), 0.0);
    float ggx1 = GeometrySchlickGGX(NdotV, roughness);
    float ggx2 = GeometrySchlickGGX(NdotL, roughness);
    return ggx1 * ggx2;
}

// PBR lighting function
vec3 PBRLighting(vec3 N, vec3 V, vec3 L, vec3 lightColor, vec3 albedo, float metallic, float roughness, vec3 F0) {
    vec3 H = normalize(V + L);
    float distance = length(L);
    float attenuation = 1.0 / (distance * distance);
    vec3 radiance = lightColor * attenuation;

    // Cook-Torrance BRDF
    float NDF = DistributionGGX(N, H, roughness); // Normal Distribution Function
    float G = GeometrySmith(N, V, L, roughness);  // Geometry function
    vec3 F = fresnelSchlick(max(dot(H, V), 0.0), F0); // Fresnel term

    vec3 nominator = NDF * G * F;
    float denominator = 4.0 * max(dot(N, V), 0.0) * max(dot(N, L), 0.0) + 0.001; // Avoid divide by zero
    vec3 specular = nominator / denominator;

    // kS is the specular amount and kD is the diffuse amount
    vec3 kS = F;
    vec3 kD = vec3(1.0) - kS;
    kD *= 1.0 - metallic;

    // Lambertian diffuse reflection
    float NdotL = max(dot(N, L), 0.0);
    vec3 diffuse = kD * albedo / PI;

    // Combine diffuse and specular lighting
    return (diffuse + specular) * radiance * NdotL;
}

void main() 
{
    // Material properties
    vec3 F0 = vec3(0.04); // Default reflection for non-metals
    F0 = mix(F0, albedo, metallic);

    // Normalize inputs
    vec3 N = normalize(cNor);
    vec3 V = normalize(camPos - cPos);

    // Calculate PBR lighting for each light source
    vec3 L0 = normalize(light0Pos - cPos);
    vec3 L1 = normalize(light1Pos - cPos);
    vec3 color0 = PBRLighting(N, V, L0, light0Color, albedo, metallic, roughness, F0);
    vec3 color1 = PBRLighting(N, V, L1, light1Color, albedo, metallic, roughness, F0);

    // Combine both light sources and add ambient lighting
    vec3 ambient = albedo * 0.03 * ao;
    vec3 finalColor = ambient + color0 + color1;

    // Gamma correction
    finalColor = pow(finalColor, vec3(1.0 / 2.2));

    fragColor = vec4(finalColor, 1.0);
}
