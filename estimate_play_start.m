function start = estimate_play_start(audio_pi, sr_pi)
    %restrict to first 20 minutes of audio
    audio_pi = audio_pi(1:sr_pi*20*60);
    
    windowLength=10*sr_pi;
    rms = sqrt(movmean(audio_pi.^2, windowLength));
    
    dec_factor = floor(windowLength/10);
    new_sr = sr_pi / dec_factor;
    
    rms = rms(1:dec_factor:end);
    thresh = mean(prctile(rms, [0,40]));
    t = linspace(0, numel(rms)/new_sr, numel(rms));
    
    plot(t, rms)
    yline(thresh, '--')
    
    thresh_diff = diff(rms>thresh);
    on_t = t(thresh_diff==1);
    start = on_t(end);
end