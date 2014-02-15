#version 330

in vec2 texCoord;
in vec2 maskCoord;

uniform vec4 color0;
uniform sampler2D texture0;
uniform sampler2D mask;
uniform sampler2D kernel;
uniform vec2 kernelSize;
uniform vec2 texture0Size;

out vec4 color;

void main(void)
{
    vec3 sum = vec3(0.0);
    
    for (float dy = 0; dy < kernelSize.y; dy++) 
    {
        float kernelY = dy / (kernelSize.y - 1);
        float texY = texCoord.y + ((dy - ((kernelSize.y - 1) / 2)) / (texture0Size.y - 1));
        
        for (float dx = 0; dx < kernelSize.x; dx++)
        {
            float kernelX = dx / (kernelSize.x - 1);
            float texX = texCoord.x + ((dx - ((kernelSize.x - 1) / 2)) / (texture0Size.x - 1));
            
            float kernelValue = texture(kernel, vec2(kernelX, kernelY)).r;
            vec3 texValue = texture(texture0, vec2(texX, texY)).rgb;
            
            sum += texValue * kernelValue;
        }
    }
    
    vec4 texFrag = texture(texture0, texCoord);
    vec4 maskFrag = texture(mask, maskCoord);
    
    color.a = color0.a * texFrag.a * maskFrag.r;
    color.rgb = color0.rgb * sum;
}