extern vec3[3] palette1;
extern vec3[3] palette2;

vec4 effect(vec4 colour, Image texture, vec2 texture_coords, vec2 pixel_coords)
    {
		vec4 pixel = Texel(texture, texture_coords);
		
		number a = pixel.a;
		
		for (int i = 0; i < 3; i++)
		{
			if (pixel.rgb == palette1[i])
			{
				pixel = vec4(palette2[i],a);
				break;
			}
		}
		return pixel * colour;
	}