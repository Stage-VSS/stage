#version 330

layout(location=0) in vec4 position;
layout(location=1) in vec2 texCoord0;
layout(location=2) in vec2 maskCoord0;

out vec2 texCoord;
out vec2 maskCoord;

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;

void main(void)
{
    gl_Position = projectionMatrix * modelViewMatrix * position;
    texCoord = texCoord0;
    maskCoord = maskCoord0;
}