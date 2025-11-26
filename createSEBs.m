%% eval SEBs
% create Volumes containing only slices 1. during stimulation, 2. directly
% after stimulation 3. usw

addpath(genpath('C:\Users\saraw\Desktop\BA\EXPRA2019_HIVR\Toolboxes\hMRI-toolbox-0.4.0'))
addpath('C:\Users\saraw\Desktop\BA\EXPRA2019_HIVR\Toolboxes\spm12')

multi_fact = 1;
wait_vol = 8;

%Logs
log_folder = 'C:\Users\saraw\Desktop\SEBs\Logs';
DesignMat = load([log_folder filesep 'DesignMat_subject-1_run-1_slices-36_multi-1_shuffle-1_01-06-2023_14-44-42']).DesignMat;
%Data
func_folder = 'C:\Users\saraw\Desktop\SEBs\Data\sub-001\func';
func_name = 'sub-001_task-SEBs_run-1_bold.nii';
func = niftiread([func_folder filesep func_name]);
dims = size(func);
volumes = dims(4);

%% prepare header info
json_name = 'sub-001_task-SEBs_run-1_bold.json';
json_file = [func_folder, filesep, json_name]; %we select the first json file to extract metadata from 
slice_timing = get_metadata_val(json_file,'SliceTiming'); %extract slice timing
n_slices = height(slice_timing); %compute number of slices from slice timing
[~,y]= sort(slice_timing); %compute slice order 
slice_order = ceil(y/multi_fact)'

%% create list of indices:
% which slice was acquired at which index (out of all slices in the run)
% technically not neccessary
% all_slices_ind = [];
% for s=1:volumes
%     all_slices_ind = [all_slices_ind; slice_order+((s-1)*n_slices)];
% end

%% sort slices into volumes
% "create" empty volume for first slice
volume_0 = load_untouch_nii([func_folder filesep func_name]);
vol_0 = volume_0.img*0;
% fill volume with slices that were stim slices
for v = 1:volumes % go trough volumes: from stim slice to volumes-1 (to have same amount of data without taking stim slices last)
    for sl = 1:n_slices % go through slices first-last (slice timing, NOT physical location)
        % find stim_slice: index of acq slice OR slice(s) after
        stim_slice_ind = DesignMat((DesignMat(:,2)==sl),3)+(v-1); %%% sure abt this?
        retreived_slice_idx = mod(stim_slice_ind,(n_slices/multi_fact)); % this was the xth slice acq in this vol %%%%%%%%%%%%%% what to do about multi?
        if retreived_slice_idx == 0
            retreived_slice_idx = (n_slices/multi_fact); % because modulo
        end
        % find according volume
        stim_vol_ind = ceil(stim_slice_ind/n_slices);
        % find stimulated slice within that volume: mapping from slice time
        sliceInVol_idx = find(slice_order==retreived_slice_idx); % to location (dorsal-ventral) %%%%%%%%%%%%%% what to do about multi?
        % put that slice in the volume
        vol_0(:,:,sliceInVol_idx,v)=func(:,:,sliceInVol_idx,stim_vol_ind);
    end
end
volume_0.img = vol_0;
save_untouch_nii(volume_0, [func_folder filesep 'SEB_' func_name(1:end-4)]);


