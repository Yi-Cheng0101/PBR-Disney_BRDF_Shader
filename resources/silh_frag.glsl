#version 330 core

in vec3 cNor; // in camera space, 接收來自頂點着色器的數據
in vec3 cPos; // in camera space, 接收來自頂點着色器的數據

out vec4 fragColor; // 输出片段颜色

void main(){
    // 計算法線與視線方向的點積
    vec3 n, e, color;
    float d;
    n = normalize(cNor);
    e = normalize(-cPos);
    d = dot(n, e);
    
    // 基於點積決定顏色
    if(d < 0.3) 
        color = vec3(0.0, 0.0, 0.0); // 背光區域
    else 
        color = vec3(1.0, 1.0, 1.0); // 高光區域
    
    // 输出最終颜色
    fragColor = vec4(color, 1.0);
}
