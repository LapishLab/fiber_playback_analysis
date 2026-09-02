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
    clf; hold on
    plot(diff(pi_events.posix))
    plot(diff(photo_events.time))
    
    min_l = min(height(pi_events), height(photo_events));
    pi_events = pi_events(1:min_l, :);
    photo_events = photo_events(1:min_l, :);
    
    warning_thresh = 0.5;
    if any(diff(pi_events.posix)-diff(photo_events.time) > warning_thresh)
        warning("Photo and Pi events have diffs greater than %d, something might not be matching up", warning_thresh)
    end
    
    %% Trim bad data from the start of the streams
    figure(31); clf
    start = find_good_start(gc, fs);
    title('Trimming start')
    
    gc = gc(start:end);
    iso = iso(start:end);
    tm = tm(start:end);
    
    %% Preprocess fiber signal
    gc = photoData.streams.x465A.data;
    iso = photoData.streams.x415A.data;
    fs = photoData.streams.x465A.fs;
    [gc, iso] = preprocessFP_GCaMP(gc, iso, fs);
    
    %% Generate pi posix timestamps for fiber stream data
    tm = linspace(0, numel(gc)/fs, numel(gc))';
    tm = interp1(photo_events.time, pi_events.posix, tm, "linear", "extrap");
end

function ind = find_good_start(stream, fs)
    max_cut = fs*60*5;
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
    tm = linspace(0, fs*numel(stream), numel(stream));
    plot(tm, stream); hold on
    scatter(tm(ind), stream(ind), '*r')
end