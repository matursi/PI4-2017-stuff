function pict = CyclicMap(mat)

dims = size(mat)
if numel(dims) == 3
    mat=reshape(mat,dims(2),dims(3));
end

[mat_lead,~] = ecog_lead(mat,'fro');
[phases, evals] = eig(mat_lead);
size(mat_lead)

phases1 = reshape(phases(:,1),8,8);
phases2 = reshape(phases(:,2),8,8);

phase_angles1 = angle(phases1);
phase_angles2 = angle(phases2);

evals = diag(evals);

start_phase1 = min(phase_angles1(:));
start_phase2 = min(phase_angles2(:));
max_phase1 = max(abs(phase_angles1(:)));
max_phase2 = max(abs(phase_angles2(:)));


figure()
image(40*(phase_angles1 - start_phase1)/max_phase1 )








