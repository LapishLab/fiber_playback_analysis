function start = estimate_play_start(spect, sr)
    %restrict to first 10 minutes of audio
    max_t = sr*10*60;
    max_t = min(max_t, width(spect));
    spect = spect(:, 1:max_t);
    
    windowLength=30*sr;
    y = movmedian(mean(spect), windowLength);
    
    thresh = mean(prctile(y, [0,50]));
    t = gen_time(numel(y), sr);
    
    thresh_diff = diff(y>thresh);
    on_t = t(thresh_diff==1);
    start = on_t(end);

    clf; hold on
    plot(t, y)
    yline(thresh, '--')
    scatter(start, thresh, "*")
end