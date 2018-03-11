function pic = CyclicMap(mat,dim1,dim2)

dims = size(mat)
if numel(dims) == 3
    mat=reshape(mat,dims(2),dims(3));
end

[mat_lead,~] = lead(mat,'inf');
cond(mat_lead)
[phases, evals] = eig(mat_lead);
size(mat_lead)

phases1 = reshape(phases(:,1),dim1,dim2);
phases2 = phases(:,1);
phases2;
phase_angles1 = angle(phases1);
phase_angles1
phase_angles2 = angle(phases2);

[ordered_phases, indices] = sort(phase_angles2);
pure_angles = phases2(indices).\abs(phases2(indices));
size(pure_angles)

angle_difs=[ mod(phase_angles2(indices(1))-phase_angles2(indices(dim1*dim2)),2*pi) ];

for i=1:(dim1*dim2-1)
    angle_difs(i+1) = angle(phases1(indices(i+1))*conj( phases1(indices(i)) ) );
end
[m, max_index] = max(abs(angle_difs));
% m, max_index
C=reshape(angle_difs,8,8)
%D=reshape(ordered_phases,8,8)
true_index = indices([mod(max_index,dim1*dim2)+1:end 1:mod(max_index,dim1*dim2)]);
size(angle_difs)
phase_angles1 = mod(phase_angles1 - phase_angles1(indices(max_index)),2*pi);

%for i = 2:(dim1*dim2)
%    phase_angles1(true_index(i)) = sum(angle_difs(true_index(1:i)));
%end

phase_angles1
evals = diag(evals);

%Find an apt starting space by letting 


[B,I]=sort(phase_angles1(:));

pic=figure('Position',[800,800,1500,400])

subplot(1,3,1)
image(phase_angles1,'CDataMapping', 'scaled' )
colorbar
subplot(1,3,2)
hold on
plot(real(phases(I,1)), imag(phases(I,1)))
scatter(real(phases(I,1)), imag(phases(I,1)),'filled')
subplot(1,3,3)
scatter(1:dim1*dim2,phase_angles2(I),'filled')
hold off










