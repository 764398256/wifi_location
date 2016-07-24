function [est_img, h_avg_amp] = process_csi(voxel_num, sample_csiM, W_eq)
sample_size = size(sample_csiM);
% normalize to [0,1]
h_avg = squeeze(mean(sample_csiM,1));
h_avg = squeeze(mean(h_avg,1));
h_avg_amp = squeeze(10*log10(abs(h_avg)));
%h_avg_ph = squeeze(angle(h_avg));
est_img = zeros(voxel_num, sample_size(4));
for i = 1: sample_size(4)
    tmp = W_eq* h_avg_amp(:, i);
    est_img(:, i) = (tmp - min(tmp))/(max(tmp) - min(tmp));
end
end