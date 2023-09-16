float mandelbrot( in vec2 c )
{
    vec2 z = vec2(0,0);

    int i;
    for (i = 0; i < 512; i++)
    {
        z = vec2( z.x * z.x - z.y * z.y,
                  2.0 * z.x * z.y ); // square.
        z += c;
        
        // check if divergent.
        if ( (z.x > 2.0 || z.y > 2.0) )
            break;
    }
    
    if ( i > 511 ) return 0.0;
    
    return float(i) / 25.0 ;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float aspect = 1280.0 / 720.0;
    
    vec2 offset = vec2(cos(iTime), sin(iTime));

    float scale = 4.0 / (1.0);
    float halfScale = scale / 2.0;

    vec2 uv = fragCoord / iResolution.xy;
    vec2 xy = uv * vec2(1.0 * scale, 1.0 * scale) - 
                   vec2(1.0 * halfScale, 1.0 * halfScale);
                   
    xy.y /= aspect;
    
    xy -= offset;
                   
    float m = mandelbrot(xy);
    
    vec3 col = vec3(0, 0, m);

    // Output to screen
    fragColor = vec4(col,1.0);
}