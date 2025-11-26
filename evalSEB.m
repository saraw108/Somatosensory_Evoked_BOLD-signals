%%% i test for SEBs, somehow

multi_fact = 3;
wait_vol = 8;

log_folder = 'C:\Users\saraw\Desktop\SEBs\Logs';
phantomMat = load([log_folder filesep 'DesignMat_subject-1_run-1_slices-36_multi-3_shuffle-1_01-06-2023_15-00-16']);
DesignMat = phantomMat.DesignMat;

func_folder = 'C:\Users\saraw\Desktop\SEBs\Data\sub-001\func';

json_name = 'sub-001_task-SEBs_run-4_bold_4.json';
json_file = [func_folder, filesep, json_name]; %we select the first json file to extract metadata from 
slice_timing = get_metadata_val(json_file,'SliceTiming'); %extract slice timing
n_slices = height(slice_timing); %compute number of slices from slice timing
if multi_fact == 1
    [~,y]= sort(slice_timing); %compute slice order 
    slice_order = y';
else
    [~,y]= sort(slice_timing); %compute slice order 
    slice_order = ceil(y/multi_fact)'
end

func_name = 'sub-001_task-SEBs_run-4_bold_4.nii';

func = niftiread([func_folder filesep func_name]);
dims = size(func);
volumes = dims(4);

all_slices_ind = [];
for s=1:volumes
    all_slices_ind = [all_slices_ind; slice_order+((s-1)*n_slices)];
end

interesting_voxel = [15 32 25];

slice_ind_theor = all_slices_ind(:,interesting_voxel(3));
activation_course = [];
slice_ind_pract = [];
temp = 0;
for s = 1:n_slices/multi_fact
    if slice_ind_theor(1)+(s-1) <= n_slices/multi_fact
        slice_ind_pract = [slice_ind_pract DesignMat((DesignMat(:,2)==slice_ind_theor(1)+(s-1)),3)];
        temp = temp+1;
    else
        slice_ind_pract = [slice_ind_pract DesignMat((DesignMat(:,2)==(s-temp)),3)];
    end
end
for v = 1:wait_vol
    slice_ind_pract = [slice_ind_pract slice_ind_pract(1:n_slices/multi_fact)+((n_slices/multi_fact)*v)];
end
pract_vol = ceil(slice_ind_pract/(n_slices/multi_fact));
for p = 1:volumes
    activation_course = [activation_course func(interesting_voxel(1),interesting_voxel(2),interesting_voxel(3), p)];
end

% act(5,:)=activation_course;

plot(activation_course)