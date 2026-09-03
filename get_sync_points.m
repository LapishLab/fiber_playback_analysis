function file_sync = get_sync_points(spect_play, spect_pi, sr, start_est)
    approx_chunk_dur = 60;
    n_spect = round(approx_chunk_dur * sr);
    
    play_inds = 1:n_spect:width(spect_play);
    
    file_sync = table();
    i = (play_inds(1:end-1) + n_spect/2)/sr;
    file_sync.play = i(:);
    file_sync.pi = nan(size(file_sync.play));
    for i=1:height(file_sync)
        seg_inds = play_inds(i):play_inds(i+1);
        play_seg = spect_play(:, seg_inds);
    
        seg_inds = seg_inds + round(start_est*sr);
        if seg_inds(end) > width(spect_pi)
            break
        end
        pi_seg = spect_pi(:, seg_inds);
    
        figure(2); clf;
        t_offset = peak_offset(play_seg, pi_seg, sr);
        pause(0.1);
        file_sync.pi(i) = file_sync.play(i)+start_est-t_offset;
    end

end


function t_offset = peak_offset(play, pi, sr)
    rho = cell(height(play),1);

    trim_num = round(5*sr);
    max_lag = round(30*sr) + trim_num;
    for i=1:height(play)
        [rho{i}, lag] = xcorr(play(i,:), pi(i,:), max_lag, 'unbiased');
    end
    lag = lag / sr;
    rho = cat(1,rho{:});
    %%
    sr_lag = 1/diff(lag(1:2));
    rho_high = highpass(rho', 1, sr_lag)';

    lag = lag(trim_num:end-trim_num);
    rho_high = rho_high(:, trim_num:end-trim_num);

    rho_avg = mean(rho_high);
    [max_val, max_ind] = max(rho_avg);
    t_offset = lag(max_ind);

    %Plot
    shadedErrorBar(lag, rho_high, {@mean, @nan_sem})
    hold on
    scatter(t_offset,max_val, '*r')
    xline(0,'--k')
    xlabel('Lag time (s)')
    ylabel('Correlation')
end