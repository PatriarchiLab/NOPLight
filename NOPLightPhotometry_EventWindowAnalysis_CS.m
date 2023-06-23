
%% SCRIPT FOR PHOTOMETRY ANALYSIS - EVENT WINDOW
% Script for processing and analysis of raw photometry signal with multiple event windows. 
% Written by Carrie Stine, 11/01/2022. Direct questions to castine@uw.edu.

%% Reset MatLab workspace - clears all variables and the command window

clear variables;  % clear all variables
close all;  % close all open graphs
clc   % clear command window

%% EDIT THESE FIELDS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Enter trial info
spreadsheetName = 'nameGeneratorNOPLightGroupedExptBEHAVIOR.csv';

T = [] - 1; %ADJUST input rows of nameGenerator spreadsheet trials that correspond to your first reference group
U = [] - 1; %ADJUST input rows of nameGenerator spreadsheet trials that correspond to your second reference group
V = [] - 1; %ADJUST see above
W = [] - 1; %ADJUST see above
X = [] - 1; %ADJUST see above
Y = [] - 1; %ADJUST see above
Z = [] - 1; %ADJUST see above

A = [] - 1; %#ok<*NBRAK> %ADJUST row numbers for trials averaged in group 1
DecayReference.A = {'T'}; %ADJUST change to whichever reference group corresponds to experimental group 1

B = [] - 1; %ADJUST row numbers for trials averaged in group 2
DecayReference.B = {'T'}; %ADJUST change to whichever reference group corresponds to experimental group 2

C = [] - 1; %ADJUST see above
DecayReference.C = {'V'}; %ADJUST see above

D = [] - 1; %ADJUST see above
DecayReference.D = {'W'}; %ADJUST see above

E = [] - 1; %ADJUST see above
DecayReference.E = {'X'}; %ADJUST see above

F = [] - 1; %ADJUST see above
DecayReference.F = {'Y'}; %ADJUST see above

G = [] - 1; %ADJUST see above
DecayReference.G = {'Z'}; %ADJUST see above

H = [] - 1; %ADJUST see above
DecayReference.H = {'Z'}; %ADJUST see above


% Set group/averaging/smoothing parameters

    CompareGroups = 1; % ADJUST to 1 if you are comparing multiple groups (A vs B, etc), 0 if you are just looking at trials in A
    
    CombineGroups = 0; % ADJUST to 1 if you want to look at the combination of all groups post decay adjustment
    
    averageall = 1; %ADJUST to 1 if you want to average all trials for all animals, or 0 if you want to average trials within an animal then average those averages
    
    resamplefactor = 300; % ADJUST to factor you want to resample data at
    
    CurveType = 'poly'; % ADJUST to 'exp' or 'poly' depending on if you want to fit exponential or polynomial curves for decay adjustment
    
    RefDecayAdjust = 0; % ADJUST to 1 if you want to match exp trials to reference trials based on curve clustering as the method for decay adjustment
    
    ScaleRef = 0; % ADJUST to 1 to detrend bleaching decay by fitting (scaling) the reference to the signal BEFORE fitting a curve
    ScaleRef_PostDecay = 1; % ADJUST to 1 to fit (scale) the reference to the signal AFTER fitting/subtracting a curve to account for decay
        scaleref_BLper = 0; % ADJUST to 1 to scale ref to sig using JUST the BL period bleaching. Good for entire session decay with pharmacology, but for transient events set this to 0 to scale using entire trace

    doSmooth = 1; % ADJUST to 1 if want to apply smoothing to the trace
    smooth_win = 1; % ADJUST period of time for smoothing, in seconds

    ZtoSession = 1; % ADJUST to 1 if you want to z score to the entire session length and not just the baseline period
    
% Set timing parameters
    manualsessionlength = 0; % ADJUST if sessions compared are not the same length
    newsessionlength = 600;% ADJUST to lowest common session length, in seconds
    
    manualtimestamps = 0; % ADJUST if you want to override the session's timestamps to enter uniform timestamps manually for all sessions
    newtimestamps = [120;240;360;480]; %ADJUST to array of timestamps that you want to use instead

    starttime = 2; % ADJUST to time (in seconds) that you want to treat as the beginning of the session
    
    timewindow = 30; %ADJUST +/- window (seconds) around each event that you want to pull out data for (must contain idxBase values in range)
    
    viewtimewindow = 1; % ADJUST if you want to plot a smaller subset of time than the entire time window of data you'll be analyzing
    viewtimewindowVal = 20; % ADJUST +/- window (seconds) that you want to see in the final plot
    
    BLperiod = [3 100]; %ADJUST to period of time where you want to baseline the trace to (in seconds, ie 1 to 260s when injection is at 300s)
    idxBase = [-20 20]; % ADJUST to window of time (seconds) relative to each event that you want to use as each event's baseline window 

% Set plot color parameters

    comparisonOptions = {'1: green gradient' '2: blue gradient' '3: red gradient' '4: gray gradient' '5: paired multicolor' '6: 405/470 vs 435/490' '7: choose colors in photomplotColor'};
    comparisonType = 6; %ADJUST to number corresponding to comparisonOption you want the colors to be. Gradients are light to dark

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
    
   
    setupParam_NAMES = {'CompareGroups', 'CombineGroups', 'averageall', 'resamplefactor', 'CurveType', 'RefDecayAdjust', 'ScaleRef', 'scaleref_BLper', 'doSmooth', 'smooth_win', 'ZtoSession', 'manualsessionlength', 'newsessionlength', 'manualtimestamps', 'newtimestamps', 'starttime', 'timewindow', 'viewtimewindow', 'viewtimewindowVal', 'BLperiod', 'idxBase', 'comparisonType', 'PlotIndividual'};
    setupParam_VALUES = {CompareGroups CombineGroups averageall resamplefactor CurveType RefDecayAdjust ScaleRef scaleref_BLper doSmooth smooth_win ZtoSession manualsessionlength newsessionlength manualtimestamps newtimestamps starttime timewindow viewtimewindow viewtimewindowVal BLperiod idxBase comparisonType PlotIndividual};

    setupParam = cell2struct(setupParam_VALUES,setupParam_NAMES,2);

    
    
    
%% Combine time series info for all trials (together and by group) into a single struct

[PreprocessedData,TrialParam,DataVersions,varnames,Fs] = entiresessionStackTrialsV4(nameGen,allTrials,setupParam,DecayReference);

varnamesDATA = varnames(2:end);

%% Plot individual traces

plotIndividualEntire(PreprocessedData,allTrials,setupParam,TrialParam.FitCurve)
    
%% Scale isosbestic to signal using LLS after decay adjustment
if ScaleRef_PostDecay == 1
    [scaledRef,scaledSigSubRef] = scaleRefToSig_postDecayV4(PreprocessedData.DecayAdj.Dts,PreprocessedData.DecayAdj,setupParam,TrialParam.delay,allTrials);
        PreprocessedData.DecayAdj.reference = scaledRef;
        PreprocessedData.DecayAdj.sigsubref = scaledSigSubRef;
end

%% Calculate ∆F/F of entire session using fixed BL period in the session

clc
[ProcessedData,varnamesDATA,Dts] = fixedBLperDFFV4(PreprocessedData,TrialParam,varnames,varnamesDATA);


%% Calculate Z-score of entire session using fixed BL period in the session

[ProcessedData,varnamesDATA] = fixedBLperZscoreV4(ProcessedData,Dts,TrialParam,varnames,varnamesDATA);

%% Extract and align time window around each event for each session

[EventWindowData,EntireSessionData,EventWindowDts] = eventwindowStackEventsV2(ProcessedData,Dts,varnamesDATA,setupParam,TrialParam,Fs);

%% Calculate ∆F/F of each event using BL period relative to each event

[ProcessedEventWindowData,varnamesDATA] = relativeBLperDFFV2(EventWindowData,EventWindowDts,varnames,varnamesDATA,setupParam);


%% Calculate Z-score of each event using BL period relative to each event

[ProcessedEventWindowData,varnamesDATA] = relativeBLperZscoreV2(ProcessedEventWindowData,EventWindowDts,varnames,varnamesDATA,setupParam);


%% Generate within group averages and calculate SEM

[DataAVG] = eventwindowAverageV2(ProcessedEventWindowData,varnamesDATA,setupParam,TrialParam,allTrials);


%% Format final processed data for plotting

[x,y,eb] = eventwindowPlotFormatV2(DataAVG,EventWindowDts,varnamesDATA,setupParam,allTrials); % this function is identical to the entiresessionPlotFormatV2 function

%% Extract averaged values in window around event

BinParam.type  = {'DecayAdj'}; % can be: 'Raw' 'Recentered' 'DecayAdj'
BinParam.process = 'Zentire'; % can be: 'none' 'dFFentire' 'Zentire' 'dFFbytrial' 'Zbytrial'
BinParam.data = 'sigsubref'; % can be: 'sig', 'sigsubref'
BinParam.window = 2; % time in seconds that you want to average data into on either side of the event

[binTable] = eventwindowBins(ProcessedEventWindowData,BinParam,TrialParam,x);




%% Plot signal and reference together

%eventwindowPhotomPlot_SigRefV2(x,y,eb,setupParam,TrialParam,allTrials,ProcessedEventWindowData);

%% Plot standard figures together

%eventwindowPhotomPlot_StandardV2(x,y,eb,setupParam,TrialParam,allTrials,ProcessedEventWindowData,varnamesDATA);

%% Plot figures as you choose
loneFigure.fignum = 200;
loneFigure.type = {'DecayAdj'}; % can be: 'Raw' 'Recentered' 'DecayAdj'
loneFigure.data = 'Zbytrial'; % can be: 'none' 'dFFentire' 'Zentire' 'dFFbytrial' 'Zbytrial'
eventwindowPhotomPlot_LoneFigV2(x,y,eb,setupParam,TrialParam,allTrials,ProcessedEventWindowData,loneFigure);
sname = 'CarrieCustom';
    S = hgexport('readstyle',sname);

    hgexport(gcf,'file_name',S,'applystyle',true);



%% Plot figures as you choose
loneFigure.fignum = 300;
loneFigure.type = {'DecayAdj'}; % can be: 'Raw' 'Recentered' 'DecayAdj'
loneFigure.data = 'none'; % can be: 'none' 'dFFentire' 'Zentire' 'dFFbytrial' 'Zbytrial'
eventwindowPhotomPlot_LoneFigV2(x,y,eb,setupParam,TrialParam,allTrials,ProcessedEventWindowData,loneFigure);
sname = 'CarrieCustom';
    S = hgexport('readstyle',sname);

    hgexport(gcf,'file_name',S,'applystyle',true);