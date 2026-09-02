function tm = gen_time(n, fs)
    dur = n/fs;
    tm = linspace(0, dur, n);
    tm = tm(:);
end