function [tm, gc, iso] = load_synced_fiber(session_dir)
    %% Load fiber data
    fiber_path = wildcard_path(fullfile(session_dir, "fiber_*", "NAc_dlight*","NAc_dlight*"));
    photoData = TDTbin2mat(char(fiber_path));

    %% Extact out weird fiber data event structure
    photo_events = table();
    photo_events.time = photoData.epocs.PiSc.onset;
    photo_events.state = photoData.epocs.PiSc.data == 3; %On = 3, off = 4???
    
    %% Load Pi sync data
    gpio_path = wildcard_path(fullfile(session_dir, 'pi-data*','fiber01','gpio', '*.csv'));
    pi_events = readtable(gpio_path);
    pi_events.posix = posixtime(datetime(pi_events.Time, 'InputFormat', 'yyyyMMdd_HHmmss_SSSSSS'));
    
    %% Drop extra pi or fiber events
    %Plot diffs to determine how things line up
    figure(30); clf;
    

    nexttile; hold on
    plot(diff(pi_events.posix))
    plot(diff(photo_events.time))
    xlabel('Event number')
    ylabel('Time until next event (s)')
    legend('Pi', 'Fiber')
    title('before shift correction') 

    % Drop X number of sync points from both ends of the Pi sync to ensure
    % we can align some good chunk
    x = 5;
    pi_events = pi_events(x:end-x, :);

    dp = diff(pi_events.posix);
    df = diff(photo_events.time);
    [inds_p, inds_f] = shift_to_min_diff(dp,df);

    % min_l = min(height(pi_events), height(photo_events));
    pi_events = pi_events(inds_p, :);
    photo_events = photo_events(inds_f, :);

    nexttile; hold on
    plot(diff(pi_events.posix))
    plot(diff(photo_events.time))
    legend('Pi', 'Fiber')
    xlabel('Event number')
    ylabel('Time until next event (s)')
    title('after shift correction') 

    sgtitle('Aligning pi and fiber events')
    
    warning_thresh = 0.09; % Max allowable difference between Pi and Fiber event intervals
    if any(abs(diff(pi_events.posix)-diff(photo_events.time)) > warning_thresh)
        warning("Photo and Pi events have diffs greater than %d, something might not be matching up", warning_thresh)
    end
    
    %% Get the stream data
    gc = double(photoData.streams.x465A.data);
    iso = double(photoData.streams.x415A.data);
    fs_raw = photoData.streams.x465A.fs;

    %% Downsample streams
    fs = 40;
    [gc,tm] = downsample_from_fs(gc, fs_raw, fs);
    iso = downsample_from_fs(iso, fs_raw, fs);

    %% Trim bad data from the start of the streams
    figure(31); clf
    start = find_good_start(gc, fs);
    title('Trimming start')
    
    gc = gc(start:end);
    iso = iso(start:end);
    tm = tm(start:end);
    
    %% Preprocess fiber signal
    figure(32); clf
    [gc, iso] = preprocessFP_GCaMP(gc, iso, fs);
    
    %% Generate pi posix timestamps for fiber stream data
    tm = interp1(photo_events.time, pi_events.posix, tm, "linear", "extrap");
end

function ind = find_good_start(stream, fs)
    max_cut = min(fs*60*5, numel(stream));
    margin = fs*1;

    smth_stream = movmean(stream, round(1*fs)); % smooth over 1 second
    dev = movstd(smth_stream, round(5*fs)); % get std over 5 seconds
    dev = movmean(dev, round(10*fs)); %Smooth std over 10 seconds   
    
    ind = find(dev(1:round(max_cut))>5);
    if isempty(ind)
        ind = 1;
    else
        ind = ind(end);
    end
    
    ind = ind + round(margin);% jump forward by margin
    
    %plotting
    tm = linspace(0, numel(stream)/fs, numel(stream));
    plot(tm, stream); hold on
    scatter(tm(ind), stream(ind), '*r')
end

function [inds_a, inds_b] = shift_to_min_diff(a,b)
    na = numel(a);
    nb = numel(b);
    if na == nb
        inds_a = 1:na;
        inds_b = 1:nb;
    elseif na < nb
        inds_a = 1:na;
        inds_b = perform_shifts(a, b);
    elseif nb < na
        inds_b = 1:nb;
        inds_a = perform_shifts(b, a);
    end
end

function inds_stationary = perform_shifts(shift, stationary)
    n_steps = numel(stationary) - numel(shift);
    abs_diff = nan(n_steps,1);
    
    for i=1:n_steps
        abs_diff(i) = sum(abs(stationary(i: i+numel(shift)-1) - shift));
    end
    [~, best_shift] = min(abs_diff);
    inds_stationary = (1:numel(shift)) + best_shift - 1;
end