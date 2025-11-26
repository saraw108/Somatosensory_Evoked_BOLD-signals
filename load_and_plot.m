% load and plot time-courses

% LSII, RSII, LBA1-2-3, RBA1-2-3

struct_string = 'all_S_approx';
id_string = ['_voxel_from_RSII_for_visuals.mat'];
file_path = 'C:\Users\mcnbf\Desktop\sara\SEBs\time_courses';
addpath('C:\Users\mcnbf\Desktop\sara\toolboxes\spm12');
new_tr = 0.06;

labels = {'HRF', 'R SII'}%, '18 68 37 (R IC)', '22 33 59 (R PPC)', '36 62 59 (R SMA)', '32 24 54 (L Precuneus)'};

mix_with = 0;
from_first = [1];
from_second = []; 
from_third = [];

second_ids = '_voxel_from_RSII_for_visuals.mat';

colours_line = ['#C00000'];%; '#C00000'; '#7030A0'; '#5B9BD5'; '#70AD47';]; % ['#5B9BD5'; '#70AD47'; '#FFC000']; % 
% colours_face = [0.8 0.8 1; 0.8 1 0.8; 0.9 0.9 0.8];

%% load

load([file_path filesep struct_string id_string]);

if mix_with > 0

    temp1 = all_S_approx(from_first,:,:);

    for m = 1:mix_with
        temp2 = load([file_path filesep struct_string second_ids(m,:)]).all_S_approx; %%
        temp1 = [temp1; temp2(from_second,:,:)];
    end

    temp = temp1 - mean(temp1, 2); 
    % clear temp1 temp2

elseif strcmp(struct_string, 'all_S_approx') == true

    % de-mean
    temp = all_S_approx - mean(all_S_approx, 2); 
    
elseif strcmp(struct_string, 'all_S_time_course_re') == true

    % de-mean
    temp = all_S_time_course_re - mean(all_S_time_course_re, 2);

end

% compute sems
SEM = std(temp(from_first,:,:),[],3)/sqrt(size(temp(from_first,:,:),3));

% compute mean over sjs
all_mean = mean(temp(from_first,:,:),3);

%% plot

x1 = [1:size(all_mean,2)]*new_tr-new_tr;
x1conf = [x1 x1(end:-1:1)];

for v = 1:size(all_mean,1)
    y1conf = [squeeze(all_mean(v,:)+SEM(v,:)), squeeze(all_mean(v,end:-1:1)-SEM(v,:))];
    fill(x1conf,y1conf,'red','FaceAlpha',0.3, FaceColor=colours_line(v,:), EdgeColor='none');
    hold on
end
for v = 1:size(all_mean,1)
    plot(x1,all_mean(v,:), Color=colours_line(v,:)')
end

x3 = [1:size(all_mean,2)]*new_tr;
[hrf,p] = spm_hrf(new_tr);
hrf=hrf-mean(hrf);
plot(x3()-new_tr, hrf(1:size(all_mean,2))*20, 'Color', [0 0 0], 'LineStyle', '--')

h = get(gca, 'Children');
legend([h(1), h(3), h(2)], labels)
%legend([h(1), h(6), h(5), h(4), h(3), h(2)], labels)
set(gca, "YLim", [-2.5, 2.75])