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
    
    %% Preprocess fiber signal
    gc = photoData.streams.x465A.data;
    iso = photoData.streams.x415A.data;
    fs = photoData.streams.x465A.fs;
    [gc, iso] = preprocessFP_GCaMP(gc, iso, fs);
    
    %% Generate pi posix timestamps for fiber stream data
    tm = linspace(0, numel(gc)/fs, numel(gc))';
    tm = interp1(photo_events.time, pi_events.posix, tm, "linear", "extrap");
end