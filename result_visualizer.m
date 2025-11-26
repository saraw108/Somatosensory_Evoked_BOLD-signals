% a skript that masks tvals and saves them as overlays for MRIcron,
% hopefully

mask_dir = 'C:\Users\mcnbf\Desktop\sara\SEBs\permutationTesting\3D_masks_s4_positive';
result_dir = 'D:\SEBs\Data\2nd_level_-FINAL_FIR_4er_noDep_4_72_bins_1-way-ANOVA';
save_dir = 'C:\Users\mcnbf\Desktop\sara\SEBs\for_figures';

for b = 1:72

    t_num = b+72;
    if t_num < 10
        t_str = ['spmT_000' num2str(t_num) '.nii'];
    elseif t_num < 100
        t_str = ['spmT_00' num2str(t_num) '.nii'];
    else
        t_str = ['spmT_0' num2str(t_num) '.nii'];
    end

    mask = niftiread([mask_dir filesep 'mask_3D_3clusters_bin-' num2str(b) '.nii']);
    info = niftiinfo([result_dir filesep t_str]);
    data = niftiread([result_dir filesep t_str]);

    visual = zeros(79,95,79);
    visual(mask>0) = data(mask>0);
    visual = cast(visual, 'single');
    niftiwrite(visual,[save_dir filesep 'masked_tvals-' num2str(b) '.nii'], info);

end