function m= angle_analysis(obj, analtype,datafolder)
%analtype = 'regular' or 'difference'

red=[linspace(1,0,50),zeros(1,50)]';
green = [zeros(1,50), linspace(0,1,50)]';
blue = zeros(100,1);

map = [red,green,blue];
clen = obj.runspersubject;
list_of_files = dir('Figures');
list_of_files = {list_of_files.name}';

if ~ismember(datafolder,list_of_files)
str = input('datafolder does not exist.  Do you want to create new file? Y/N [Y]: ','s');
    if strcmp('Y',str)
        mkdir('Figures',datafolder)
    else
        output('exiting program...')
        return;
     end
end


if strcmp(analtype,'regular')
    
    vectors = obj.vectors;
    session = ['1','2']
    run = ['1','2']
    

    for i=session
        for j = run
            ctrind = find(strcmp(cellstr(obj.filenames(:,[1:2 4:7 9:11])),['s' i 'run' j 'ctr']));
            tinind = find(strcmp(cellstr(obj.filenames(:,[1:2 4:7 9:11])),['s' i 'run' j 'tin']));
            
            a=angle_anal(vectors(ctrind,:),vectors(tinind,:),length(ctrind),length(tinind),map);
            title(['Session ' i ' Run ' j ' angle differences'])
           
            savefig(['Figures/' datafolder '/session' i '_run' j '_angles']);
        end
    end
    

elseif strcmp(analtype,'difference')
    

    diffsettings = {'**','1*','2*','*1','*2'};
    vectornums = {[1 2 3 4], [1 2], [1 2], [1 2]};
    full_vector_set = obj.vectors;
 
        
    
s1r1 = full_vector_set(find(strcmp(cellstr(obj.filenames(:,[1 2 4:7])),'s1run1')),:);
s1r2 = full_vector_set(find(strcmp(cellstr(obj.filenames(:,[1 2 4:7])),'s1run2')),:);
s2r1 = full_vector_set(find(strcmp(cellstr(obj.filenames(:,[1 2 4:7])),'s2run1')),:);
s2r2 = full_vector_set(find(strcmp(cellstr(obj.filenames(:,[1 2 4:7])),'s2run2')),:);

size(s1r1(:,:))
size(s1r2(:,1)')
x1=[];
y1=[];
x2=[];
y2=[];

ctrind = find(strcmp(cellstr(obj.filenames(:,[1:2 4:7 9:11])),'s1run1ctr'));
tinind = find(strcmp(cellstr(obj.filenames(:,[1:2 4:7 9:11])),'s1run1tin'));


for i=1:length(obj.subjects)
    x1(i) = acos(s1r1(i,:)*(s1r2(i,:)')/( norm(s1r1(i,:))*norm(s1r2(i,:)) ));
    y1(i) = acos(s2r1(i,:)*(s2r2(i,:)')/( norm(s2r1(i,:))*norm(s2r2(i,:)) ));
    x2(i) = acos(s1r1(i,:)*(s2r1(i,:)')/( norm(s1r1(i,:))*norm(s2r1(i,:)) ));
    y2(i) = acos(s1r2(i,:)*(s2r2(i,:)')/( norm(s1r2(i,:))*norm(s2r2(i,:)) ));

    
    
end

figure('Position',[100,100, 1000,400])
ax1 = subplot(1,2,1)
hold on
scatter(x1(ctrind),y1(ctrind), 'filled');
scatter(x1(tinind),y1(tinind),40, 'd');
legend({'NH','Tin'},'Location','Northwest')
title({'Ses1 vs. Ses2';datafolder})
hold off

labels = [obj.subjects(ctrind); 
          obj.subjects(tinind)]
      
c = [x1(ctrind),x1(tinind);y1(ctrind),y1(tinind)];

[x1(tinind);y1(tinind)]

text(ax1,c(1,:),c(2,:), labels,...
    'VerticalAlignment','bottom','HorizontalAlignment','right');


ax2 = subplot(1,2,2)
hold on
scatter(x2(ctrind),y2(ctrind), 'filled');
scatter(x2(tinind),y2(tinind),40, 'd');
title({'Run1 vs Run2'; datafolder})

c = [x2(ctrind),x2(tinind);y2(ctrind),y2(tinind)];



text(ax2,c(1,:),c(2,:), labels,...
    'VerticalAlignment','bottom','HorizontalAlignment','right');


hold off

savefig(['Figures/' datafolder '/angle_comparisons'])

f=figure

subplot(2,2,1)
hold on
scatter(cos(x1(ctrind)),sin(x1(ctrind)), 'filled');
scatter(cos(x1(tinind)),sin(x1(tinind)),40', 'd');
xlim([-1,1])
ylim([0.3,1.2])
title('Session 1')
legend({'NH','Tin'},'Location','Northwest')
hold off

subplot(2,2,2)
hold on
scatter(cos(x2(ctrind)),sin(x2(ctrind)), 'filled');
scatter(cos(x2(tinind)),sin(x2(tinind)),40, 'd');
xlim([-1,1])
ylim([0.3,1.2])
title('Run 1')
hold off

subplot(2,2,3)
hold on
scatter(cos(y1(ctrind)),sin(y1(ctrind)), 'filled');
scatter(cos(y1(tinind)),sin(y1(tinind)),40, 'd');
xlim([-1,1])
ylim([0.3,1.2])
title('Session 2')
hold off

subplot(2,2,4)
hold on
scatter(cos(y2(ctrind)),sin(y2(ctrind)), 'filled');
scatter(cos(y2(tinind)),sin(y2(tinind)),40,'d');
xlim([-1,1])
ylim([0.3,1.2])
title('Run 2')
hold off

savefig(f,['Figures/' datafolder '/angle_differences_for_sessions_and_runs']);

end

end

function a= angle_anal(vects1,vects2,lengthvar1,lengthvar2,map)

A=[vects1; ones(1,size(vects1,2)); vects2];

B=A*A';

r= ones(lengthvar1+lengthvar2+1,1);
for i=1:lengthvar1
    r(i) = norm(vects1(i,:));
end

for i = 1:lengthvar2
    r(i+1+lengthvar1) = norm(vects2(i,:));
end
length(r)
C = r*r';
C(lengthvar1+1,:)=1;
C(:,lengthvar1+1) = 1;
B(lengthvar1+1,:)=-1;
B(:,lengthvar1+1) = -1;

size(B)
size(C)

angles = B./C;

angles=real(acos(angles));
%angles(1:30,1:30);
a=image(angles,'CDataMapping', 'scaled');

colormap(map)
colorbar
end

