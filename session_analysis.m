
root_dir = 'C:\Users\daswyga\Desktop\Anna_fiber';

%% Happy 
play_info_path = fullfile(root_dir, 'happy_0.15_squeak_info.mat');
playback_audio_path = fullfile(root_dir, 'happy_0.15.wav');

% Cohort 1:
ses_nm = "2026-08-06_09-23-23_NAc_dlight_rat12"; note = "Rat 12: Wistar, Male, saline (8/6)";
ses_nm = "2026-08-06_11-16-16_NAc_dlight_rat3"; note = "Rat 3: Wistar, Female, saline (8/6)";
ses_nm = "2026-08-06_11-45-59_NAc_dlight_rat5"; note = "Rat 5: P, Male, saline (8/6)";
ses_nm = "2026-08-06_12-49-10_NAc_dlight_rat6"; note = "Rat 6: Wistar, Male, DCZ (8/6)";
ses_nm = "2026-08-06_13-20-18_NAc_dlight_rat4"; note = "Rat 4: P, female, DCZ (8/6)";
ses_nm = "2026-08-06_13-50-10_NAc_dlight_rat2"; note = "Rat 2: P, male, DCZ (8/6)";

% Cohort 2:
% Rat 13, 15, 23 on 8/17 and 8/18
ses_nm = "2026-08-18_09-15-32_NAc_dlight_rat13"; note = "Rat 13: P, female, saline (8/18)";
ses_nm = "2026-08-18_10-26-09_NAc_dlight_rat15"; note = "Rat 15: W, female, DCZ (8/18)";
ses_nm = "2026-08-18_14-44-09_NAc_dlight_rat23"; note = "Rat 23: W, female, saline (8/18)";

%% Noise
% play_info_path = fullfile(root_dir, 'noise_squeak_info.mat');
% playback_audio_path = fullfile(root_dir, 'noise_NAc_dlight.wav');

% Cohort 2:
% Rat 13, 15, 23 on 8/17 and 8/18
ses_nm = "2026-08-17_09-14-32_NAc_dlight_rat13"; note = "Rat 13: P, female, noise (8/17)";
ses_nm = "2026-08-17_10-12-09_NAc_dlight_rat15"; note = "Rat 15: W, female, noise (8/17)";
ses_nm = "2026-08-17_14-09-41_NAc_dlight_rat23"; note = "Rat 23: W, female, noise (8/17)";

ses_nm = "2026-08-26_09-05-52_NAc_dlight_rat13";

%%
session_dir = fullfile(root_dir, "raw_data", ses_nm);
%% Load the playback info file and synchronize to pi posix time using cross correlation of recorded and played files
% play_info = load_synced_play_info(playback_audio_path, session_dir, play_info_path);

%% Load the fiber data, and synchonize to pi posix time using TTL events
[tm, gc, iso] = load_synced_fiber(session_dir);
sgtitle(note);
%%
% plot_around_usv(play_info, gc, tm)
% title(note)
%%
% plot_around_chunk(play_info, gc, tm, chunk_inds = 1)
% title(note)
% 

