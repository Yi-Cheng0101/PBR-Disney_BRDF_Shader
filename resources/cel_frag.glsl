#version 330 core

uniform vec3 lightPos;
uniform vec3 ka;
uniform vec3 kd;
uniform vec3 ks;
uniform float s;
uniform vec3 light0Pos;
uniform vec3 light1Pos;
uniform vec3 light0Color;
uniform vec3 light1Color;

in vec3 cNor; // in camera space, 接收自頂點着色器的數據
in vec3 cPos; // in camera space, 接收自頂點着色器的數據

out vec4 fragColor; // 使用 `out` 來指定片段着色器輸出顏色

vec3 set_color(vec3 color) {
    vec3 _color = vec3(0.0);
    for(int i = 0; i < 3; ++i) {
        if(color[i] < 0.25) {
            _color[i] = 0.0;
        } else if(color[i] < 0.5) {
            _color[i] = 0.25;
        } else if(color[i] < 0.75) {
            _color[i] = 0.5;
        } else if(color[i] < 1.0) {
            _color[i] = 0.75;
        } else {
            _color[i] = 1.0;
        }
    }
    return _color;
}

vec3 CalculateColor(vec3 _lightPos, vec3 _lightColor, vec3 _cNor, vec3 _cPos, vec3 _ka, vec3 _kd, vec3 _ks, float _s) {
    vec3 n, l, ca, cd, cs, c, h, e;
    
    // Compute the normals
    n = normalize(_cNor);
    l = normalize(_lightPos - _cPos);
    e = normalize(-_cPos); // Eye vector
    h = normalize(l + e);
    
    // Perform lighting computation
    ca = _ka; // Ambient color
    cd = _kd * max(0.0, dot(l, n));
    
    // Specular computation for Blinn-Phong
    float nh = max(0.0, dot(n, h));
    cs = _ks * pow(nh, _s);
    
    c = ca + cd + cs;
    return (_lightColor * c);
}

void main() {
    vec3 n, l, ca, cd, cs, c, h, e, color;
    
    // Compute the normals
    n = normalize(cNor);
    l = normalize(lightPos - cPos);
    e = normalize(-cPos); // Eye vector
    h = normalize(l + e);
    
    // Perform lighting computation
    ca = ka; // Ambient color
    cd = kd * max(0.0, dot(l, n));
    
    // Specular computation for Blinn-Phong
    float nh = max(0.0, dot(n, h));
    cs = ks * pow(nh, s);
    c = ca + cd + cs;
    
    // Calculate lighting from two lights
    color = CalculateColor(light0Pos, light0Color, cNor, cPos, ka, kd, ks, s);
    color += CalculateColor(light1Pos, light1Color, cNor, cPos, ka, kd, ks, s);
    
    // Quantize the final color
    c = set_color(color);
    
    // Output the final color
    fragColor = vec4(c, 1.0);
}
