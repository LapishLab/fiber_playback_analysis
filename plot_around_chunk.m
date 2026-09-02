function plot_around_chunk(play_info, gc, tm, opt)
    arguments
        play_info
        gc
        tm
        opt.chunk_inds = 1
    end
    %% Get Chunk ON times
    if any('USV' == play_info.Type)
        inds = find_chunk_inds(play_info.Type, 'USV');
    else
        inds = 1:500:height(play_info);
    end
    chunk_time_usv = play_info.posix(inds);
        
    % %% Histogram of chunk durations
    % inds = find_chunk_inds(play_info.Type, 'background');
    % chunk_time_back = play_info.posix(inds);

    % figure(1); clf
    % subplot(2,1,1)
    % histogram(chunk_time_back-chunk_time_usv)
    % title('USV chunk')
    % xlabel('Duration (s)')
    % ylabel('Count')
    % 
    % subplot(2,1,2)
    % histogram(chunk_time_usv(2:end)-chunk_time_back(1:end-1))
    % title('Background chunk')
    % xlabel('Duration (s)')
    % ylabel('Count')
    %% Plot chunks of ON/OFF
    pre_time = 20;
    post_time = 20;
    t = chunk_time_usv(opt.chunk_inds); % Which chunks to plot. Maybe not first since it doesn't have a preceeding background

    [fiber_usv, fiber_tm] = get_around_inds(gc, tm, t, pre_time, post_time);
    %%
    figure(1); clf; hold on
    is_basline = fiber_tm<0;
    y = zscore_subset(fiber_usv, is_basline);
    if length(opt.chunk_inds)>1
        shadedErrorBar(fiber_tm, y, {@mean, @nan_sem}, 'lineprops', {'Color', 'b'})
    else
        plot(fiber_tm, y, 'Color', 'b')
    end
    xline(0,'--k')
    ylabel('Zscored dF/F')
    xlabel('Time (s)')
    xlabel('Time after USV chunk start (s)')

end


function inds = find_chunk_inds(data, pat)
    inds = find(diff(data==pat) == 1)+1;

    if data(1)==pat
        inds = [1; inds];
    end
end