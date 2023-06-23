function [DataAVG_SAVE] = eventwindowAverageV2(ProcessedEventWindowData,varnamesDATA,setupParam,TrialParam,allTrials)

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
    
    numexpAnimals1 = zeros(1,numel(expGroups));
    for d = 1:numel(expGroups)
        numexpAnimals1(d) = numel(allTrialsID.(expGroups(d)));
    end
    numexpAnimals = sum(numexpAnimals1);
    
%     refGroups1 = ['T'; 'U'; 'V'; 'W'; 'X'; 'Y'; 'Z'];
%     refGroups = refGroups1(ismember(refGroups1,groups));
end

%% Setup data name parameters
ST1 = {'Raw'; 'Recentered'; 'DecayAdj'};
inUseST = fieldnames(ProcessedEventWindowData);
STidx = zeros(1,numel(ST1));
    for i = 1:numel(ST1)
        if ismember(ST1(i),inUseST)
            STidx(i) = 1;
        end
    end
ST = ST1(STidx==1);

%% Average all experimental animals (all groups combined)

if setupParam.averageall == 1
    for t = 1:numel(ST)
        for i = 1:numel(varnamesDATA)
            clear temp_toAVG;
            if setupParam.CompareGroups == 1
                expidx1 = GroupParam.(expGroups(1)).eventindex(1,1);
                expidx2 = GroupParam.(expGroups(end)).eventindex(2,end);
                temp_toAVG = ProcessedEventWindowData.(ST{t}).(varnamesDATA{i})(:,expidx1:expidx2);
            else
                temp_toAVG = ProcessedEventWindowData.(ST{t}).(varnamesDATA{i});
            end
            
            DataAVG1.all.average.(ST{t}).(varnamesDATA{i}) = mean(temp_toAVG,2);
            DataAVG1.all.sem.(ST{t}).(varnamesDATA{i}) = std(temp_toAVG,0,2)./sqrt(size(temp_toAVG,2));
        end
    end
    
elseif setupParam.averageall == 0
    for t = 1:numel(ST)
        for i = 1:numel(varnamesDATA)
            clear temp_toAVG; clear all_toAVG;
            if setupParam.CompareGroups == 1
                temp_toAVG = zeros(size(ProcessedEventWindowData.(ST{t}).(varnamesDATA{i}),1),numexpAnimals);
                
                expidx1 = GroupParam.(expGroups(1)).eventindex(1,1);
                expidx2 = GroupParam.(expGroups(end)).eventindex(2,end);
                
                all_toAVG = ProcessedEventWindowData.(ST{t}).(varnamesDATA{i})(:,expidx1:expidx2);
                
                for p = 1:numexpAnimals
                    temp_toAVG(:,p) = mean(all_toAVG(:,TrialParam.eventindex(1,p):TrialParam.eventindex(2,p)),2);
                end
                
                
            else
                temp_toAVG = zeros(size(ProcessedEventWindowData.(ST{t}).(varnamesDATA{i}),1),numel(allTrials.Grouped));
                all_toAVG = ProcessedEventWindowData.(ST{t}).(varnamesDATA{i});
                
                for p = 1:numel(allTrials.Grouped)
                    temp_toAVG(:,p) = mean(all_toAVG(:,TrialParam.eventindex(1,p):TrialParam.eventindex(2,p)),2);
                end
            end
            
            DataAVG1.all.average.(ST{t}).(varnamesDATA{i}) = mean(temp_toAVG,2);
            DataAVG1.all.sem.(ST{t}).(varnamesDATA{i}) = std(temp_toAVG,0,2)./sqrt(size(temp_toAVG,2));
        end
    end
end

    
%% Calculate average and SEM by group
if setupParam.CompareGroups == 1
    if setupParam.averageall == 1
        for g = 1:numel(groups)
            clear groupidx1; clear groupidx2;
            groupidx1 = GroupParam.(groups{g}).eventindex(1,1);
            groupidx2 = GroupParam.(groups{g}).eventindex(2,end);
            
            for t = 1:numel(ST)
                for i = 1:numel(varnamesDATA)
                    temp_toAVGgroup.(groups{g}) = ProcessedEventWindowData.(ST{t}).(varnamesDATA{i})(:,groupidx1:groupidx2);

                    DataAVG1.(groups{g}).average.(ST{t}).(varnamesDATA{i}) = mean(temp_toAVGgroup.(groups{g}),2);
                    DataAVG1.(groups{g}).sem.(ST{t}).(varnamesDATA{i}) = std(temp_toAVGgroup.(groups{g}),0,2)./sqrt(size(temp_toAVGgroup.(groups{g}),2));
                end
            end
        end
        
    elseif setupParam.averageall == 0
        for g = 1:numel(groups)
            for t = 1:numel(ST)
                for i = 1:numel(varnamesDATA)
                    clear all_toAVGgroup;
                    temp_toAVGgroup.(groups{g}) = zeros(size(ProcessedEventWindowData.(ST{t}).(varnamesDATA{i}),1),numel(allTrialsID.(groups{g})));
                    
                    all_toAVGgroup = ProcessedEventWindowData.(ST{t}).(varnamesDATA{i});
                    
                    for p = 1:size(GroupParam.(groups{g}).eventindex,2)
                        temp_toAVGgroup.(groups{g})(:,p) = mean(all_toAVGgroup(:,GroupParam.(groups{g}).eventindex(1,p):GroupParam.(groups{g}).eventindex(2,p)),2);
                    end
                    
                    DataAVG1.(groups{g}).average.(ST{t}).(varnamesDATA{i}) = mean(temp_toAVGgroup.(groups{g}),2);
                    DataAVG1.(groups{g}).sem.(ST{t}).(varnamesDATA{i}) = std(temp_toAVGgroup.(groups{g}),0,2)./sqrt(size(temp_toAVGgroup.(groups{g}),2));
                end
            end
        end
    end
end
    
 %%
 DataAVG_SAVE = DataAVG1;
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    