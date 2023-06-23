function [ProcessedData_SAVE,varnamesDATA_SAVE] = fixedBLperZscoreV4(Data,Dts,TrialParam,varnames,varnamesDATA)

ST1 = {'Raw'; 'Recentered'; 'DecayAdj';};
inUseST = fieldnames(Data);
STidx = zeros(1,numel(ST1));
    for i = 1:numel(ST1)
        if ismember(ST1(i),inUseST)
            STidx(i) = 1;
        end
    end
ST = ST1(STidx==1);


%% Calculate Z-score using entire session BL period
BLstart = TrialParam.BLstart;
BLend = TrialParam.BLend;
BLidx1 = zeros(1,length(BLstart)); BLidx2 = zeros(1,length(BLstart));
    for d = 1:size(BLstart,2)
        tempCol = Dts(:,d);
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
    %%%%

Z_ID = {'Zentire_sig' 'Zentire_ref' 'Zentire_sigsubref'};

%                 sessionBL = mean(tempSession(BLstart:BLend));
%                 sessionSTD = std(tempSession(BLstart:BLend));
%                 tempzTrial = (tempSession - sessionBL)./sessionSTD;
%                 superStackZ1.(string(ST(t))).(Z_ID)(:,p) = tempzTrial;
    
    if  any(ismember(ST,'Recentered'))
        STtemp = ST;
        STtemp(contains(STtemp,'Recentered')) = [];
        STtemp(contains(STtemp,'Raw')) = [];
        
        % Calculate Z score for raw and recentered data using original
        % baseline (their Z score is identical, since Recentered is just 
        % the Raw baseline subtraction. Don't want to accidentally double normalize.)
        for i = 2:numel(varnames)
            if contains(varnames{i},'signal')
                Z_IDuse = Z_ID(1);
            elseif contains(varnames{i},'reference')
                Z_IDuse = Z_ID(2);
            elseif contains(varnames{i},'sigsubref')
                Z_IDuse = Z_ID(3);
            end
            sessionSTD.Recentered.(varnames{i}) = zeros(1,size(TrialParam.BLperMeanRAW.(varnames{i}),2));
            
            for d = 1:size(sessionSTD.Recentered.(varnames{i}),2)
                sessionSTD.Recentered.(varnames{i})(1,d) = std(TrialParam.BLper.(varnames{i})(:,d));
            end
            
            Data.Recentered.(Z_IDuse{1}) = Data.Recentered.(varnames{i})./sessionSTD.Recentered.(varnames{i});
            Data.Raw.(Z_IDuse{1}) = Data.Recentered.(Z_IDuse{1});
        end
        
        sessionSTD.Raw = sessionSTD.Recentered;
        columnMeans.Raw = TrialParam.BLperMeanRAW;
        columnMeans.Recentered = TrialParam.BLperMeanRAW;
        
    else
        STtemp = ST;
    end
    
    % Calculate Z score for decay adj (and raw, if recentered doesn't
    % exist)
        for i = 2:numel(varnames)
            if contains(varnames{i},'signal')
                Z_IDuse = Z_ID(1);
            elseif contains(varnames{i},'reference')
                Z_IDuse = Z_ID(2);
            elseif contains(varnames{i},'sigsubref')
                Z_IDuse = Z_ID(3);
            end
    
            % Create empty array to fill Z score data into
            for t = 1:numel(STtemp)
                pr = size(Data.(STtemp{t}).(varnames{i}),1);
                pc = size(Data.(STtemp{t}).(varnames{i}),2);
                Data.(STtemp{t}).(Z_IDuse{1}) = zeros(pr,pc);
                
                % Pull out subset of data within the BL period, each column
                % = 1 animal
                for d = 1:size(Data.(STtemp{t}).(varnames{i}),2)
                    BLper.(STtemp{t}).(varnames{i})(:,d) = Data.(STtemp{t}).(varnames{i})(BLidx1(d):BLidx2(d),d);
                end
                
                % Create empty array to put BL per means and STDs into
                columnMeans.(STtemp{t}).(varnames{i}) = zeros(1,size(Data.(STtemp{t}).(varnames{i}),2));
                sessionSTD.(STtemp{t}).(varnames{i}) = zeros(1,size(Data.(STtemp{t}).(varnames{i}),2));
                
                % Calculate mean and standard deviation of each BL per column
                for d = 1:size(Data.(STtemp{t}).(varnames{i}),2)
                    columnMeans.(STtemp{t}).(varnames{i})(1,d) = mean(BLper.(STtemp{t}).(varnames{i})(:,d),1);
                    sessionSTD.(STtemp{t}).(varnames{i})(1,d) = std(BLper.(STtemp{t}).(varnames{i})(:,d));
                end

                Data.(STtemp{t}).(Z_IDuse{1}) = (Data.(STtemp{t}).(varnames{i}) - columnMeans.(STtemp{t}).(varnames{i}))./sessionSTD.(STtemp{t}).(varnames{i});
            end
        end

%% Store new variable names, final structs to save

tempData = Data.(STtemp{1});
tempFieldNames = fieldnames(tempData);
        
Znames = transpose(tempFieldNames(contains(tempFieldNames,Z_ID)));       
varnamesDATAnew = [varnamesDATA Znames];

varnamesDATA_SAVE = varnamesDATAnew;
ProcessedData_SAVE = Data;
        
        
        
        
        
        
        
        