% le plotting device
% game-plan: 2 plots: 1 for multiband data, 1 for no multi, both contain
% reordered time course and normal time course estimates but additionally
% confidence intervall

% plot time course 
% 
% no fun allowed here

addpath('C:\Users\mcnbf\Desktop\sara\toolboxes\spm12');

src = 'D:\SEBs\Data';
% src = 'C:\Users\saraw\Desktop\SEBs\Data\noMulti';

sub = [2:21 23:33]; %
pref = 's8wr';
pref_re = 's4wSEBr';
voxel = 1;
intr = [   9    49    44]; %... 
        % 14 51 61; 16 39 64; 14 42 62 
        % 19 42 67; 24 37 70; 20 37 68; ...
        % 16 45 47; 14 48 47; 12 50 46 ]; % SI (ventral, dorsal), SII
id_string = 'voxel_from_RSII_for_visuals';

time_size = 270;
roving = 0;
win_size = 1;
% cluster = niftiread('C:\Users\saraw\Desktop\SEBs\MA\Data\2nd_level_N12_factorial\rSII_FWE.nii');
% cluster1 = squeeze(sum(cluster, [2, 3]))';
% cluster2 = squeeze(sum(cluster, [1, 3]));
% cluster3 = squeeze(sum(cluster, [1, 2]))';

% Sara right SII: 9.0 48.0 52.0, Sara, right SI: 12.0 49.0 65.0
% Sara left SII: 73.0 49.0 44.0, Sara, left SI: 69.0 44.0 62.0
% 4 subjects peak: 14 49 46
multi = '4'; % 4 = multi, 1 = not multi
% or
new_tr = 0.06;
if multi == '1'
    old_tr = 2.16;
else
    old_tr = 0.54;
end

logDir = 'C:\Users\mcnbf\Desktop\sara\SEBs\Logs';

sub_counter = 0;
for s = sub

    clear fun
    disp(['currently at subject ' num2str(s)])

    sub_counter = sub_counter + 1;

    % cd(logDir)
    % oruns=dir(['LogFile_subject-' num2str(s) '_*multi-' multi '_*.tsv']);
    % runs_to_mean = [];
    % for l = 1:size(oruns, 1)
    %     runs_to_mean = [runs_to_mean str2num(oruns(l).name(regexp(oruns(l).name, 'run-')+4))];
    % end

    % cd([src filesep to_do filesep 'sub-00' num2str(sub) filesep 'func']);
    if s < 10
        subj_dir = [src filesep 'sub-00' num2str(s) filesep 'func'];
    else
        subj_dir = [src filesep 'sub-0' num2str(s) filesep 'func'];
    end
    cd(subj_dir);
    funcs_re = dir([pref_re 'sub*.nii']);
    
    disp(['gathering data...'])
    %load niftis -> faster way?
    counter = 0;
    for f = 1:4 %%%%%%%%%%%%%%%%%%%%%%%%%%%
        counter = counter +1;
        fun(:,:,:,:,counter) = niftiread(funcs_re(f).name);
    end   
    mean_fun = mean(fun,5);
    if voxel == 1
        for v = 1:size(intr, 1)
            time_course_re(v,:) = squeeze(mean_fun(intr(v,1), intr(v,2), intr(v,3), :))';
        end
    elseif voxel == 2
        time_course_re = squeeze(mean(mean_fun(cluster1>0, cluster2>0, cluster3>0, :), [1 2 3]));
    end

    % funcs = dir([pref 'sub*.nii']);

    %load niftis -> faster way?
    % other_counter = 0;
    % time_courses = zeros([size(intr, 2), round(16/old_tr)+1, length(runs_to_mean)]);
    % for r = runs_to_mean
    %     other_counter = other_counter +1;
    %     this_log = tdfread([logDir filesep oruns(other_counter).name]);
    %     trigger = round(this_log.TriggerTime/old_tr);
    %     fun = niftiread([subj_dir filesep funcs(r).name]);
    %     for t = 1:length(trigger)
    %         if voxel == 1
    %             for v = size(intr, 2)
    %                 time_courses(v,:,other_counter) = time_courses(v,:,other_counter) + double(squeeze(fun(intr(v,1), intr(v,2), intr(v,3), [trigger(t):(trigger(t)+round(16/old_tr))]))');
    %             end
    %         elseif voxel == 2
    %             time_courses(:,other_counter) = time_courses(:,other_counter) + double(squeeze(mean(fun(cluster1>0, cluster2>0, cluster3>0, [trigger(t):(trigger(t)+round(16/old_tr))]), [1 2 3])));
    %         end
    %     end
    % end   
    % time_courses = time_courses/length(trigger);

    disp(['applying roving window...'])
    if win_size > 1 && roving == 1
        for w = 1:size(time_course_re,2)

            if w < floor(win_size/2)+1
                this_win_size = w;
            elseif w > (size(time_course_re,2)-floor(win_size/2))
                this_win_size = (size(time_course_re,2)-w);
            else
                this_win_size = win_size;
            end
            approx_re(:,w) = mean(time_course_re(:,(w-floor(this_win_size/2)):(w+floor(this_win_size/2))),2);

        end
    elseif win_size > 1 && roving == 0
        counter = 0;
        for w = 1:win_size:size(time_course_re,2)
            
            counter = counter + 1;
            if w+win_size <= size(time_course_re,2)
                approx_re(:,counter) = mean(time_course_re(:,(w:(w+win_size-1))),2);
            else
                approx_re(:,counter) = mean(time_course_re(:,(w:end)),2);
            end

        end
    else
        approx_re = time_course_re;
    end

    all_S_time_course_re(:,:,sub_counter) = time_course_re;
    % all_S_time_courses(:,:,:,sub_counter) = time_courses;
    all_S_approx(:,:,sub_counter) = approx_re;

end

save(['C:\Users\mcnbf\Desktop\sara\SEBs\time_courses\all_S_time_course_re_' id_string '.mat'], "all_S_time_course_re");
% save(['C:\Users\mcnbf\Desktop\sara\SEBs\time_courses\all_S_time_courses_' id_string '.mat'], "all_S_time_courses");
save(['C:\Users\mcnbf\Desktop\sara\SEBs\time_courses\all_S_approx_' id_string '.mat'], "all_S_approx");

figure()

if size(intr,1) > 1
    % mean runs
    % all_time_courses_temp = reshape(mean(all_S_time_courses, 3), [size(all_S_time_courses, [1,2,4])]); 
    % all_time_courses_temp = all_time_courses_temp - mean(all_time_courses_temp, 2);
    % de-mean over time
    all_S_time_course_re_temp = all_S_time_course_re - mean(all_S_time_course_re, 2);
    all_S_approx_temp = all_S_approx - mean(all_S_approx, 2); 
    
    % compute sems
    all_S_time_course_re_SEM = std(all_S_time_course_re_temp,[],3)/sqrt(length(sub));
    % all_S_time_courses_SEM = std(all_time_courses_temp,[],3)/sqrt(length(sub));
    all_S_approx_SEM = std(all_S_approx_temp,[],3)/sqrt(length(sub));
    
    % compute mean over sjs + mean correct
    all_S_time_course_re_mean = mean(all_S_time_course_re_temp,3);
    % all_S_time_courses_mean = mean(all_time_courses_temp,3);
    all_S_approx_mean = mean(all_S_approx_temp,3);
else
    all_time_courses_temp = reshape(mean(all_S_time_courses, 2), [size(all_S_time_courses, [1, 3])]); 
    all_time_courses_temp = all_time_courses_temp - mean(all_time_courses_temp, 1);
    all_S_time_course_re_temp = all_S_time_course_re - mean(all_S_time_course_re, 1);
    all_S_approx_temp = all_S_approx - mean(all_S_approx, 1);
    
    all_S_time_course_re_SEM = std(all_S_time_course_re_temp,[],2)/sqrt(length(sub));
    all_S_time_courses_SEM = std(all_time_courses_temp,[],2)/sqrt(length(sub));
    all_S_approx_SEM = std(all_S_approx_temp,[],2)/sqrt(length(sub));
    
    all_S_time_course_re_mean = mean(all_S_time_course_re_temp,2)-mean(all_S_time_course_re_temp, 'all');
    all_S_time_courses_mean = mean(all_time_courses_temp,2)-mean(all_time_courses_temp,'all');
    all_S_approx_mean = mean(all_S_approx_temp,2)-mean(all_S_approx_temp,'all');
end

if length(sub) > 1
    if roving == 0
        new_tr = new_tr*win_size;
    end
    x1 = [1:size(approx_re,2)]*new_tr -new_tr;
    plot(x1,all_S_approx_mean)
    hold on
    % for v = size(intr,1)
    %     % x2 = [1:size(time_courses,2)]*old_tr -old_tr;
    %     x3 = [1:300]*new_tr;
    %     x1conf = [x1 x1(end:-1:1)]; 
    %     % x2conf = [x2 x2(end:-1:1)]; 
    %     % y1conf = [squeeze(all_S_approx_mean(v,:)+all_S_approx_SEM(v,:)); squeeze(all_S_approx_mean(v,end:-1:1)-all_S_approx_SEM(v,:))];
    %     % y2conf = [all_S_time_courses_mean(v,:)+all_S_time_courses_SEM(v,:); all_S_time_courses_mean(v,end:-1:1)-all_S_time_courses_SEM(v,:)];
    % 
    %     % plot(x1,all_S_time_course_re-mean(all_S_time_course_re))
    %     hold on    
    %     fill(x1conf,y1conf,'red', FaceColor=[1 0.8 0.8], EdgeColor='none');
    %     % fill(x2conf,y2conf,'blue', FaceColor=[0.8 0.8 1], EdgeColor='none');
    % 
    %     % plot(x2,all_S_time_courses_mean-mean(all_S_time_courses_mean)', '-o', 'Color','blue')
    % end

    x3 = [1:round(time_size/win_size)]*new_tr;

    [hrf,p] = spm_hrf(new_tr);
    hrf=hrf-mean(hrf);
    plot(x3()-new_tr,hrf(1:size(approx_re,2))*50, '--')
    h = get(gca, 'Children');
    legend([h(1), h(4), h(3), h(2)], {'HRF', [num2str(intr(1,:)) ' (early 14)'],  [num2str(intr(2,:)) ' (peak 36)'], [num2str(intr(3,:)) ' (late 41)']})
    set(gca, "YLim", [-2.5, 2.5])

    hold off
else
    x1 = [1:length(approx_re)]*new_tr;
    x2 = [1:size(time_courses,1)]*old_tr;
    x3 = [1:300]*new_tr;

    plot(x1,time_course_re-mean(time_course_re))
    hold on
    plot(x1,approx_re-mean(approx_re))
    plot(x2, (mean(time_courses, 2))-squeeze(mean(time_courses, 'all'))', '-o')
    plot(x3,hrf(1:300)*200, '--')
    h = get(gca, 'Children');
    set(h(1), 'Color', 'blue')
    set(h(2), 'Color', 'red')
    set(gca, "YLim", [-2.5, 2.5])
%     set(h(4), 'Color', '#848484', LineWidth=0.5)
%     set(h(1), 'Color', 'red', LineWidth=5)
    legend([h(1), h(2), h(4), h(3)], {'HRF', 'unsorted', 'resorted', 'resorted temp smooth'})
    hold off
end

clear all_S_time_course_re all_S_time_courses all_S_approx




