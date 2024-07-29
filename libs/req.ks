// rocket equations

function flow_rate {
    parameter isp, f.
    return f / (isp * constant:g0).
}

function burn_time {
    parameter isp, f, m.
    return m / flow_rate(isp, f).
}

function dry_mass {
    parameter dv, isp, m0.
    return m0 / constant:e^(dv / (isp * constant:g0)).
}

function delta_v {
    parameter isp, m0, mf.
    return (isp * constant:g0) * ln(m0 / mf).
}