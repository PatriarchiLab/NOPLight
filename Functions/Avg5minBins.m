function [Bin_Table_SAVE,binCheck] = Avg5minBins(ProcessedData,setupParam,BinParam,TrialParam,x)
%delay = TrialParam.delay;
BLperiod = setupParam.BLperiod;

%BLstart = BLperiod(1) + delay;
%BLend = BLperiod(2) + delay;

ST = BinParam.type;


VN1 = {'signal' 'sigsubref' 'dFFentire_sig' 'dFFentire_sigsubref' 'Zentire_sig' 'Zentire_sigsubref'};

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

eventtime = TrialParam.rawtimestamps{1}(1);
sessionlength = TrialParam.sessionlength(1);
%%

Dts = transpose(x.Dts);

bin1Start = (floor(eventtime/60) + 1) * 60;
num_bins = ((sessionlength - bin1Start)/300) + 1;
num_animals = size(ProcessedData.(ST{1}).(VN{1}),2);

%%
binIDX = zeros(2,num_bins);
    binIDX(1,1) = find(Dts < BLperiod(1),1,'last') + 1;
    binIDX(2,1) = find(Dts > BLperiod(2),1,'first') - 1;

    binIDX(1,2) = find(Dts < bin1Start,1,'last') + 1;
    binIDX(2,2) = find(Dts < (bin1Start + 300),1,'last');
    for i = 3:num_bins
        binIDX(1,i) = find(Dts < (bin1Start + 300*(i-2)),1,'last') + 1;
        binIDX(2,i) = find(Dts < (bin1Start + 300*(i-1)),1,'last');
    end
    
binIDX(2,end) = length(Dts);

binCheck = Dts(binIDX);

%%

DataTABLE = zeros(num_bins,num_animals);
for k = 1:num_bins
    clear tempDATA; clear avgtempDATA;
    tempDATA = ProcessedData.(ST{1}).(VN{1})(binIDX(1,k):binIDX(2,k),:);
    avgtempDATA = mean(tempDATA,1);
    DataTABLE(k,:) = avgtempDATA;
end

%%
Bin_Table_SAVE = DataTABLE;




    