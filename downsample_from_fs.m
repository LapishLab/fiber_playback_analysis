function [y_final, x_final] = downsample_from_fs(data, old_fs, new_fs)
r = floor(old_fs / new_fs);
data_dec = decimate(double(data),r);
fs_dec = old_fs/r;

x_dec = gen_time(numel(data_dec), fs_dec);
x_final = gen_time(new_fs*x_dec(end), new_fs);

y_final = interp1(x_dec, data_dec, x_final,"linear", "extrap");
end