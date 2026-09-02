function start = estimate_play_start(spect, sr)
    %restrict to first 10 minutes of audio
    spect = spect(:, 1:sr*10*60);
    
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