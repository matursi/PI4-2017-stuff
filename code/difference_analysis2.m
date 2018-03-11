function [r,az,el,x,y,z,full_vector_set]= difference_analysis2(session,run)
% Run from file above new_rois
% Don't worry about this function so much, was updated by later function
% anyway.
map = [zeros(1,50), linspace(0,1,50); 
    zeros(1,100);linspace(1,0,50),zeros(1,50)]';

% lists subjects in NH and Tin categories
ctr_nums = {'113','115','117','120','122','123',...
            '125','126','166','167','168','169'};
tin_nums = {'102','103','105','106','108','129',...
            '131','132','133','135','136','140',...
            '146','150','152','153','157','158',...
            '160','162','163','174','178'};
        
combine = 'none';

% checks how many "differences" will be generated from the input data.  If
% both inputs were '*', the relevant lead matrix vectors are s1r1,s1r2,s2r1,s2r2.
% Otherwise it's only two lead matrix vectors
if strcmp(run,'*')*strcmp(session,'*') == 1
    vector_nums = [1 2 4 5];
    vlen = 4;
elseif strcmp(run,'*')+strcmp(session,'*') == 1
    vector_nums = [1 2];
    vlen = 2;
else
    error('need either both runs or both sessions for difference analysis')
end

%Set up vectors according tu subject group (to enable easy subtraction)

full_vector_set=[]

vector_indices=[]



%Collect vectors of normal subjects
for i = 1:12
    [~,vectors] = lead_data(run,session,combine,'*',':','none',ctr_nums{i});
    %vectors = vectors(vector_nums,:);
    full_vector_set = [full_vector_set; vectors];
end

%collect vectors of Tinnitus subjects
for i = 13:35
    [~,vectors] = lead_data(run,session,combine,'*',':','none',tin_nums{i-12});
   % vectors = vectors(vector_nums,:); % 1= s1r1,2=s1r2, 3=s1r3,4 = s2r1, 5 = s2r2
    full_vector_set = [full_vector_set; vectors];
end

if vlen == 4
    
F=full_vector_set';
sup = max(abs(F(:)))
F=F/sup;
% Difference between runs for each session
SesRealDifs = [];
RunRealDifs = [];
SesRealDifs = F(:,(1:12)*4-2)-F(:,(1:12)*4-3);                  % Difference between runs in Session 1 NH
SesRealDifs = [SesRealDifs,F(:,(1:12)*4)-F(:,(1:12)*4-1)];      % Difference between runs in Session 2 NH
SesRealDifs = [SesRealDifs,F(:,(13:35)*4-2)-F(:,(1:23)*4-3)];   % Difference between runs for Session 1 Tin
SesRealDifs = [SesRealDifs,F(:,(13:35)*4)-F(:,(1:23)*4-1)];     % Difference between runs for Session 2 Tin

% Difference between sessions for each run
RunRealDifs = F(:,(1:12)*4-1)-F(:,(1:12)*4-3);                  % Difference between sessions for run 1 NH
RunRealDifs = [RunRealDifs,F(:,(1:12)*4)-F(:,(1:12)*4-2)];      % Difference between sessions for run 2 NH 
RunRealDifs = [RunRealDifs, F(:,(13:35)*4-1)-F(:,(1:23)*4-3)];  % Difference between sessions for run 1 Tin
RunRealDifs = [RunRealDifs, F(:,(13:35)*4)-F(:,(1:23)*4-2)];    % Difference between sessions for run 2 Tin

image(RunRealDifs,'CDataMapping','scaled')

'Condition number of dampened matrix is: '
SesCov = cov(SesRealDifs');
RunCov = cov(RunRealDifs');
TotCov = cov([SesRealDifs, RunRealDifs]');

figure
image(RunCov,'CDataMapping','scaled')
colormap(map)

'max is: '
m= max(abs(SesCov(:)))
m2 = max(abs(RunCov(:)))
m3 = max(abs(RunCov(:)))
[u,s,v]=svd(SesCov);
[u2,s2,v2] = svd(RunCov);
[u3,s3,v3] = svd(TotCov);
s=diag(s);
s2=diag(s2);
s3=diag(s3);
s(1:5)
s2(1:5)
s3(1:5)
Acoords = [v(:,1),v(:,2),v(:,3)]\SesRealDifs;
Bcoords = [v2(:,1),v2(:,2),v2(:,3)]\RunRealDifs;
Ccoords = [v2(:,1),v2(:,2),v2(:,3)]\[SesRealDifs,RunRealDifs]; 

size(Acoords)
splits=[1 13 25 48 71];

figure
hold on
for i=1:4
    scatter3(Acoords(1,splits(i):splits(i+1)-1),...
            Acoords(2,splits(i):splits(i+1)-1),...
            Acoords(3,splits(i):splits(i+1)-1),'filled')

end
legend({'NH S1', 'NH S2', 'Tin S1', 'Tin S2'}) 

figure
hold on
for i=1:4
    scatter3(Bcoords(1,splits(i):splits(i+1)-1),...
            Bcoords(2,splits(i):splits(i+1)-1),...
            Bcoords(3,splits(i):splits(i+1)-1),'filled')

end
legend({'NH R1', 'NH R2', 'Tin R1', 'Tin R2'}) 

figure('Position', [100 100 1000 450])
suptitle('projection for all differences')
splits = [splits(1:4), 70+splits];
subplot(1,2,1)
hold on
for i=1:4
    scatter3(Ccoords(1,splits(i):splits(i+1)-1),...
            Ccoords(2,splits(i):splits(i+1)-1),...
            Ccoords(3,splits(i):splits(i+1)-1),'filled')

end
legend({'NH S1', 'NH S2', 'Tin S1', 'Tin S2'})

dx = 0.01;
dy = 0.01;


subplot(1,2,2)
hold on
for i=5:8
    scatter3(Ccoords(1,splits(i):splits(i+1)-1),...
            Ccoords(2,splits(i):splits(i+1)-1),...
            Ccoords(3,splits(i):splits(i+1)-1),'filled')

end
legend({ 'NH R1','NH R2','Tin R1','Tin R2'}) 

if vlen ==2
    
    if strcmp(session,'*') == 1
        titpart = ['Run ' run];
        savepart = ['Run_' run];
    else
        titpart = ['Session ' session];
        savepart = ['Session_' session];
    end 
DifA=Acoords(:,(1:12)*2)-Acoords(:,(1:12)*2-1);
DifB=Bcoords(:,(1:23)*2)-Bcoords(:,(1:23)*2-1);

RealDifA=F(:,(1:12)*2)-F(:,(1:12)*2-1);
RealDifB=F(:,(13:35)*2)-F(:,(13:35)*2-1);

pic = restoreMatrix(sum(RealDifA')',[],[],0,1);
title(['NH Lead difference only ' savepart])
savefig(['Figures/NH_Lead_difference_Only_' savepart])
close
pic =restoreMatrix(sum(RealDifB')',[],[],0,1);
title(['Tin Lead difference only ' savepart])
savefig(['Figures/Tin_Lead_difference_Only_' savepart])
close

r={};
az={};
el={};
x={DifA(1,:),DifB(1,:)};
y={DifA(2,:),DifB(2,:)};
z={DifA(3,:),DifB(3,:)};

A = figure('Position',[100 100 900 400]);
hold on;

suptitle(['Projections of Differences: ' titpart])

subplot(1,2,1)
hold on
scatter3(DifA(1,:),DifA(2,:),DifA(3,:),'filled')
scatter3(DifB(1,:),DifB(2,:),DifB(3,:),'filled')
legend({'Normal Hearing','Tinnitus'},'location','northeast');
xlabel('eigvect 1');
ylabel('eigvect 2');
zlabel('eigvect 3');

[az{1},el{1},r{1}] = cart2sph(DifA(1,:),DifA(2,:),DifA(3,:));
[az{2},el{2},r{2}] = cart2sph(DifB(1,:),DifB(2,:),DifB(3,:));

subplot(1,2,2)
hold on
scatter3(r{1},az{1},el{1},'filled')
scatter3(r{2},az{2},el{2},'filled')
xlabel('radius');
ylabel('azimuth');
zlabel('elevation');


savefig(['Figures/difference_' savepart])
close
    end
end