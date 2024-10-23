#version 330 core

in vec3 color;   // 接收頂點著色器傳遞過來的顏色

out vec4 fragColor;  // 用來輸出片段顏色

void main()
{
    fragColor = vec4(color, 1.0);  // 將顏色輸出
}
