//Linus Neuman @ love2d forums
uniform float _AberrationOffset = 0.1f;

vec4 effect(vec4 col, Image texture, vec2 texturePos, vec2 screenPos)
{
    vec2 coords = texturePos;

	vec4 pixel = texture2D(texture, texturePos);
    //Red Channel
    vec4 red = texture2D(texture , coords - _AberrationOffset);
    //Green Channel
    vec4 green = texture2D(texture, coords);
    //Blue Channel
    vec4 blue = texture2D(texture, coords + _AberrationOffset);

    vec4 finalColor = vec4(red.r, green.g, blue.b, pixel.a);
    return finalColor;
}