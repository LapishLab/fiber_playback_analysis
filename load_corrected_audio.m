function [audio, target_sr] = load_corrected_audio(audio_path)
    %% load metadata and smooth
    metadata_path = strrep(audio_path, '.wav', '.csv');
    meta = readtable(metadata_path);
    meta = smooth_audio_sync(meta);
    
    %% load audio
    [audio, target_sr] = audioread(audio_path);
    
    %% Resample audio to exactly 250kHz
    audio = correct_audio(audio, meta, target_sr);
    
    % %% Plot drift
    % x = meta.file_us/1e6;
    % plot(x, meta.file_us/1e6 - meta.sample/250e3)
    % xlabel('seconds')
end

function meta = smooth_audio_sync(meta)
    window_dur = 1; %Smoothing window in seconds

    % Ensure uniform spacing (probably won't change anything)
    if length(unique(diff(meta.sample))) > 1
        x = 0:median(diff(meta.sample)):max(meta.sample);
        y = interp1(meta.sample,meta.file_us, x);
        meta = table(x,y, 'VariableNames', {'sample', 'file_us'}); % overwrite table
    end

    % Smooth across diffs, and then reconstruct with cumulative sum
    t_diff = diff(meta.file_us);
    window = ceil(window_dur * 1e6 / mean(t_diff));
    t_diff = movmean(t_diff,window);
    meta.file_us = [0; cumsum(t_diff)];
end

function new_y = correct_audio(old_y, meta, target_sr)
    old_t = interp1(meta.sample, meta.file_us/1e6, 1:numel(old_y), "linear", "extrap"); % (seconds) Interpolate the expected actual timestamps for the audio given the metadata
    new_t = 0: 1/target_sr: old_t(end); % Perfectly spaced at target sample rate
    new_y = interp1(old_t, old_y, new_t,"nearest", "extrap");

    % Check if that changed the power spectrum
    % clf
    % hold on;
    % [p,f] = pspectrum(new_y(1:1e6), new_fs);
    % plot(f,p)
    % hold on
    % [p,f] = pspectrum(y(1:1e6),  fs);
    % plot(f,p)
    % yscale('log')
    % legend('new','old')
end