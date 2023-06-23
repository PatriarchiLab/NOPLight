function [DataAVG_SAVE] = entiresessionAverageV2(ProcessedData,varnamesDATA,setupParam,TrialParam,allTrials)

% Setup group info (if there are groups)
allTrialsID = allTrials.ID;

if setupParam.CompareGroups == 1
    GroupParam = TrialParam.GroupParam;
    groupnames1 = fieldnames(allTrialsID);
    groupidx = zeros(1,numel(groupnames1));
        for i = 1:numel(groupnames1)
            if ~isempty(allTrialsID.(groupnames1{i}))
                groupidx(i) = 1;
            end
        end
    groups = groupnames1(groupidx==1);
    
    expGroups1 =  ['A'; 'B'; 'C'; 'D'; 'E'; 'F'; 'G'; 'H'];
    expGroups = expGroups1(ismember(expGroups1,groups));
    
%     refGroups1 = ['T'; 'U'; 'V'; 'W'; 'X'; 'Y'; 'Z'];
%     refGroups = refGroups1(ismember(refGroups1,groups));
end

%% Setup data name parameters
ST1 = {'Raw'; 'Recentered'; 'DecayAdj'};
inUseST = fieldnames(ProcessedData);
STidx = zeros(1,numel(ST1));
    for i = 1:numel(ST1)
        if ismember(ST1(i),inUseST)
            STidx(i) = 1;
        end
    end
ST = ST1(STidx==1);

%% Average all experimental animals (all groups combined)

    for t = 1:numel(ST)
        for i = 1:numel(varnamesDATA)
            if setupParam.CompareGroups == 1
                expidx1 = GroupParam.(expGroups(1)).animalindex(1,1);
                expidx2 = GroupParam.(expGroups(end)).animalindex(1,end);
                temp_toAVG = ProcessedData.(ST{t}).(varnamesDATA{i})(:,expidx1:expidx2);
            else
                temp_toAVG = ProcessedData.(ST{t}).(varnamesDATA{i});
            end
            
            DataAVG1.all.average.(ST{t}).(varnamesDATA{i}) = mean(temp_toAVG,2);
            DataAVG1.all.sem.(ST{t}).(varnamesDATA{i}) = std(temp_toAVG,0,2)./sqrt(size(temp_toAVG,2));
        end
    end
    
%% Calculate average and SEM by group
if setupParam.CompareGroups == 1
    for g = 1:numel(groups)
        clear groupidx1; clear groupidx2;
        groupidx1 = GroupParam.(groups{g}).animalindex(1,1);
        groupidx2 = GroupParam.(groups{g}).animalindex(1,end);
        
        for t = 1:numel(ST)
            for i = 1:numel(varnamesDATA)
                clear temp_toAVGgroup;
                temp_toAVGgroup = ProcessedData.(ST{t}).(varnamesDATA{i})(:,groupidx1:groupidx2);
                
                DataAVG1.(groups{g}).average.(ST{t}).(varnamesDATA{i}) = mean(temp_toAVGgroup,2);
                DataAVG1.(groups{g}).sem.(ST{t}).(varnamesDATA{i}) = std(temp_toAVGgroup,0,2)./sqrt(size(temp_toAVGgroup,2));
            end
        end
    end
end

DataAVG_SAVE = DataAVG1;
        
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                