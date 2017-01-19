function [histo] = fingerprint_builder_csi( M )
% M: multiple dimension matrix containing data of [ streams, subcarriers, voxel_num, sample_len ]
%   
[voxel_num, stream_num, dim ,sample_len] = size(M);
arange = [-3, 3];
phrange = [-pi, pi];
astep = 0.1;
nbin = (arange(2) - arange(1))/astep;

phstep = (phrange(2) - phrange(1))/nbin;
histo = zeros(voxel_num, stream_num* dim, 2, nbin);
histo_flatten = zeros(voxel_num,  2, nbin* stream_num*dim);
%RSS Value Range
% Gussian Filter
sigma =0.1;
rsize = 10;
x = linspace(-rsize / 2, rsize / 2, rsize);
gaussFilter = exp(-x .^ 2 / (2 * sigma ^ 2));
gaussFilter = gaussFilter / sum (gaussFilter); % normalize

ratio = 0.00001;
for i = 1: stream_num* dim
    s = floor( ( i+dim - 1)/dim) ;
    d = mod(i + dim - 1,dim) + 1;
%     if d <= dim/2
        edges = [arange(1):astep:arange(2)]; 
%     else
%         edges = [phrange(1): phstep: phrange(2) ];
%     end
    for j = 1: voxel_num
        [h,~]=histcounts(M(j, s,d , :), edges, 'Normalization','probability');
        tmp  = conv (h, gaussFilter, 'same')';
        if sum(sum(squeeze(tmp))) ~= 0
            maxv = max(max(tmp));
            tmp(tmp<maxv*ratio) = maxv*ratio;
        end
        tmp  = tmp/sum(sum(tmp));
        histo(j,i,1,:) = tmp;
        if i < dim*stream_num/2
            figure(1);
            subplot(121);
            plot(h);        
            hold on;
            subplot(122);
            plot(squeeze(histo(j, i, 1, :) ));
            hold on;
        end
        [ho,~]= histcounts( reshape( M([1: (j-1), (j+1):end], s, d,:  ), sample_len*(voxel_num-1) ,1) , edges, 'Normalization','probability');
        tmp  = conv (ho, gaussFilter, 'same')';
        if sum(sum(squeeze(tmp))) ~= 0
            maxv = max(max(tmp));
            tmp(tmp<maxv*ratio) = maxv*ratio;
        end
        tmp  = tmp/sum(sum(tmp));
        histo(j,i,2,:) = tmp;
        %assert(sum(sum(sum(sum(histo== 0)))) == 0);
        histo_flatten(j, 1,nbin*(i-1)+1:  nbin*(i)) = squeeze( histo(j, i, 1, :) );
        histo_flatten(j, 2, nbin*(i-1)+1:  nbin*(i)) = squeeze( histo(j, i, 2, :) );

    end
end
write_img = 1;
  if write_img
for dim_show = 1:dim
    f = figure(1);
    la = [];
le = [];
for j = voxel_num - 6: voxel_num
        h1 = plot(squeeze(histo_flatten(j,1,nbin*stream_num*(dim_show-1)+1:nbin*stream_num*dim_show)));
        le = [le; h1];
        la = [la; {sprintf('voxel %d,  pos', j)}];
        hold on;
        h2 = plot(squeeze(histo_flatten(j,2,nbin*stream_num*(dim_show-1)+1:nbin*stream_num*dim_show)),'o');
        le = [le; h2];
        la = [la; {sprintf('voxel %d, neg', j)}];
        hold on;
end
legend(le, la);
lh=findall(gcf,'tag','legend');
set(lh,'location','northeastoutside');
hold off;
saveas(f,sprintf('data/dim_%d.png', dim_show));

end
  end
disp(sum(sum(sum(sum(histo== 0)))) );
disp(min(min(min(min(histo)))));
% plot
%fingerprint = reshape(histo, stream_num* dim*voxel_num*2*(srange(2) - srange(1))/step );
end

