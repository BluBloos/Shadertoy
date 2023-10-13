float log_map( in vec2 z )
{
    // Basically, we just need to ask if after some
    // amount of iterations that the current
    // y value has been hit to within a specific radius.
    
    // x_(n+1) = x_n * r ( 1 - x_n)
    
    float r = z.x;
    float x = 0.5f * r * 0.5f; // start with half the population.

    // step 1 is to get the sequence reasonably far along.
    int i;
    for (i = 0; i < 256; i++)
    {
        x = x * r * ( 1.f - x);
    }
    
    // step 2 is to find if this particular pixel should
    // be lit.
    float s = 0.f;
    
    bool b = false;
    
    for (i = 0; i < 256; i++)
    {
        if ( abs(x - z.y) < 1e-3 )
        {
            s += 1.f;
            b = true;
        }
        x = x * r * ( 1.f - x);
    }
    
   // return float(s) / 256.0 ;
   return b ? 1.0f : 0.f;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float aspect = 1280.0 / 720.0;
    
    vec2 offset = vec2(0,0); // vec2(cos(iTime), sin(iTime));

    float scale = 4.0 / (1.0);
    float halfScale = scale / 2.0;

    vec2 uv = fragCoord / iResolution.xy;

    vec2 xy = uv * vec2(4.025f, 1.0);
                   
    // xy.y /= aspect;
    // xy -= offset;
                   
    float m = log_map(xy);
    
    vec3 col = vec3(0, 0, m);

    // Output to screen.
    fragColor = vec4(col,1.0);
}