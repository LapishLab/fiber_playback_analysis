function play_info = load_synced_play_info(playback_audio_path, session_dir, play_info_path)
    %% Load playback audio and compute spectrogram
    [audio_play, sr_play] = audioread(playback_audio_path);
    [dB_play,~,T_play] = get_spec(audio_play, sr_play);
    sr_spect = 1/diff(T_play(1:2));
    
    %% Load drift corrected Pi audio and compute spectrogram
    audio_file = wildcard_path(fullfile(session_dir, 'pi-data*','fiber01','mic', '*.wav'));
    [audio_pi, sr_pi] = load_corrected_audio(audio_file);
    [dB_pi,~,~] = get_spec(audio_pi, sr_pi);
    
    %% Estimate offset by RMS
    start_est = estimate_play_start(audio_pi, sr_pi);
    
    %% Loop in chunks through playback spectrogram
    file_sync = get_sync_points(dB_play, dB_pi, sr_spect, start_est);
    file_sync.pi_posix = file_sync.pi + fname2posix(audio_file);
    
    %% Add column of posix times to playback metadata table 
    play_info = load_play_info(play_info_path);
    play_info.posix = interp1(file_sync.play, file_sync.pi_posix, play_info.file_time, "linear", "extrap");
end

function posix = fname2posix(fname)
    [~,t_str,~] = fileparts(fname);
    dt = datetime(t_str, "InputFormat","uuuuMMdd_HHmmss_SSSSSS");
    posix = posixtime(dt);
end