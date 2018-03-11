function [fileseries, filenames] = retrieve_files(session, run,type,subjects)

% Goes into the timeseries file and retrievesthe timeseries txt files into
% numeric matrices.  

%INPUT:     
%   session: put in '1','2', or '*' (to choose sessions 1,2, or both)
%   run: put in '1','2','3', some cell combo, or '*'.  To pick run number
%   type:  type in 'ctr', 'tin', or '*' for both
%   time: put in a an array of integers (between 1 and 300), or ':' to
%   indicate the time intervals you want from the series
%   subjects: use only if you want individual subject data

%OUTPUT:
%   an array with the time series with specifications given by the
%   parameters 


switch nargin
    case 0
        session = '*';
        run = '*';
        type = '*';
        
        subjects = '*';
    case 1  
        run = '*';
        type = '*';
     
        subjects = '*';
    case 2
        type = '*';
    
        subjects = '*';
    case 3
       
        subjects = '*';

end

%Picks filenames with session, run,type, and subject specifications 
fileinfo = dir(['new_rois/overall/s',session,'_run',run,'_',type,'_sub_',subjects,'.txt']);
fileinfo = struct2cell(fileinfo);
filenames = fileinfo(1,:)';
%filenames
[numrois,serieslength] = size(importdata(['new_rois/overall/' filenames{1}]));

fileseries=[];
for i=1:length(filenames)
    fileseries(i,1:numrois,1:serieslength)=importdata(['new_rois/overall/' filenames{i}]);
end

end
