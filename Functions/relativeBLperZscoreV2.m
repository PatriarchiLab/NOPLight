function [ProcessedEventWindowData_SAVE,varnamesDATA_SAVE] = relativeBLperZscoreV2(ProcessedEventWindowData,EventWindowDts,varnames,varnamesDATA,setupParam)

ST1 = {'Raw'; 'Recentered'; 'DecayAdj';};
inUseST = fieldnames(ProcessedEventWindowData);
STidx = zeros(1,numel(ST1));
    for i = 1:numel(ST1)
        if ismember(ST1(i),inUseST)
            STidx(i) = 1;
        end
    end
ST = ST1(STidx==1);


%% Calculate Z-score in the time window using an event-relative BL period

BLperiod = setupParam.idxBase;
    BLidx1 = find(EventWindowDts<(BLperiod(1)),1,'last') + 1;
    BLidx2 = find(EventWindowDts>(BLperiod(2)),1,'first') - 1;

Z_ID = {'Zbytrial_sig' 'Zbytrial_ref' 'Zbytrial_sigsubref'};

for t = 1:numel(ST)
    for i = 2:numel(varnames)
        clear sessionBLavg;
        if contains(varnames{i},'signal')
            Z_IDuse = Z_ID(1);
        elseif contains(varnames{i},'reference')
            Z_IDuse = Z_ID(2);
        elseif contains(varnames{i},'sigsubref')
            Z_IDuse = Z_ID(3);
        end
        
        % create empty array (1 x # events) to store BLper average into
        sessionBLavg = zeros(1,size(ProcessedEventWindowData.(ST{t}).(varnames{i}),2));
        sessionSTD = zeros(1,size(sessionBLavg,2));
        % create empty array (2*time window x # events) to store ∆F/F into
        ProcessedEventWindowData.(ST{t}).(Z_IDuse{1}) = zeros(size(ProcessedEventWindowData.(ST{t}).(varnames{i}),1),size(ProcessedEventWindowData.(ST{t}).(varnames{i}),2));
        
        for p = 1:size(sessionBLavg,2)
            sessionBLavg(1,p) = mean(ProcessedEventWindowData.(ST{t}).(varnames{i})(BLidx1:BLidx2,p),1);
            sessionSTD(1,p) = std(ProcessedEventWindowData.(ST{t}).(varnames{i})(BLidx1:BLidx2,p));
            ProcessedEventWindowData.(ST{t}).(Z_IDuse{1})(:,p) = (ProcessedEventWindowData.(ST{t}).(varnames{i})(:,p) - sessionBLavg(1,p))./sessionSTD(1,p);
        end
    end
end

%%

tempData = ProcessedEventWindowData.(ST{1});
tempFieldNames = fieldnames(tempData);

Znames = transpose(tempFieldNames(contains(tempFieldNames,Z_ID)));
varnamesDATA_SAVE = [varnamesDATA Znames];

ProcessedEventWindowData_SAVE = ProcessedEventWindowData;



