function subgraph(file_folder, files, width, height, tag_id, stitle, ttitle, fign)
% w, h: subgraph position
% data: wave

 h = figure;
 for i = 1:numel(files)
        load(strcat(file_folder, char(files(i))) );
        f_nonext =strsplit(char(files(i)), '.');
        f_nonext = char(f_nonext(1));
        %for example, [prefix,empty, antenna,  location]
        param = strsplit(f_nonext, '_') ;
        ax(i)=subplot(width, height ,i);
        surf(sample_pwM, 'linestyle', 'none');
        ylabel('sc');
        xlabel('t(N*0.2s)');
        zlim(ax(i), [0 40]);
        ylim(ax(i), [0 40]);
        xlim(ax(i), [50 400]);
        zlabel('Magnitude[dB]');
        if tag_id ~= -1
            title(sprintf(stitle, char(param(tag_id)) ));
        else
            title(stitle);
        end
 end
 cb = colorbar;
 %position: left, bottom, right, top
 set(cb, 'Position', [.9314 .11 .0181 .8150])
 for i=1:numel(files)
     pos=get(ax(i), 'Position');
     set(ax(i), 'Position', [pos(1) pos(2) 0.85*pos(3) 0.8*pos(4)]);
 end
 subtitle(ttitle);
 savefig(h, fign);
 close(h);
 
end