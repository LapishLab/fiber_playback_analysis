function play_info =  load_play_info(file_path)
    play_info = load(file_path);
    play_info = cat(1, play_info.metadata.audio_chunk{:});
    play_info.Type(contains(play_info.detection_file, 'background')) = "background";
    row_dur = cumsum(play_info.usv_duration+play_info.background_duration);
    play_info.file_time = [0; row_dur(1:end-1)];
end