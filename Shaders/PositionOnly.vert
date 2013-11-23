#version 330

layout(location=0) in vec4 position;

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;

void main(void)
{
    gl_Position = projectionMatrix * modelViewMatrix * position;
}