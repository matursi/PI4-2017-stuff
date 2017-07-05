function [matrices,vectors] = lead_data(session, run, combine, type, time, normalize, subjects)

% Returns the lead matrices for datasets with set parameters.  Inputs must
% be made in the order above if you only want to put a certain amount.
% Also, the "combine" feature allows you to create a lead matrix for
% combinations of time series.  Other than the time variable, the inputs
% are in string form.

% INPUT:
%       session: timeseries session for subject.  Can put in '1', '2', or
%           '*' for both sessions.  Default is '*'
%       run:  timeseries run for subject. parameters are exactly like those
%           of session
%       combine: choose method of combination of tie series for each
%           subject.  Possible choices are 'none','run','session', or 'all'.
%           None leaves the timeseries as in the files.  run combines the 
%           runs from a session into one time series, session combines
%           the same run from two sessions, and all combines all four runs into
%           one series. Default is 'none'. NOTE FOR USER: if session or run is
%           specified other than *, then use the minimal combination parameter.
%           For example, if you choose run 1, and want to combine runs, since
%           there is only one run, the result will be trivial.  
%       type: subject type.  Options are 'ctr','tin',or '*', as in the
%           retrieve_files function.
%       time: a list of whole number values indicating which columns of the
%           time series you are looking build a lead matrix for.
%           subjects: subject number in string form.  Default is ':'. Use a
%           nontrivial time list only if combine is set to 'none'.

% OUTPUT:
%       matrices: a three dimensional array where the first dimension
%           indiciates a time series, and the second and thirs are the
%           dimnesions of the lead matrix
%       vectors: a two dimensional array with columns equal to the values
%           of the upper triangular part of the lead matrices.


% Set up parameters to be used for arguments
if nargin == 0
    session = '*';
end    
if nargin <= 1
    run = '*';
end
if nargin <= 2
    combine = 'none';
end
if nargin <= 3
    type = '*';
end
if nargin <= 4
    time = ':';
end
if nargin <= 5
    normalize = 'fro'
end
if nargin <= 6
    subjects = '*'      
end

if strcmp(time,':')+strcmp(combine,'none') == 0
    error('tried to combine tests with non-trivial times')
end 
%% Main %%

mats = []

%determines combination method and builds a modified timeseries with
%combined data.

switch combine
   
    case 'none'
        mats = retrieve_files(session,run,type,subjects);
    case 'session'
        %check that session combination choice is not redundant.  See
        %description above.
        
        if strcmp(session, '*') == 0
            error(['session combine not necessary,'...
            'since at most have one session chosen. Use * for session'])
        end
        
        %  retrieves time series for sessions 1 and 2
        part1 = retrieve_files('1',run,type,subjects);
        dim1=size(part1);
        part2 = retrieve_files('2',run,type,subjects);
        
        
        dim1
       
        
        % builds combined timeseries, where time is accross both runs of a
        % single session
        mats(1:dim1(1),1:dim1(2),1:dim1(3))=part1;
        mats(1:dim1(1),1:dim1(2),dim1(3)+1:2*dim1(3)) = part2;
        size(mats)
   
    case 'run'
        
        % check that run combination choice is not redundant
        if strcmp(run,'*') == 0
            error(['run combine not necessary, since at most',...
                'have one run chosen.  set run to * instead'])
        end
        
        % retrieves time series for runs 1 and 2
        part1 = retrieve_files(session,'1',type,subjects);
        dim1=size(part1);
        part2 = retrieve_files(session,'2',type,subjects);
        
        % builds combined time series for each subject
        mats(1:dim1(1),1:dim1(2),1:dim1(3))=part1;
        mats(1:dim1(1),1:dim1(2),dim1(3)+1:2*dim1(3)) = part2;
        size(mats)
        
    case 'all'
      
        if strcmp(session,'*')*strcmp(run,'*') == 0
            error(['pick simpler combination: set nontrivial choice',...
                ' of subject or run to *'])
        end
        part1 = retrieve_files('1','1',type,subjects);
        part2 = retrieve_files('1','2',type,subjects);
        part3 = retrieve_files('2','1',type,subjects);
        part4 = retrieve_files('2','2',type,subjects);
        dim1 = size(part1);
        
        % order is session 1 run 1, session 1 run 2, session 2 run 1, session 2 run 2 
        mats(1:dim1(1),1:dim1(2),1:dim1(3))=part1;
        mats(1:dim1(1),1:dim1(2),dim1(3)+1:2*dim1(3)) = part2;
        mats(1:dim1(1),1:dim1(2),2*dim1(3)+1:3*dim1(3)) = part3;
        mats(1:dim1(1),1:dim1(2),3*dim1(3)+1:4*dim1(3)) = part4;
        
        
end


matrices = {};
vectors = [];

s = size(mats(:,:,time))

for i = 1:s(1)
    [m,v]=lead(reshape(mats(i,:,time),s(2),s(3)),normalize);
    matrices = [matrices, m];
    vectors = [vectors;v];
end


end

function names=subjectarray(filenames)

names = {}
for name = filenames
    name = name{1}
    names = [names, name(end-6:end-4)]
end
names
end