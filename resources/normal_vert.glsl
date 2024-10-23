#version 330 core

uniform mat4 P;
uniform mat4 MV;

in vec4 aPos;    // 將 attribute 替換為 in
in vec3 aNor;    // 將 attribute 替換為 in

out vec3 color;  // 將 varying 替換為 out，傳遞給片段著色器

void main()
{
    // 將頂點位置進行縮放和平移
    vec4 scaledAndTranslatedPos = vec4(aPos.xyz * 0.5 + vec3(0.0, -0.5, 0.0), aPos.w);

    // 將頂點位置轉換到 clip 空間
    gl_Position = P * (MV * scaledAndTranslatedPos);

    // 根據法線計算顏色
    color = 0.5 * aNor + vec3(0.5, 0.5, 0.5);
}

