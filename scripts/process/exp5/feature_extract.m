function  features_real  = feature_extract( M )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
h_avg_amp = amplitude(M);
%features = diff(h_avg_amp);
features = PEM(h_avg_amp);
features_real = (features - min(features))/(max(features) - min(features));
%corr_train(:,:,i) = cov(h_amp_diff_train_detail.');
end

