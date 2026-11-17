
// source: https://thebookofshaders.com/07/
float circle(in float2 _st, in float _radius){
    float2 dist = _st-float2(0.5,0.5);
	return 1.-smoothstep(_radius-(_radius*0.01),
                         _radius+(_radius*0.01),
                         dot(dist,dist)*4.0);
}

// source: https://thebookofshaders.com/07/
float polar(in float2 _st, in float amount)
{
    float2 pos = float2(0.5,0.5)-_st;

    float r = length(pos)*2.0;
    float a = atan2(pos.y,pos.x);

    float f = cos(a*amount);
    // f = abs(cos(a*3.));
    // f = abs(cos(a*2.5))*.5+.3;
    // f = abs(cos(a*12.)*sin(a*3.))*.8+.1;
    // f = smoothstep(-.5,1., cos(a*10.))*0.2+0.5;
	//color = vec3(f,f,f);
    //color = vec3( 1.-smoothstep(f,f+0.02,r) );
    return 1.-smoothstep(f,f+0.02,r);
    //return f;
}

// source: https://thebookofshaders.com/07/
float triangle1(in float2 _st)
{
    float d = 0.0;

    // Remap the space to -1. to 1.
    _st = _st *2.-1.;

    // Number of sides of your shape
    int N = 3;

    // Angle and radius from the current pixel
    float a = atan2(_st.x,_st.y)+UNITY_PI;
    float r = UNITY_TWO_PI/float(N);

    // Shaping function that modulate the distance
    d = cos(floor(.5+a/r)*r-a)*length(_st);
    //return d;

    return 1.0-smoothstep(.4,.41,d);
}

// source: https://thebookofshaders.com/07/
float circle2(in float2 _st, in float radius, in float smooth)
{
    float pct = 0.0;

    // a. The DISTANCE from the pixel to the center
    pct = distance(_st,float2(0.5,0.5));

    // b. The LENGTH of the vector
    //    from the pixel to the center
    //vec2 toCenter = vec2(0.5)-st;
    //pct = length(toCenter);

    // c. The SQUARE ROOT of the vector
    //    from the pixel to the center
    //vec2 tC = vec2(0.5)-st;
    //pct = sqrt(tC.x*tC.x+tC.y*tC.y);

    //return pct;
    return 1.0-smoothstep(min(radius,smooth),radius,pct);
}

float wave(in float2 _st, in float frequency, in float amplitude, in float time)
{
    float dist = distance(_st.xy, float2(0.5,0.5));
    float wave = sin(dist * frequency - time);
    return wave * amplitude;
}
            
// source: GPU Particles by RED_SIM
float wobble(in float _st, in float amplitude, in float frequency, in float time)
{
    float wobFreq = max(frequency, 0.0);
    return sin(time * wobFreq + 1 * UNITY_PI) * amplitude;
}