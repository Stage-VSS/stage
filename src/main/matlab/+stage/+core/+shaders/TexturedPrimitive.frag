#version 330

in vec2 texCoord;
in vec2 maskCoord;

uniform vec4 color0;
uniform sampler2D texture0;
uniform sampler2D mask;

out vec4 color;

void main(void)
{
    vec4 texFrag = texture(texture0, texCoord);
    vec4 maskFrag = texture(mask, maskCoord);
    
    color.a = color0.a * texFrag.a * maskFrag.r;
    color.rgb = color0.rgb * texFrag.rgb;
}