function [ProcessedEventWindowData_SAVE,varnamesDATA_SAVE] = relativeBLperDFFV2(EventWindowData,EventWindowDts,varnames,varnamesDATA,setupParam)

ST1 = {'Raw'; 'Recentered'; 'DecayAdj';};
inUseST = fieldnames(EventWindowData);
STidx = zeros(1,numel(ST1));
    for i = 1:numel(ST1)
        if ismember(ST1(i),inUseST)
            STidx(i) = 1;
        end
    end
ST = ST1(STidx==1);

%% Calculate ∆F/F in the time window using an event-relative BL period

BLperiod = setupParam.idxBase;
    BLidx1 = find(EventWindowDts<(BLperiod(1)),1,'last') + 1;
    BLidx2 = find(EventWindowDts>(BLperiod(2)),1,'first') - 1;

DFF_ID = {'dFFbytrial_sig' 'dFFbytrial_ref' 'dFFbytrial_sigsubref'};

for t = 1:numel(ST)
    for i = 2:numel(varnames)
        clear sessionBLavg;
        if contains(varnames{i},'signal')
            DFF_IDuse = DFF_ID(1);
        elseif contains(varnames{i},'reference')
            DFF_IDuse = DFF_ID(2);
        elseif contains(varnames{i},'sigsubref')
            DFF_IDuse = DFF_ID(3);
        end
        
        % create empty array (1 x # events) to store BLper average into
        sessionBLavg = zeros(1,size(EventWindowData.(ST{t}).(varnames{i}),2));
        
        % create empty array (2*time window x # events) to store ∆F/F into
        EventWindowData.(ST{t}).(DFF_IDuse{1}) = zeros(size(EventWindowData.(ST{t}).(varnames{i}),1),size(EventWindowData.(ST{t}).(varnames{i}),2));
        
        for p = 1:size(sessionBLavg,2)
            sessionBLavg(1,p) = mean(EventWindowData.(ST{t}).(varnames{i})(BLidx1:BLidx2,p),1);
            EventWindowData.(ST{t}).(DFF_IDuse{1})(:,p) = (EventWindowData.(ST{t}).(varnames{i})(:,p) - sessionBLavg(1,p))./abs(sessionBLavg(1,p));
        end
    end
end

%%

tempData = EventWindowData.(ST{1});
tempFieldNames = fieldnames(tempData);

dFFnames = transpose(tempFieldNames(contains(tempFieldNames,DFF_ID)));
varnamesDATA_SAVE = [varnamesDATA dFFnames];

ProcessedEventWindowData_SAVE = EventWindowData;






