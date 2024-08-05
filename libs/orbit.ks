// some useful information:
// elipse equation: x^2/a^2 + y^2/b^2 = 1
// sma = a
// ecc = sqrt(1 - b^2/a^2)
// c = a * ecc // sma * ecc
// pe = a - c // sma - sma * ecc
// ap = a + c // sma + sma * ecc


runoncepath("0:libs/util.ks").
runoncepath("0:libs/math.ks").

function srf_lan {
    return abs_mod(body:rotationangle + ship:longitude).
}

function srf_lan_eta {
    local parameter lan.
    return (abs_mod(lan - srf_lan())/360) * body:rotationperiod.
}

// OLD ORBIT FUNCTIONS

// solar prime vector frame to local frame
// (vec) -> vec
function spv_to_local {
    local parameter spv. // vector in the solar prime vector reference frame
    local ang to spv_angle().
    return v(
        (cos(ang) * spv:x) + (-sin(ang) * spv:z),
        spv:y,
        (sin(ang) * spv:x) + (cos(ang) * spv:z)
    ).
}

// local frame to solar prime vector frame
// (vec) -> vec
function local_to_spv {
    local parameter local. // vector in the local reference frame
    local ang to -spv_angle().
    return v(
        (cos(ang) * local:x) + (-sin(ang) * local:z),
        local:y,
        (sin(ang) * local:x) + (cos(ang) * local:z)
    ).
}

// direction of the solar prime vector
// () -> scalar(deg)
function spv_angle {
    local spvcos to solarprimevector * V(1, 0, 0).
    local spvsin to solarprimevector * V(0, 0, 1).
    return arctan2(spvsin, spvcos).
}

// direction of ascending node
// (scalar) -> vec
function an_dir {
    local parameter lan. // longitude of ascending node
    return v(cos(lan),0,sin(lan)):normalized.
}

// direction of ascending node velocity vector
// (scalar, scalar, scalar, scalar) -> vec
function an_vel_dir {
    local parameter lan, aop, inc, ecc. // longitude of ascending node, argument of periapsis, inclination and eccentricity
    local ox to -sin(ta_ea(ecc, -aop)).
    local oy to sqrt(1 - (ecc^2))*cos(ta_ea(ecc, -aop)).
    return v(
        (ox*((cos(aop)*cos(lan)) - (sin(aop)*sin(lan)))) - (oy*((sin(aop)*cos(lan)) + (cos(aop)*sin(lan)))),
        sin(inc),
        (ox*((cos(aop)*sin(lan)) + (sin(aop)*cos(lan)))) + (oy*((cos(aop)*cos(lan)) - (sin(aop)*sin(lan))))
    ):normalized.
}

// direction of periapsis
// (scalar, scalar, scalar) -> vec
function pe_dir {
    local parameter lan, aop, inc. // longitude of ascending node, argument of periapsis and inclination
    return v(
        (cos(aop)*cos(lan)) - (sin(aop)*cos(inc)*sin(lan)),
        sin(aop)*sin(inc),
        (cos(aop)*sin(lan)) + (sin(aop)*cos(inc)*cos(lan))
    ):normalized.
}

function ap_dir {
    local parameter lan, aop, inc.
    return -pe_dir(lan, aop, inc).
}

// direction of periapsis velocity vector
// (scalar, scalar, scalar) -> vec
function pe_vel_dir {
    local parameter lan, aop, inc. // longitude of ascending node, argument of periapsis and inclination
    return v(
        -((sin(aop)*cos(lan)) + (cos(aop)*cos(inc)*sin(lan))),
        cos(aop)*sin(inc),
        (cos(aop)*cos(lan)*cos(inc)) - (sin(aop)*sin(lan))
    ):normalized.
}

function ap_vel_dir {
    local parameter lan, aop, inc.
    return -pe_vel_dir(lan, aop, inc).
}

// direction of true anomaly
// (scalar, scalar, scalar, scalar) -> vec
function ta_dir {
    local parameter lan, aop, inc, ta. // longitude of ascending node, argument of periapsis, inclination and true anomaly
    return v(
        (cos(ta)*((cos(aop)*cos(lan)) - (sin(aop)*cos(inc)*sin(lan)))) - (sin(ta)*((sin(aop)*cos(lan)) + (cos(aop)*cos(inc)*sin(lan)))),
        (cos(ta)*(sin(aop)*sin(inc))) + (sin(ta)*(cos(aop)*sin(inc))),
        (cos(ta)*((cos(aop)*sin(lan)) + (sin(aop)*cos(inc)*cos(lan)))) + (sin(ta)*((cos(aop)*cos(lan)*cos(inc)) - (sin(aop)*sin(lan))))
    ):normalized.
}

// direction of true anomaly velocity vector
// (scalar, scalar, scalar, scalar, scalar) -> vec
function ta_vel_dir {
    local parameter lan, aop, inc, ecc, ta. // longitude of ascending node, argument of periapsis, inclination, eccentricity and true anomaly
    local ox to -sin(ta_ea(ecc, ta)).
    local oy to sqrt(1 - (ecc^2))*cos(ta_ea(ecc, ta)).
    return v(
        (ox*((cos(aop)*cos(lan)) - (sin(aop)*cos(inc)*sin(lan)))) - (oy*((sin(aop)*cos(lan)) + (cos(aop)*cos(inc)*sin(lan)))),
        (ox*(sin(aop)*sin(inc))) + (oy*(cos(aop)*sin(inc))),
        (ox*((cos(aop)*sin(lan)) + (sin(aop)*cos(inc)*cos(lan)))) + (oy*((cos(aop)*cos(lan)*cos(inc)) - (sin(aop)*sin(lan))))
    ):normalized.
}

// radius at true anomaly
// (scalar, scalar, scalar) -> scalar
function ta_alt {
    local parameter sma, ecc, ta. // semi major axis, eccentricity and true anomaly
    return sma*((1-(ecc^2))/(1+(ecc*cos(ta)))).
}

// velocity at true anomaly
// (scalar, scalar, scalar, scalar) -> scalar
function ta_vel {
    local parameter mu, sma, ecc, ta. // body mu, semi major axis, eccentricity and true anomaly
    return vis_viva(mu, ta_alt(sma, ecc, ta), sma).
}

// eccentric anomaly at true anomaly
// (scalar, scalar) -> scalar
function ta_ea {
    local parameter ecc, ta. // eccentricity and true anomaly
    local eac to (ecc + cos(ta)) / (1 + ecc*cos(ta)).
    local eas to (sqrt(1 - (ecc^2)) * sin(ta)) / (1 + ecc*cos(ta)).
    return utl_cstoa(eac, eas).
}

// mean anomaly at true anomaly
// (scalar, scalar) -> scalar
function ta_ma {
    local parameter ecc, ta. // eccentricity and true anomaly
    local ea to ta_ea(ecc, ta).
    return ea - (ecc*sin(ea)*constant:radtodeg).
}

// time to true anomaly
// (scalar, scalar, scalar, scalar, scalar) -> scalar
function ta_eta {
    local parameter mu, sma, ecc, ta0, ta. // body mu, semi major axis, eccentricity, initial true anomaly and target true anomaly
    local n to 360/period(mu, sma).
    local ma0 to ta_ma(ecc, ta0).
    local ma to ta_ma(ecc, ta).
    return ((choose ma if ma >= ma0 else ma + 360) - ma0) / n.
}

// vis viva equation
// (scalar, scalar, scalar) -> scalar
function vis_viva {
    local parameter mu, d, sma. // body mu, distance from body center and semi major axis
    return sqrt(mu*((2/d) - (1/sma))).
}

// orbit period
// (scalar, scalar) -> scalar
function period {
    local parameter mu, sma. // body mu and semi major axis
    return (2*constant:pi*sma)/sqrt(mu/sma).
}

// true anomaly at altitude
// (scalar, scalar, scalar) -> scalar
// ATTENTION: RETURNS NONSENSE IF ALTITUDE IS OUT OF BOUNDS [periapsis, apoapsis]. USE CAREFULLY
function alt_ta {
    local parameter sma, ecc, rad. // semi major axis, eccentricity and altitude
    local ta_cos to ((sma-(sma*(ecc^2)))-rad)/(ecc*rad).
    set ta_cos to clamp(ta_cos, -1, 1).
    return arccos(ta_cos).
}

//function alt_ta {
    //local parameter sma, ecc, rad. // semi major axis, eccentricity and altitude
    //local ta_cos to ((sma-(sma*(ecc^2)))-rad)/(ecc*rad).
    //if (ta_cos > 1) {
        //set ta_cos to 1.
    //} else if (ta_cos < -1) {
        //set ta_cos to -1.
    //}
    //set ta_cos to clamp(ta_cos, -1, 1).
    //return arccos(ta_cos).
//}