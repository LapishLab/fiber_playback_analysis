
root_dir = 'C:\Users\daswyga\Desktop\Anna_fiber';
d = struct2table(dir(fullfile(root_dir,"raw_data")));
d = d(3:end, :);
session_dirs = fullfile(d.folder(d.isdir), d.name(d.isdir));

for i=1:length(session_dirs)
    mic_folder = fullfile(session_dirs{i}, 'pi-data*','fiber01','mic');

    try
        wildcard_path(fullfile(mic_folder, "*_corrected.wav"));
    catch
        audio_file = wildcard_path(fullfile(mic_folder, '*.wav'));
        [audio_pi, sr_pi] = load_corrected_audio(audio_file);
        audiowrite(strrep(audio_file, '.wav', '_corrected.wav'), audio_pi, sr_pi)
    end
    sprintf("%i/%i", i, length(session_dirs))
end