tic

root_dir = 'C:\Users\daswyga\Desktop\Anna_fiber';
% ses_nm = "2026-08-06_09-23-23_NAc_dlight_rat12"; note = "Rat 12: Wistar, Male, saline (8/6)";
% ses_nm = "2026-08-06_11-16-16_NAc_dlight_rat3"; note = "Rat 3: Wistar, Female, saline (8/6)";
ses_nm = "2026-08-06_11-45-59_NAc_dlight_rat5"; note = "Rat 5: P, Male, saline (8/6)";
% ses_nm = "2026-08-06_12-49-10_NAc_dlight_rat6"; note = "Rat 6: Wistar, Male, DCZ (8/6)";
% ses_nm = "2026-08-06_13-20-18_NAc_dlight_rat4"; note = "Rat 4: P, female, DCZ (8/6)";  Syncronization not working at all
% ses_nm = "2026-08-06_13-50-10_NAc_dlight_rat2"; note = "Rat 2: P, male, DCZ (8/6)";


session_dir = fullfile(root_dir, "raw_data", ses_nm);
play_info_path = fullfile(root_dir, 'happy_0.15_squeak_info.mat');
playback_audio_path = fullfile(root_dir, 'happy_0.15.wav');

%% Load the playback info file and synchronize to pi posix time using cross correlation of recorded and played files
play_info = load_synced_play_info(playback_audio_path, session_dir, play_info_path);

%% Load the fiber data, and synchonize to pi posix time using TTL events
[tm, gc, iso] = load_synced_fiber(session_dir);

%%
% plot_around_usv(play_info, gc, tm)
% title(note)
%%
plot_around_chunk(play_info, gc, tm)
title(note)

%%



toc


