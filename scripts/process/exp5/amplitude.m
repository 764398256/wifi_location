function h_avg_amp = amplitude(M)
% normalize to [0,1]
h_avg = squeeze(mean(M,1));
h_avg = squeeze(mean(h_avg,1));
h_avg_amp_tmp = squeeze(10*log10(abs(h_avg)));
h_avg_amp = h_avg_amp_tmp;
lower_bound = -100;
h_avg_amp(h_avg_amp_tmp < lower_bound) = lower_bound;
%h_avg_ph = squeeze(angle(h_avg));
end