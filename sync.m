root_dir = 'C:\Users\daswyga\Desktop\Anna_fiber';

%% Load playback audio and compute spectrogram
playback_audio_path = fullfile(root_dir, 'happy_0.15.wav');
[audio_play, sr_play] = audioread(playback_audio_path);
[dB_play,~,T_play] = get_spec(audio_play, sr_play);
sr_spect = 1/diff(T_play(1:2));

%% Load drift corrected Pi audio and compute spectrogram
session_dir = fullfile(root_dir, "raw_data","2026-08-06_09-23-23_NAc_dlight_rat12");
audio_file = wildcard_path(fullfile(session_dir, 'pi-data*','fiber01','mic', '*.wav'));
[audio_pi, sr_pi] = load_corrected_audio(audio_file);
[dB_pi,~,~] = get_spec(audio_pi, sr_pi);

%% Estimate offset by RMS
start_est = estimate_play_start(audio_pi, sr_pi);

%% Loop in chunks through playback spectrogram
file_sync = get_sync_points(dB_play, dB_pi, sr_spect, start_est);
file_sync.pi_posix = file_sync.pi + fname2posix(audio_file);

%% Add column of posix times to playback metadata table 
% audio_rec_time + file_start -> posix
% interp1: x=playback_file_time, y=posix, new_x=playback_meta_time
play_info_path = fullfile(root_dir, 'happy_0.15_squeak_info.mat');
play_info = load(play_info_path);
play_info = cat(1, play_info.metadata.audio_chunk{:});
row_dur = cumsum(play_info.usv_duration+play_info.background_duration);
play_info.file_time = [0; row_dur(1:end-1)];

play_info.posix = interp1(file_sync.play, file_sync.pi_posix, play_info.file_time, "linear", "extrap");

function posix = fname2posix(fname)
    [~,t_str,~] = fileparts(fname);
    dt = datetime(t_str, "InputFormat","uuuuMMdd_HHmmss_SSSSSS");
    posix = posixtime(dt);
end