function features = feature_csi(M)
% normalize to [0,1]
h_avg = squeeze(mean(M,1));
h_avg = squeeze(mean(h_avg,1));
h_avg_amp_tmp = squeeze(10*log10(abs(h_avg)));
h_avg_ph_tmp = squeeze(angle(h_avg));
h_amp_diff_train_detail = diff(h_avg_amp_tmp);
h_ph_diff_train_detail = diff(h_avg_ph_tmp);

h_avg_amp = h_amp_diff_train_detail;
h_avg_ph = h_ph_diff_train_detail;
lb= -3;
ub = 3;
h_avg_amp(h_amp_diff_train_detail < lb) = lb;
h_avg_amp(h_amp_diff_train_detail > ub) = ub;
features = [h_avg_amp;h_avg_ph ];
%h_avg_ph = squeeze(angle(h_avg));
end