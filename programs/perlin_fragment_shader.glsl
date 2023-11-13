#version 430

//Output variables
out vec4 fragColor;

//Input variables
uniform vec2 resolution;
uniform float time;

/*--------------------*/ 
/*  Helper functions  */
/*--------------------*/ 

//Pseudo random generator taken from https://stackoverflow.com/questions/4200224/random-noise-functions-for-glsl
float rand(vec2 in_vec){
    return fract( sin(dot(in_vec, vec2(12.9898, 78.233))) * 43758.5453);
}

// Perlin noise functions based on the
// wikipedia webpage

//cubic interpolator
float interpolate(float a0 , float a1, float w){
    return (a1 - a0) * ((w * (w * 6.0 - 15.0) + 10.0) * w * w * w) + a0;
} 

//Random gradient generator
vec2 randomGradient(int ix, int iy, int w, float t, float rate){

    int a = ix , b = iy;
    int s = int(w/2.0);
    
    a *= 3284157443; b ^= a << s | a >> w-s;
    b *= 1911520717; a ^= b << s | b >> w-s;
    a *= 2048419325;
    
    //float random = a * (3.14159265 / ~(~0u >> 1)); // in [0, 2*Pi]
    float random = rand(vec2(float(ix),float(iy)));
    
    return vec2(cos(rate*t*random),sin(rate*t*random));
}

//Dot product
float dotGridGradient(int ix, int iy, float x, float y, int w, float t, float rate){

    vec2 gradient = randomGradient(ix, iy, w, t, rate);

    float dx = x - float(ix);
    float dy = y - float(iy);

    return dx*gradient.x + dy*gradient.y;
}

//Perlin noise calculator
float perlin_noise(float x, float y, int w, float t, float rate){

    //Define grid points
    int x0 = int(floor(x));
    int x1 = x0 + 1;
    int y0 = int(floor(y));
    int y1 = y0 + 1;

    //Distance from grid point
    float sx = x - float(x0);
    float sy = y - float(y0);

    //Define gradient vectors and dot product
    float n0, n1, ix0, ix1;
    
    n0  = dotGridGradient(x0,y0, x, y, w, t, rate);
    n1  = dotGridGradient(x1,y0, x, y, w, t, rate);
    ix0 = interpolate(n0,n1,sx);

    n0  = dotGridGradient(x0,y1, x, y, w, t, rate);
    n1  = dotGridGradient(x1,y1, x, y, w, t, rate);
    ix1 = interpolate(n0,n1,sx);

    return interpolate(ix0, ix1, sy);
}

/*--------------------*/ 
/*  Main loop         */
/*--------------------*/ 

void main(){
    
    vec2 uv  = (gl_FragCoord.xy - 0.5 * resolution.xy) / resolution.y;
    vec3 col = vec3(0.0, 0.0, 0.0);

    //Define basic colors
    vec3 c1 = vec3(0.2, 0.8, 0.9);
    vec3 c2 = vec3(0.0, 0.1451, 0.8);
    vec3 c3 = vec3(0.2, 0.8, 0.0);
    
    //Define amplitude
    float A = 5.0;
    float rate = 10;
    int w = 8*23;

    //col += perlin_noise(gl_FragCoord.x/10 , gl_FragCoord.y/10,)*vec3(0.2, 0.8, 0.9);
    col+= A*c1*perlin_noise(gl_FragCoord.x/10  , gl_FragCoord.y/10  ,w,time,rate);
    col+= A*c2*perlin_noise(gl_FragCoord.x/400 , gl_FragCoord.y/400 ,w,time,rate);
    col+= A*c3*perlin_noise(gl_FragCoord.x/400 , gl_FragCoord.y/400 ,w,time,rate);

    fragColor = vec4(col,1.0);
}