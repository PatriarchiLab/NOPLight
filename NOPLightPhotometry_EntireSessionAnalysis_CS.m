%% SCRIPT FOR PHOTOMETRY ANALYSIS - EVENT WINDOW
% Script for processing and analysis of raw photometry signal over the entire trace (only one event/timestamp). 
% Written by Carrie Stine, 12/14/2022. Direct questions to castine@uw.edu.

%% Reset MatLab workspace - clears all variables and the command window

clear variables;  % clear all variables
close all;  % close all open graphs
clc   % clear command window

%% EDIT THESE FIELDS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Enter trial info
spreadsheetName = 'nameGeneratorNOPLightGroupedExptPHARM_V2.csv';

T = [] - 1; %ADJUST input rows of nameGenerator spreadsheet trials that correspond to your first reference group
U = [] - 1; %ADJUST input rows of nameGenerator spreadsheet trials that correspond to your second reference group
V = [] - 1; %ADJUST see above
W = [] - 1; %ADJUST see above
X = [] - 1; %ADJUST see above
Y = [] - 1; %ADJUST see above
Z = [] - 1; %ADJUST see above

A = [2:5] - 1; %#ok<*NBRAK> %ADJUST row numbers for trials averaged in group 1
DecayReference.A = {'T'}; %ADJUST change to whichever reference group corresponds to experimental group 1

B = [65:72] - 1; %ADJUST row numbers for trials averaged in group 2
DecayReference.B = {'T'}; %ADJUST change to whichever reference group corresponds to experimental group 2

C = [75:82] - 1; %ADJUST see above
DecayReference.C = {'T'}; %ADJUST see above

D = [92:99] - 1; %ADJUST see above
DecayReference.D = {'W'}; %ADJUST see above

E = [] - 1; %ADJUST see above
DecayReference.E = {'T'}; %ADJUST see above

F = [] - 1; %ADJUST see above
DecayReference.F = {'Y'}; %ADJUST see above

G = [] - 1; %ADJUST see above
DecayReference.G = {'Z'}; %ADJUST see above

H = [] - 1; %ADJUST see above
DecayReference.H = {'Z'}; %ADJUST see above


% Set group/averaging/smoothing parameters

    RefDecayAdjust = 0; % ADJUST to 1 if you want to match exp trials to reference trials based on curve clustering as the method for decay adjustment
    
    CompareGroups = 1; % ADJUST to 1 if you are comparing multiple groups (A vs B, etc), 0 if you are just looking at trials in A
    CombineGroups = 0; % ADJUST to 1 if you want to look at the combination of all groups post decay adjustment
    
    averageall = 1; % ADJUST to 1 if you want to average all trials for all animals, or 0 if you want to average trials within an animal then average those averages
    
    resamplefactor = 300; % ADJUST to factor you want to resample data at
    
    CurveType = 'poly'; % ADJUST to 'exp' or 'poly' depending on if you want to fit exponential or polynomial curves for decay adjustment
    
    ScaleRef = 1; % ADJUST to 1 to detrend bleaching decay by fitting (scaling) the reference to the signal
    scaleref_BLper = 1; % ADJUST to 1 to scale ref to sig using JUST the BL period bleaching. Good for entire session decay with pharmacology, but for transient events set this to 0 to scale using entire trace

    doSmooth = 1; % ADJUST to 1 if want to apply smoothing to the trace
    smooth_win = 30; % ADJUST period of time for smoothing, in seconds


% Set timing parameters

    manualsessionlength = 0; % ADJUST if sessions compared are not the same length
    newsessionlength = 3000;% ADJUST to lowest common session length, in seconds
    
    BLperiod = [3 260]; %ADJUST to period of time where you want to baseline the trace to (in seconds, ie 1 to 260s when injection is at 300s)
    
    starttime = 2; % ADJUST to time (in seconds) that you want to treat as the beginning of the session
    
    %Event window specific stuff below, doesn't need to be adjusted for
    %this entire session script (just keeping it here to make updating
    %either version easier)
    timewindow = 60; %ADJUST +/- window (seconds) around each event that you want to pull out data for (must contain idxBase values in range)
    
    viewtimewindow = 0; % ADJUST if you want to plot a smaller subset of time than the entire time window of data you'll be analyzing
    viewtimewindowVal = 20; % ADJUST +/- window (seconds) that you want to see in the final plot
    
    manualtimestamps = 0; % ADJUST if you want to override the session's timestamps to enter uniform timestamps manually for all sessions
    newtimestamps = [120;240;360;480]; %ADJUST to array of timestamps that you want to use instead

    idxBase = [-30 -15]; % ADJUST to window of time (seconds) relative to each event that you want to use as each event's baseline window 

% Set plot color parameters

    comparisonOptions = {'1: green gradient' '2: blue gradient' '3: red gradient' '4: gray gradient' '5: paired multicolor' '6: 405/470 vs 435/490' '7: choose colors in photomplotColor'};
    comparisonType = 1; %ADJUST to number corresponding to comparisonOption you want the colors to be. Gradients are light to dark

    PlotIndividual = 0; %ADJUST if you want to see graphs for each ind animal
    

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%% Establish paths, setup spreadsheet info as cell array

path_to_functions = '/Users/castine/Dropbox (Bruchas Lab)/TEMPORARY PHOTOMETRY/Carrie_analysis_repository/FunctionsForAnalysis';
 addpath(path_to_functions);
 
path_to_functions2 = '/Users/castine/Dropbox (Bruchas Lab)/TEMPORARY PHOTOMETRY/Carrie_analysis_repository/FunctionsForAnalysis/AnalysisFunctions';
 addpath(path_to_functions2);

path_to_functions3 = '/Users/castine/Dropbox (Bruchas Lab)/TEMPORARY PHOTOMETRY/Carrie_analysis_repository/FunctionsForAnalysis/PlotFunctions';
 addpath(path_to_functions3); 
 
path_to_spreadsheet = '/Users/castine/Dropbox (Bruchas Lab)/TEMPORARY PHOTOMETRY/Carrie_analysis_repository';
 addpath(path_to_spreadsheet);

    nameGenerator = readtable(spreadsheetName); 
    nameGen = table2cell(nameGenerator); % turn spreadsheet with trial info into a cell array
 
%% Prep variables in format needed for functions
    clear allTrials; clear setupParam;
    allTrials.Grouped = [A B C D E F G H T U V W X Y Z];
    allTrials.ID.A = A; allTrials.ID.B = B; allTrials.ID.C = C; allTrials.ID.D = D; allTrials.ID.E = E; allTrials.ID.F = F; allTrials.ID.G = G; allTrials.ID.H = H; allTrials.ID.T = T; allTrials.ID.U = U; allTrials.ID.V = V; allTrials.ID.W = W; allTrials.ID.X = X; allTrials.ID.Y = Y; allTrials.ID.Z = Z; allTrials.ID.R = [T U V W X Y Z];
    
   
    setupParam_NAMES = {'CompareGroups', 'CombineGroups', 'averageall', 'resamplefactor', 'CurveType', 'RefDecayAdjust', 'ScaleRef', 'scaleref_BLper', 'doSmooth', 'smooth_win', 'manualsessionlength', 'newsessionlength', 'manualtimestamps', 'newtimestamps', 'starttime', 'timewindow', 'viewtimewindow', 'viewtimewindowVal', 'BLperiod', 'idxBase', 'comparisonType', 'PlotIndividual'};
    setupParam_VALUES = {CompareGroups CombineGroups averageall resamplefactor CurveType RefDecayAdjust ScaleRef scaleref_BLper doSmooth smooth_win manualsessionlength newsessionlength manualtimestamps newtimestamps starttime timewindow viewtimewindow viewtimewindowVal BLperiod idxBase comparisonType PlotIndividual};

    setupParam = cell2struct(setupParam_VALUES,setupParam_NAMES,2);

    
    
    
    
    
    
    
%% Combine time series info for all trials (together and by group) into a single struct

[PreprocessedData,TrialParam,DataVersions,varnames,Fs] = entiresessionStackTrialsV4(nameGen,allTrials,setupParam,DecayReference);

varnamesDATA = varnames(2:end);

%% Plot individual traces
if setupParam.PlotIndividual == 1
    plotIndividualEntire(PreprocessedData,allTrials,setupParam,TrialParam.FitCurve)
end
    
%% Calculate ∆F/F of entire session using fixed BL period in the session

clc
[ProcessedData,varnamesDATA,Dts] = fixedBLperDFFV4(PreprocessedData,TrialParam,varnames,varnamesDATA);


%% Calculate Z-score of entire session using fixed BL period in the session

[ProcessedData,varnamesDATA] = fixedBLperZscoreV4(ProcessedData,Dts,TrialParam,varnames,varnamesDATA);


%% Generate within group averages and calculate SEM

[DataAVG] = entiresessionAverageV2(ProcessedData,varnamesDATA,setupParam,TrialParam,allTrials);

%% Format final processed data for plotting

[x,y,eb] = entiresessionPlotFormatV2(DataAVG,Dts,varnamesDATA,setupParam,TrialParam,allTrials);

%% Obtain average signal for each animal in 5 min time bins

BinParam.type  = {'DecayAdj'}; % can be: 'Raw' 'Recentered' 'DecayAdj'
BinParam.process = 'Zentire'; % can be: 'none' 'dFFentire' 'Zentire'
BinParam.data = 'sigsubref'; % can be: 'sig', 'sigsubref'

[BIN_Table,binCheck] = Avg5minBins(ProcessedData,setupParam,BinParam,TrialParam,x);

%% Obtain area under curve for each animal

AUCParam.type = {'DecayAdj'}; % can be: 'Raw' 'Recentered' 'DecayAdj'
AUCParam.process = 'dFFentire'; % can be: 'none' 'dFFentire' 'Zentire'
AUCParam.data = 'sigsubref'; % can be: 'sig', 'sigsubref'

[AUC_Table] = entiresessionAUC(ProcessedData,setupParam,AUCParam,TrialParam,x);
%% Plot signal and reference together

entiresessionPhotomPlot_SigRefV2(x,y,eb,setupParam,TrialParam,allTrials);

%% Plot standard figures together

%entiresessionPhotomPlot_StandardV2(x,y,eb,setupParam,TrialParam,allTrials);

%% Plot figures as you choose
loneFigure.fignum = 101;
loneFigure.type = {'DecayAdj'}; % can be: 'Raw' 'Recentered' 'DecayAdj'
loneFigure.data = 'Zentire'; % can be: 'none' 'dFFentire' 'Zentire'
entiresessionPhotomPlot_LoneFigV2(x,y,eb,setupParam,TrialParam,allTrials,loneFigure);


