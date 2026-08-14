function [dB,F,T] = get_spec(audio, fs, opt)
    arguments
        audio
        fs
        opt.window = 0.002 % seconds
        opt.overlap = 0.5 % overlap proportion
        opt.freq = (34:2:70)*1e3 % frequencies to return
    end
    window = round(fs * opt.window);
    overlap = round(window*opt.overlap);
    [~,F,T,P] = spectrogram(audio ,window, overlap, opt.freq, fs);

    ref = median(P,2);
    dB = 10*log10(P./ref);
    dB = imgaussfilt(dB);
end