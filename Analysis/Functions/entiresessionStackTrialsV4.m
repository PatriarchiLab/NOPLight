function [PreprocessedData_SAVE,TrialParam_SAVE,DataVersions_SAVE,varnames_SAVE,Fs_SAVE] = entiresessionStackTrialsV4(nameGen,allTrials,setupParam,DecayReference)

%% Establish paths to data
path_to_data = '/Users/castine/Dropbox (Bruchas Lab)/TEMPORARY PHOTOMETRY/Carrie_analysis_repository/MatFilesSimple';
 addpath(path_to_data);
 
path_to_timestamps = '/Users/castine/Dropbox (Bruchas Lab)/TEMPORARY PHOTOMETRY/Carrie_analysis_repository/TimeStamps';
 addpath(path_to_timestamps);
 
%% Make array with basic nomenclature and timing info for each trial
a = allTrials.Grouped;
allTrialsID = allTrials.ID;
k = 1:numel(a);

tempID = nameGen(a,:);
filename1 = strcat(tempID(k,3),tempID(k,4),tempID(k,5));
filename = append(filename1,'.mat');

trialtimes = (tempID(k,6))';

eventduration = (cell2mat(tempID(k,7)))';
sessionlength = (cell2mat(tempID(k,8))*60)';
    if numel(unique(sessionlength)) ~= 1
        warning('Trials have differing session lengths, using minimum common session length.')
       sessionlength(:) = min(sessionlength);
    end
delay = (cell2mat(tempID(k,9))*60)';

rawtimestamps = cell(1,length(k));
for d = 1:numel(a)
rawtimestamps{1,d} = dlmread(char(trialtimes{d}));
end

%% Adjust session length and timestamps manually, if desired
if setupParam.manualsessionlength == 1
    sessionlength(:) = setupParam.newsessionlength;
end

if setupParam.manualtimestamps == 1
    for d = 1:numel(a)
    rawtimestamps{1,d} = setupParam.newtimestamps;
    end
end

%% Load unprocessed data for each trial into cell array

Dts = cell(1,length(k)); signal = cell(1,length(k)); reference = cell(1,length(k)); sigsubref = cell(1,length(k));
LoadedData = cell(1,length(k));
for d = 1:numel(a)
    LoadedData{d} = load(filename{d},'FPvalues');
end    

for d = 1:numel(a)
    tempFile = LoadedData{d};
    Dts{1,d} = tempFile.FPvalues.Dts;
    signal{1,d} = tempFile.FPvalues.raw470;
    reference{1,d} = tempFile.FPvalues.raw405;                              % reference means isosbestic
    sigsubref{1,d} = tempFile.FPvalues.rawsub405;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Altered 12/14/22 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Scale reference to signal to detrend bleaching
if setupParam.ScaleRef == 1
    [referenceSCALED,sigsubrefSCALED] = scaleRefToSigV4(Dts,signal,reference,setupParam,delay,k,allTrials);
    clear reference; clear sigsubref;
    reference = referenceSCALED;
    sigsubref = sigsubrefSCALED;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Fs = length(Dts{1})/(Dts{1}(end)); % calculate sampling frequency (this is a known value, but it's better to truly calculate it)

    
structNames = {'Dts' 'signal' 'reference' 'sigsubref'};
structValues = {Dts signal reference sigsubref};
rawData = cell2struct(structValues,structNames,2);

    % check that the all trials are at least as long as the session length
        sesslength_idx = zeros(1,size(rawData.Dts,2)); min_length = floor(Fs*sessionlength(1));
        for d = 1:length(sesslength_idx)
            sesslength_idx(d) = size(rawData.Dts{d},1);
        end
        if any(sesslength_idx<min_length)
            warning('At least one trial is shorter than the designated session length.')
        end
        
%% Store raw data into a matrix
starttime = setupParam.starttime;
chsesslength = floor(sessionlength(k)*Fs);
    idx1 = round(1+(delay*Fs) + (starttime*Fs));
    idx2 = round(chsesslength+(delay*Fs));
   
    %%%% Added 1/10/23      %%%% REMOVED AGAIN 2/10/23, SOMEHOW BROKE THE Z
                            %%%% SCORING
    diffidx = idx2 - idx1;
    if length(unique(diffidx)) > 1
        IDXdist = min(diffidx);
        clear idx2;
        idx2 = idx1 + IDXdist;
    end
    %%%
    
ArrayTemp = zeros(length(idx1:idx2),length(k));
%ArrayTemp = zeros(chsesslength(1),length(k));
for i = 1:length(structNames)
DataArrayTrimmed.(structNames{i}) = ArrayTemp;
end


for i = 1:length(structNames)
    for p = 1:size(DataArrayTrimmed.(structNames{i}),2)
        DataArrayTrimmed.(structNames{i})(:,p) =  rawData.(structNames{i}){p}(idx1(p):idx2(p));
    end
end

%% Smooth all traces
if setupParam.doSmooth == 1
    smooth_window = Fs*setupParam.smooth_win;
    DataArraySmooth.Dts = DataArrayTrimmed.Dts;
        for i = 2:length(structNames)
            DataArraySmooth.(structNames{i}) = movmean(DataArrayTrimmed.(structNames{i}),smooth_window,1);
        end
end

%% Reduce sampling frequency to exclude noise
resampf = setupParam.resamplefactor;
%resampsize = round(idx2./resampf);
    for i = 1:length(structNames)
        DataArrayResampled.(structNames{i}) = downsample(DataArraySmooth.(structNames{i}),resampf);
    end
    

DataVersions.RawCell = rawData;
DataVersions.TrimmedArray = DataArrayTrimmed;
DataVersions.SmoothArray = DataArraySmooth;
DataVersions.ResampledArray = DataArrayResampled;

%% Subtract mean of BL period from entire session for each trace
BLperiod = setupParam.BLperiod;
    BLstart(k) = BLperiod(1) + delay(k);
    BLend(k) = BLperiod(2) + delay(k);
        BLidx1 = zeros(1,length(BLstart)); BLidx2 = zeros(1,length(BLstart));
    for d = 1:size(BLstart,2)
        tempCol = DataArrayResampled.Dts(:,d);
        BLidx1(d) = find(tempCol<BLstart(d),1,'last') + 1;
        BLidx2(d) = find(tempCol<BLend(d),1,'last') + 1;
    end
    
    %%%% Added 1/10/23      %%%% REMOVED AGAIN 2/10/23, SOMEHOW BROKE THE Z
                            %%%% SCORING
%     diffBL = BLidx2 - BLidx1;
%     if length(unique(diffBL)) > 1
%         BLdist = min(diffBL);
%         clear BLidx2;
%         BLidx2 = BLidx1 + BLdist;
%     end
    %%%%
    
for i = 1:length(structNames)
    for d = 1:numel(a)
        DataArrayBLper.(structNames{i})(:,d) = DataArrayResampled.(structNames{i})(BLidx1(d):BLidx2(d),d);
    end
end

for i = 2:length(structNames)
    columnMeans.(structNames{i}) = mean(DataArrayBLper.(structNames{i}),1);
end

DataRecentered.Dts  = DataArrayResampled.Dts;
for i = 2:length(structNames)
    DataRecentered.(structNames{i}) = DataArrayResampled.(structNames{i}) - columnMeans.(structNames{i});
end


PreprocessedData.Raw = DataArrayResampled;
PreprocessedData.Recentered = DataRecentered;

%% Detrend natural LED decay from the signal

% Fit a curve to each trial
if setupParam.RefDecayAdjust == 1
    [FitFunction,FitCurve,DataDecayAdj] = entiresessionRefDecayAdjV2(structNames,DataRecentered,setupParam,allTrials,DecayReference);
else       
    if contains(setupParam.CurveType,'poly')
        for i = 2:length(structNames)
            FitFunction.(structNames{i}) = cell(1,numel(a));
            
            FitCurve.(structNames{i}) = zeros(size(DataRecentered.Dts));
            
            for d = 1:numel(a)
               FitFunction.(structNames{i}){d} = polyfit(DataRecentered.Dts(:,d),DataRecentered.(structNames{i})(:,d),4);
               FitCurve.(structNames{i})(:,d) = polyval(FitFunction.(structNames{i}){d},DataRecentered.Dts(:,d));
                
            end
        end
    elseif contains(setupParam.CurveType,'exp')
        for i = 2:length(structNames)
            FitFunction.(structNames{i}) = cell(1,numel(a));
            FitCurve.(structNames{i}) = zeros(size(DataRecentered.Dts));
            for d = 1:numel(a)
                FitFunction.(structNames{i}){d} = fit(DataRecentered.Dts(:,d),DataRecentered.(structNames{i})(:,d),'exp2');
                FitCurve.(structNames{i})(:,d) = FitFunction.(structNames{i}){d}(DataRecentered.Dts(:,d));
                
           
            end
        end
    end
    
    % Subtract fit curve from recentered data
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ADDED 11/14/22 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if setupParam.ScaleRef == 1
        tempstructNames = {'signal' 'reference'};
        for i = 1:length(tempstructNames)
            DataDecayAdj.(tempstructNames{i}) = DataRecentered.(tempstructNames{i}) - FitCurve.reference; % if scaling reference to signal, decay adjusted signal = signal - curve fit to scaled reference (no motion correction)
            %DataDecayAdj.(tempstructNames{i}) = DataArrayResampled.(tempstructNames{i}) - FitCurve.reference;
        end
        %DataDecayAdj.sigsubref = DataRecentered.sigsubref; % if scaling reference to signal, no further decay adjustment performed on signal - reference
        DataDecayAdj.sigsubref = DataArrayResampled.sigsubref; 
    else
        
        tempstructNames = {'signal' 'reference'};
        for i = 1:length(tempstructNames)
            DataDecayAdj.(tempstructNames{i}) = DataRecentered.(tempstructNames{i}) - FitCurve.(tempstructNames{i});
        end
        DataDecayAdj.sigsubref = DataDecayAdj.signal - DataDecayAdj.reference;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  

end

DataDecayAdj.Dts = DataRecentered.Dts;

PreprocessedData.DecayAdj = DataDecayAdj;

%% Store info about which index refers to which animal and which event

animalindex = k;
eventindex = zeros(2,length(animalindex));
for d  = 1:numel(a)
    if d==1
        eventindex(1,d) = 1;
        eventindex(2,d) = numel(rawtimestamps{d});
    else
        eventindex(1,d) = eventindex(2,d-1) + 1;
        eventindex(2,d) = eventindex(1,d) + numel(rawtimestamps{d}) - 1;
    end
end

   

%% Store Group info
if setupParam.CompareGroups == 1
    groupnames1 = fieldnames(allTrialsID);
    groupidx = zeros(1,numel(groupnames1));
        for i = 1:numel(groupnames1)
            if ~isempty(allTrialsID.(groupnames1{i}))
                groupidx(i) = 1;
            end
        end
    groups = groupnames1(groupidx==1);
    
    expGroups1 =  {'A'; 'B'; 'C'; 'D'; 'E'; 'F'; 'G'; 'H'};
    expGroups = expGroups1(ismember(expGroups1,groups));
    
    refGroups1 = {'T'; 'U'; 'V'; 'W'; 'X'; 'Y'; 'Z'};
    refGroups = refGroups1(ismember(refGroups1,groups));
    
    for g = 1:numel(groups)
        colidx = ismember(allTrials.Grouped,allTrialsID.(groups{g}));
        GroupParam.(groups{g}).animalindex = find(colidx==1);
        GroupParam.(groups{g}).eventindex = eventindex(:,(find(colidx==1)));
    end

    GroupParam.allgroups = groups;
    GroupParam.expgroups = expGroups;
    GroupParam.refgroups = refGroups;
    
    TrialParam.GroupParam = GroupParam;
end
    

%% Store all trial parameters into one struct
TrialParam.sessionlength = sessionlength;
TrialParam.eventduration = eventduration;
TrialParam.delay = delay;
TrialParam.animalindex = animalindex;
TrialParam.eventindex = eventindex;
TrialParam.BLstart = BLstart;
TrialParam.BLend = BLend;
TrialParam.BLper = DataArrayBLper;
TrialParam.BLperMeanRAW = columnMeans;
TrialParam.rawtimestamps = rawtimestamps;
TrialParam.FitCurve = FitCurve;
TrialParam.FitFunction = FitFunction;


PreprocessedData_SAVE = PreprocessedData;
TrialParam_SAVE = TrialParam;
varnames_SAVE = structNames;
Fs_SAVE = Fs;
DataVersions_SAVE = DataVersions;


