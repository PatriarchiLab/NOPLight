function [binTable_SAVE] = eventwindowBins(ProcessedEventWindowData,BinParam,TrialParam,x)

ST = BinParam.type;

VN1 = {'signal' 'sigsubref' 'dFFentire_sig' 'dFFentire_sigsubref' 'Zentire_sig' 'Zentire_sigsubref' 'dFFbytrial_sig' 'dFFbytrial_sigsubref' 'Zbytrial_sig' 'Zbytrial_sigsubref'};

if contains(BinParam.process,'none')
    VN2 = VN1(~contains(VN1,'Z'));
    VN_all = VN2(~contains(VN2,'dFF'));
else
    VN_all = VN1(contains(VN1,BinParam.process));
end

if contains(BinParam.data,'sigsubref')
    VN = VN_all(contains(VN_all,'sigsubref'));
else
    VN = VN_all(~contains(VN_all,'sigsubref'));
end

%% Find indices where bin window start/end prior to event and after the event

Dts = transpose(x.Dts);
idxPOST(1) = length(Dts)/2 + 1; % find midway point of time window
idxPOST(2) = find(Dts > BinParam.window,1,'first') - 1;

BinSize = idxPOST(2) - idxPOST(1);

idxPRE(1) = idxPOST(1) - 1 - BinSize;
idxPRE(2) = length(Dts)/2;

%%
binTable = cell(1,numel(TrialParam.animalindex));

for i = 1:numel(TrialParam.animalindex)
    clear tempAVG; clear avgPRE; clear avgPOST; clear tempData; clear tempDataPRE; clear tempDataPOST;
    currTrialsIDX(1) = TrialParam.eventindex(1,i);
    currTrialsIDX(2) = TrialParam.eventindex(2,i);
    
    tempData = ProcessedEventWindowData.(ST{1}).(VN{1})(:,currTrialsIDX(1):currTrialsIDX(2));
    
    tempDataPRE = tempData(idxPRE(1):idxPRE(2),:);
    tempDataPOST = tempData(idxPOST(1):idxPOST(2),:);
    
    avgPRE = mean(tempDataPRE,1);
    avgPOST = mean(tempDataPOST,1);
    
    tempAVG = zeros(size(avgPRE,2),3);
        tempAVG(:,1) = TrialParam.rawtimestamps{i};
        tempAVG(:,2) = transpose(avgPRE);
        tempAVG(:,3) = transpose(avgPOST);
        
    binTable{i} = tempAVG;
end


%%
binTable_SAVE = binTable;
















