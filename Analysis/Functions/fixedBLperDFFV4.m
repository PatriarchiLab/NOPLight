function [ProcessedData_SAVE,varnamesDATA_SAVE,Dts_SAVE] = fixedBLperDFFV4(PreprocessedData,TrialParam,varnames,varnamesDATA)

ST1 = {'Raw'; 'Recentered'; 'DecayAdj';};
inUseST = fieldnames(PreprocessedData);
STidx = zeros(1,numel(ST1));
    for i = 1:numel(ST1)
        if ismember(ST1(i),inUseST)
            STidx(i) = 1;
        end
    end
ST = ST1(STidx==1);


%% Calculate ∆F/F using entire session BL period

BLstart = TrialParam.BLstart;
BLend = TrialParam.BLend;
BLidx1 = zeros(1,length(BLstart)); BLidx2 = zeros(1,length(BLstart));
    for d = 1:size(BLstart,2)
        tempCol = PreprocessedData.(ST{1}).Dts(:,d);
        BLidx1(d) = find(tempCol<BLstart(d),1,'last') + 1;
        BLidx2(d) = find(tempCol<BLend(d),1,'last') + 1;
    end
    
    %%%% Added 1/10/23
%     diffBL = BLidx2 - BLidx1;
%     if length(unique(diffBL)) > 1
%         BLdist = min(diffBL);
%         clear BLidx2;
%         BLidx2 = BLidx1 + BLdist;
%     end
%     %%%%

DFF_ID = cell(1,(numel(varnames)-1));

STtemp = ST;
STtemp(contains(STtemp,'Recentered')) = [];
for i = 2:numel(varnames)
        if contains(varnames{i},'signal')
            DFF_ID{i} = 'dFFentire_sig';
        elseif contains(varnames{i},'reference')
            DFF_ID{i} = 'dFFentire_ref';
        elseif contains(varnames{i},'sigsubref')
            DFF_ID{i} = 'dFFentire_sigsubref';
        end

        for t = 1:numel(STtemp)
            pr = size(PreprocessedData.(STtemp{t}).(varnames{i}),1);
            pc = size(PreprocessedData.(STtemp{t}).(varnames{i}),2);
            DataDFF.(STtemp{t}).(DFF_ID{i}) = zeros(pr,pc);

            for d = 1:size(PreprocessedData.(STtemp{t}).(varnames{i}),2)
                BLper.(STtemp{t}).(varnames{i})(:,d) = PreprocessedData.(STtemp{t}).(varnames{i})(BLidx1(d):BLidx2(d),d);
            end

            columnMeans.(STtemp{t}).(varnames{i}) = abs(mean(BLper.(STtemp{t}).(varnames{i}),1)) + 1; % add arbitrary value to means and to data to prevent it from having a BL period sub 0
            

            DataDFF.(STtemp{t}).(DFF_ID{i}) =  ((PreprocessedData.(STtemp{t}).(varnames{i})+1) - columnMeans.(STtemp{t}).(varnames{i}))./columnMeans.(STtemp{t}).(varnames{i})*100;
            
        end
        DataDFF.Recentered.(DFF_ID{i}) = DataDFF.Raw.(DFF_ID{i});
end


    
%%   Save new variable names and final ∆F/F data
DFFnames = DFF_ID(2:end);

for t = 1:numel(ST)
    for i = 1:numel(varnamesDATA)
        ProcessedData1.(ST{t}).(varnamesDATA{i}) = PreprocessedData.(ST{t}).(varnamesDATA{i});
    end
    
    for i = 1:numel(DFFnames)
        ProcessedData1.(ST{t}).(DFFnames{i}) = DataDFF.(ST{t}).(DFFnames{i});
    end
end

varnamesDATAnew = [varnamesDATA DFFnames];

varnamesDATA_SAVE = varnamesDATAnew;
Dts_SAVE = PreprocessedData.(ST{1}).Dts;
ProcessedData_SAVE = ProcessedData1;
       

   
        
        
       
   
