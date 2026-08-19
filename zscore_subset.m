function out = zscore_subset(data, is_subset)
    subset = data(:, is_subset);
    avg = mean(subset, 2);
    stan_dev = std(subset, [], 2);
    out = (data - avg) ./ stan_dev;
end