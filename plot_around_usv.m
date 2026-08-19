function plot_around_usv(play_info, gc, tm)
    %% Histogram of USV durations
    figure(1); clf;
    subplot(2,1,1)
    histogram(play_info.usv_duration,30)
    xlabel('Duration (s)')
    ylabel('count')
    title('USV segments')
    xlim([0 1.3])
    
    subplot(2,1,2)
    histogram(play_info.background_duration,30)
    xlabel('Duration (s)')
    ylabel('count')
    title('Background segments')
    xlim([0 1.3])
    
    %% Plot data following each played USV
    pre_time = 0.5;
    post_time = 2;
    
    usv_tm = play_info.posix(play_info.Type == 'USV');
    [fiber_usv, fiber_tm] = get_around_inds(gc, tm, usv_tm, pre_time, post_time);
    
    back_tm =  play_info.posix(play_info.Type ~= 'USV');
    fiber_back = get_around_inds(gc, tm, back_tm, pre_time, post_time);

    %
    figure(2); clf; hold on
    is_basline = fiber_tm<0;
    y =  zscore_subset(fiber_usv, is_basline);
    shadedErrorBar(fiber_tm, y, {@mean, @nan_sem}, 'lineprops', {'Color', 'b'})
    y =  zscore_subset(fiber_back, is_basline);
    shadedErrorBar(fiber_tm, y, {@mean, @nan_sem}, 'lineprops', {'Color', 'k'})
    xline(0,'--k')
    
    xlabel('Time (s)')
    ylabel('Zscored dF/F')
    xlabel('Time after USV start (s)')
 
    legend('USVs', 'Background control')

end