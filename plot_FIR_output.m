% a plot that includes the results from the FIR 
% idea: to avoid excessive data loading, re-use data for time courses and
% then just overlay the "stairs" from the FIR, then do something like
% highlighting the time-course and plot the contrast map from spm next to
% it or so

clear all

addpath('C:\Users\nnu13\Desktop\Sara\toolboxes\spm12');

scr_dir = 'C:\Users\nnu13\Desktop\Sara\SEBs\Data\output_hpc_paper-relevant\old';

multi = '4';
bins = 45;
bin_size = 0.24; % in s
voxel = [20 42 68]; % SI: 20 42 68, SII: 9 48 52 % weird: 23 68 37
v_area = 'RSII';
old_TR = 0.54; % 2.16; % 

hrf = spm_hrf(0.24, [6 16 1 1 6 0 45*0.24], 1);

second_dir = [scr_dir filesep '2nd_level_-FIR_REO_' multi '_' num2str(bins)];

t_stairs = [];
b_stairs = [];
sagital_t = zeros(95,79,bins);
coronal_t = zeros(79,79,bins);
horizontal_t = zeros(79,95,bins);
sagital_b = zeros(95,79,bins);
coronal_b = zeros(79,79,bins);
horizontal_b = zeros(79,95,bins);

for b = 1:bins

    cd([second_dir filesep 'FIR_REO_' multi '_' num2str(bins) '_bins' filesep 'Con' num2str(b) '_bin_' num2str(b)]);
    
    t_map = niftiread('spmT_0001.nii');
    b_map = niftiread('beta_0001.nii');

    t_stairs = [t_stairs t_map(voxel(1), voxel(2), voxel(3))];
    b_stairs = [b_stairs b_map(voxel(1), voxel(2), voxel(3))];

    sagital_t(:,:,b) = t_map(voxel(1), :, :);
    coronal_t(:,:,b) = t_map(:, voxel(2), :);
    horizontal_t(:,:,b) = t_map(:, :, voxel(3));

    sagital_b(:,:,b) = b_map(voxel(1), :, :);
    coronal_b(:,:,b) = b_map(:, voxel(2), :);
    horizontal_b(:,:,b) = b_map(:, :, voxel(3));

end

x1 = ([1:bins]-1)*bin_size;
vols_SEB = round(bin_size/0.06);
x2 = ([1:bins*vols_SEB]-1)*0.06;
vols = round(x1(end)/old_TR);
x3 = (([1:vols]-1)*old_TR);

x_area = [x1 x1(end:-1:1)];
b_area = [b_stairs; b_stairs(end:-1:1)];
t_area = [t_stairs; t_stairs(end:-1:1)];

[~, imax_t] = max(t_stairs);
[~, imax_b] = max(b_stairs);

% no_SEB = mean(load(['C:\Users\nnu13\Desktop\Sara\SEBs\time_courses' filesep 'vox_' v_area '_' multi '.mat']).all_S_time_courses, [2, 3]);
% with_SEB = mean(load(['C:\Users\nnu13\Desktop\Sara\SEBs\time_courses' filesep 'vox_' v_area '_' multi '_SEB.mat']).all_S_time_course_re, 2);

figure(5)
st1 = stairs(x1, b_stairs*1000);
hold on 

st2 = stairs(x1, t_stairs);
legend({'beta-values*1000', 't-values'}, AutoUpdate = 'off')

bottom = min(gca().YLim(1)); %identify bottom; or use 

x_area1 = [st1.XData(1),repelem(st1.XData(2:end),2)];
y_area1 = [repelem(st1.YData(1:end-1),2),st1.YData(end)];
fill([x_area1,fliplr(x_area1)],[y_area1,bottom*ones(size(y_area1))], [0 0 1], FaceAlpha = 0.5)

x_area2 = [st2.XData(1),repelem(st2.XData(2:end),2)];
y_area2 = [repelem(st2.YData(1:end-1),2),st2.YData(end)];
fill([x_area2,fliplr(x_area2)],[y_area2,bottom*ones(size(y_area2))], [1 0 0], FaceAlpha = 0.5)

% figure(2)
% plot(x2, with_SEB(1:length(x2))-mean(with_SEB(1:length(x2))))
% hold on
% plot(x3, no_SEB(1:length(x3))-mean(no_SEB(1:length(x3))))
% legend({'reordered data', 'non-reordered data'})

imax_t
imax_b

% figure(2)
% imagesc(sagital_b(:,end:-1:1,imax_b)')
% figure(3)
% imagesc(coronal_b(end:-1:1,end:-1:1,imax_b)')
% figure(4)
% imagesc(horizontal_b(:,end:-1:1,imax_b))
% figure(5)
% imagesc(sagital_t(:,end:-1:1,imax_t)')
% figure(6)
% imagesc(coronal_t(end:-1:1,end:-1:1,imax_t)')
% figure(7)
% imagesc(horizontal_t(:,end:-1:1,imax_t))