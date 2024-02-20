// NOTE: some of the code was generated with AI. I didn't want to write some components since the purpose
// of this exercise was to understand the volumetric rendering tehcnique.

float R = 0.25;
vec3 mid = vec3(0.5,0.5,0.5);

// NOTE: written with AI.
float perlinNoise(vec2 point) {
    // Define lattice points
    vec2 p = floor(point);
    vec2 f = fract(point);
    
    // Interpolation function (could be improved with a smoother step function)
    f = f*f*(3.0-2.0*f);
    
    // Hash function to generate pseudo-random gradients
    float n = p.x + p.y * 57.0;
    vec2  gradients[4] = vec2[](vec2(1,0), vec2(-1,0), vec2(0,1), vec2(0,-1));
    float g00 = dot(gradients[int(mod(n, 4.0))], f - vec2(0,0));
    float g10 = dot(gradients[int(mod(n + 1.0, 4.0))], f - vec2(1,0));
    float g01 = dot(gradients[int(mod(n + 57.0, 4.0))], f - vec2(0,1));
    float g11 = dot(gradients[int(mod(n + 58.0, 4.0))], f - vec2(1,1));
    
    // Interpolate between gradients
    float gx0 = mix(g00, g10, f.x);
    float gx1 = mix(g01, g11, f.x);
    float gxy = mix(gx0, gx1, f.y);
    
    // Map result to [0, 1]
    return 0.5 * gxy + 0.5;
}


// NOTE: written with AI.
vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float angleBetweenVectors(vec3 v1, vec3 v2) {
    vec3 v1Norm = normalize(v1);
    vec3 v2Norm = normalize(v2);
    float dotProd = dot(v1Norm, v2Norm);
    dotProd = clamp(dotProd, -1.0, 1.0);
    return acos(dotProd);
}

float objectSdf(vec3 p)
{
    vec3 pp = p - mid;
    float x = abs(angleBetweenVectors( vec3(0.0,0.0,1.0), p));
    float k =50.0;
    float f=1.0;
    float sd = (R+sin(k*x-f*iTime)*R*0.1) - length(pp);
    return sd;
}

vec3 objectColor(vec3 p)
{
    vec3 pp = p - mid;
    float sr = length(pp)/R;

    float f=1.0;
    float noise = perlinNoise(p.xy * p.z*f); // 'scale' adjusts the noise frequency
    
    float hue = noise;// map to degrees
    // Convert HSV to RGB
    // Assuming full saturation (1.0) and value (1.0) for vivid colors
    vec3 color = hsv2rgb(vec3(hue*7.0, 1.0, 0.04));
    
    return color;    
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float aspect = iResolution.x / iResolution.y;

    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy * vec2(aspect,1.0);

    vec3 bgC = vec3(0.0, 0.0, 0.0);
    vec3 sC = vec3(1.0,0.0,0.0);
    float A = 1.0;
    vec3 C = vec3(0.0, 0.0,0.0);
    
    
    int count = 100;
    float rayStepLen = 1.0/float(count);
    
    for ( int i = (count-1); i >=0; i-- )
    {
        // there exists a sphere; that's what we're sampling.
        // and maybe there is a sinusoid on the radius of the sphere.
        // we'll assume there is a directional light right in front of cam.
        
        // NOTE: notice that we sample the [0,1] space in xyz.
        float z = rayStepLen*(float(i)+0.5); // sample the middle of the voxel.
        float x = uv.x;
        float y = uv.y;
        
        vec3 p = vec3(x,y,z);
        
        // we shall represent the object with an SDF.
        // at the core, the "solidness" of the object goes up; it's more opaque.
        // 
        float sd = objectSdf(p);
        
        C += objectColor(p) * A; // accumulate color.
        //C = objectColor(p);
        
        // negative outside, positive inside, and zero on surface.
        float Aj = max(0.0,sd/R*0.5);
        A = A * (1.0-Aj);
        
    }
    
    A = 1.0 - A;
    
    // NOTE: we perform in-house blending.
    fragColor = vec4(C*A+(1.0-A)*bgC, 1.0);
}
