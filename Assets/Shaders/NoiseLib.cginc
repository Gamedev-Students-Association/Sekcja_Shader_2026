#define NOISE_LIB

//-------------------------------
//noise functions

float RemapNoise(float noise)
{
    return (noise + 1) / 2;
}

float PseudoRand(float2 uv)
{
    return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
}

float3 hash(float3 p)
{ // replace this by something better
    p = float3(dot(p, float3(127.1, 311.7, 74.7)),
        dot(p, float3(269.5, 183.3, 246.1)),
        dot(p, float3(113.5, 271.9, 124.6)));
    return -1.0 + 2.0 * frac(sin(p) * 43758.5453123);
}

float2 hash(float2 p)
{
    p = float2(dot(p, float2(127.1, 311.7)), dot(p, float2(269.5, 183.3)));
    return -1.0 + 2.0 * frac(sin(p) * 43758.5453123);
}

/* discontinuous pseudorandom uniformly distributed in [-0.5, +0.5]^3 */
float3 hashV2(float3 c)
{
	float j = 4096.0 * sin(dot(c, float3(17.0, 59.4, 15.0)));
	float3 r;
	r.z = frac(512.0 * j);
	j *= .125;
	r.x = frac(512.0 * j);
	j *= .125;
	r.y = frac(512.0 * j);
	return r - 0.5;
}

float GradientNoise(in float3 p)
{
    float3 i = floor(p);
    float3 f = frac(p);
    float3 u = f * f * (3.0 - 2.0 * f);
    return lerp(lerp(lerp(dot(hash(i + float3(0.0, 0.0, 0.0)), f - float3(0.0, 0.0, 0.0)),
        dot(hash(i + float3(1.0, 0.0, 0.0)), f - float3(1.0, 0.0, 0.0)), u.x),
        lerp(dot(hash(i + float3(0.0, 1.0, 0.0)), f - float3(0.0, 1.0, 0.0)),
            dot(hash(i + float3(1.0, 1.0, 0.0)), f - float3(1.0, 1.0, 0.0)), u.x), u.y),
        lerp(lerp(dot(hash(i + float3(0.0, 0.0, 1.0)), f - float3(0.0, 0.0, 1.0)),
            dot(hash(i + float3(1.0, 0.0, 1.0)), f - float3(1.0, 0.0, 1.0)), u.x),
            lerp(dot(hash(i + float3(0.0, 1.0, 1.0)), f - float3(0.0, 1.0, 1.0)),
                dot(hash(i + float3(1.0, 1.0, 1.0)), f - float3(1.0, 1.0, 1.0)), u.x), u.y), u.z);
}

float GradientNoiseLooped(in float3 p, in float3 s)
{
    float3 i = floor(p);
    float3 f = frac(p);
    float3 u = f * f * (3.0 - 2.0 * f);
    return lerp(lerp(lerp(dot(hash((i + float3(0.0, 0.0, 0.0)) % s), (f - float3(0.0, 0.0, 0.0)) % s),
        dot(hash((i + float3(1.0, 0.0, 0.0)) % s), (f - float3(1.0, 0.0, 0.0)) % s), u.x),
        lerp(dot(hash((i + float3(0.0, 1.0, 0.0)) % s), (f - float3(0.0, 1.0, 0.0)) % s),
            dot(hash((i + float3(1.0, 1.0, 0.0)) % s), (f - float3(1.0, 1.0, 0.0)) % s), u.x), u.y),
        lerp(lerp(dot(hash((i + float3(0.0, 0.0, 1.0)) % s), (f - float3(0.0, 0.0, 1.0)) % s),
            dot(hash((i + float3(1.0, 0.0, 1.0)) % s), (f - float3(1.0, 0.0, 1.0)) % s), u.x),
            lerp(dot(hash((i + float3(0.0, 1.0, 1.0)) % s), (f - float3(0.0, 1.0, 1.0)) % s),
                dot(hash((i + float3(1.0, 1.0, 1.0)) % s), (f - float3(1.0, 1.0, 1.0)) % s), u.x), u.y), u.z);
}

float PerlinNoise(float3 p)
{
    float3 pi = floor(p);
    float3 pf = p - pi;

    float3 w = pf * pf * (3.0 - 2.0 * pf);

    return 	lerp(
        lerp(
            lerp(dot(pf - float3(0, 0, 0), hash(pi + float3(0, 0, 0))),
                dot(pf - float3(1, 0, 0), hash(pi + float3(1, 0, 0))),
                w.x),
            lerp(dot(pf - float3(0, 0, 1), hash(pi + float3(0, 0, 1))),
                dot(pf - float3(1, 0, 1), hash(pi + float3(1, 0, 1))),
                w.x),
            w.z),
        lerp(
            lerp(dot(pf - float3(0, 1, 0), hash(pi + float3(0, 1, 0))),
                dot(pf - float3(1, 1, 0), hash(pi + float3(1, 1, 0))),
                w.x),
            lerp(dot(pf - float3(0, 1, 1), hash(pi + float3(0, 1, 1))),
                dot(pf - float3(1, 1, 1), hash(pi + float3(1, 1, 1))),
                w.x),
            w.z),
        w.y);
}

float CloudNoise2D(in float3 p)
{
    const float K1 = 0.366025404; // (sqrt(3)-1)/2;
    const float K2 = 0.211324865; // (3-sqrt(3))/6;

    float2  i = floor(p + (p.x + p.y) * K1);
    float2  a = p - i + (i.x + i.y) * K2;
    float m = step(a.y, a.x);
    float2  o = float2(m, 1.0 - m);
    float2  b = a - o + K2;
    float2  c = a - 1.0 + 2.0 * K2;
    float3  h = max(0.5 - float3(dot(a, a), dot(b, b), dot(c, c)), 0.0);
    float3  n = h * h * h * h * float3(dot(a, hash(i + 0.0)), dot(b, hash(i + o)), dot(c, hash(i + 1.0)));
    return dot(n, float3(70.0, 70.0, 70.0));
}

float3 WhiteNoise3d(float3 data, float3 seed)
{
    return float3(PseudoRand(float2(data.x, seed.x)), PseudoRand(float2(data.y, seed.y)), PseudoRand(float2(data.z, seed.z)));
}

float3 LinearCombineNoise(float3 pos, float3 seed)
{
    return WhiteNoise3d(float3((pos.x * pos.y) % pos.z, (pos.y * pos.z) % pos.x, (pos.z * pos.x) % pos.y), seed);
}

float2 WhiteNoise2d(float2 data, float2 seed)
{
    return float2(PseudoRand(float2(data.x, seed.x)), PseudoRand(float2(data.y, seed.y)));
}

float2 LinearCombineNoise2d(float2 pos, float2 seed)
{
    return WhiteNoise2d(float2((pos.x * pos.y) * pos.y, (pos.x * pos.y) * pos.x), seed);
}

const float F3 = 0.3333333;
const float G3 = 0.1666667;

float SimplexNoise(float3 p)
{
	/* 1. find current tetrahedron T and it's four vertices */
	/* s, s+i1, s+i2, s+1.0 - absolute skewed (integer) coordinates of T vertices */
	/* x, x1, x2, x3 - unskewed coordinates of p relative to each of T vertices*/

	/* calculate s and x */
	float3 s = floor(p + dot(p, float3(F3, F3, F3)));
	float3 x = p - s + dot(s, float3(G3, G3, G3));

	/* calculate i1 and i2 */
	float3 e = step(float3(0.0, 0.0, 0.0), x - x.yzx);
	float3 i1 = e * (1.0 - e.zxy);
	float3 i2 = 1.0 - e.zxy * (1.0 - e);

	/* x1, x2, x3 */
	float3 x1 = x - i1 + G3;
	float3 x2 = x - i2 + 2.0 * G3;
	float3 x3 = x - 1.0 + 3.0 * G3;

	/* 2. find four surflets and store them in d */
	float4 w, d;

	/* calculate surflet weights */
	w.x = dot(x, x);
	w.y = dot(x1, x1);
	w.z = dot(x2, x2);
	w.w = dot(x3, x3);

	/* w fades from 0.6 at the center of the surflet to 0.0 at the margin */
	w = max(0.6 - w, 0.0);

	/* calculate surflet components */
	d.x = dot(hash(s), x);
	d.y = dot(hash(s + i1), x1);
	d.z = dot(hash(s + i2), x2);
	d.w = dot(hash(s + 1.0), x3);

	/* multiply d by w^4 */
	w *= w;
	w *= w;
	d *= w;

	/* 3. return the sum of the four surflets */
	return dot(d, float4(52.0, 52.0, 52.0, 52.0));
}