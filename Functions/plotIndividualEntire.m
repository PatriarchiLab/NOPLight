function plotIndividualEntire(PreprocessedData,allTrials,setupParam,FitCurve)

tempX = PreprocessedData.DecayAdj.Dts;
allTrialsID = allTrials.ID;

    if setupParam.CompareGroups == 0
        figure(1)
        %signal
        subplot(3,3,1)
            title('Raw Signal')
            hold on
            plot(tempX,PreprocessedData.Raw.signal,'Color','b');
        subplot(3,3,2)
            title('Recentered Signal')
            hold on
            plot(tempX,PreprocessedData.Recentered.signal,'Color','b');
            plot(tempX,FitCurve.signal,'r')
        subplot(3,3,3)
            if setupParam.RefDecayAdjust == 1
                title('(Reference) Decay Adjusted Signal')
            else
                title('Decay Adjusted Signal')
            end
            hold on
            plot(tempX,PreprocessedData.DecayAdj.signal,'Color','b');
            
        %reference
        subplot(3,3,4)
            title('Raw Reference')
            hold on
            plot(tempX,PreprocessedData.Raw.reference,'Color','b');
        subplot(3,3,5)
            title('Recentered Reference')
            hold on
            plot(tempX,PreprocessedData.Recentered.reference,'Color','b');
            plot(tempX,FitCurve.reference,'r')
        subplot(3,3,6)
            if setupParam.RefDecayAdjust == 1
                title('(Reference) Decay Adjusted Reference')
            else
                title('Decay Adjusted Reference')
            end
            hold on
            plot(tempX,PreprocessedData.DecayAdj.reference,'Color','b');
            
        %signal - reference
        subplot(3,3,7)
            title('Raw Sig - Ref')
            hold on
            plot(tempX,PreprocessedData.Raw.sigsubref,'Color','b');
        subplot(3,3,8)
            title('Recentered Sig - Ref')
            hold on
            plot(tempX,PreprocessedData.Recentered.sigsubref,'Color','b');
            plot(tempX,FitCurve.sigsubref,'r')
        subplot(3,3,9)
            if setupParam.RefDecayAdjust == 1
                title('(Reference) Decay Adjusted Sig - Ref')
            else
                title('Decay Adjusted Sig - Ref')
            end
            hold on
            plot(tempX,PreprocessedData.DecayAdj.sigsubref,'Color','b');
            hold off
    elseif setupParam.CompareGroups == 1
        groupnames1 = fieldnames(allTrialsID);
        groupidx = zeros(1,numel(groupnames1));
            for i = 1:numel(groupnames1)
                if ~isempty(allTrialsID.(groupnames1{i}))
                    groupidx(i) = 1;
                end
            end
        groups1 = groupnames1(groupidx==1);
        if ismember('R',groups1)
            J = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H' 'R'};
            groups = groups1(contains(groups1,J));
        else
            groups = groups1;
        end
        numgroups = numel(groups);
        [choosecolor] = photomplotColor(setupParam,numgroups);
            if ismember(choosecolor(1),'k')
                choosecolor2 = [choosecolor(2:numgroups) {'k'}];
            else 
                choosecolor2 = [choosecolor(1:numgroups-1) {'k'}];
            end
        
        for i = 1:numel(groups)
            plotidx1 = find(allTrialsID.(groups{i})(1)==allTrials.Grouped);
            plotidx2 = find(allTrialsID.(groups{i})(end)==allTrials.Grouped);
            figure(i)
            %signal
            subplot(3,3,1)
                title('Raw Signal')
                hold on
                plot(tempX(:,plotidx1:plotidx2),PreprocessedData.Raw.signal(:,plotidx1:plotidx2),'Color',choosecolor2{i});
            subplot(3,3,2)
                title('Recentered Signal')
                hold on
                plot(tempX(:,plotidx1:plotidx2),PreprocessedData.Recentered.signal(:,plotidx1:plotidx2),'Color',choosecolor2{i});
                plot(tempX(:,plotidx1:plotidx2),FitCurve.signal(:,plotidx1:plotidx2),'r')
            subplot(3,3,3)
                if setupParam.RefDecayAdjust == 1
                    title('(Reference) Decay Adjusted Signal')
                else
                    title('Decay Adjusted Signal')
                end
                hold on
                plot(tempX(:,plotidx1:plotidx2),PreprocessedData.DecayAdj.signal(:,plotidx1:plotidx2),'Color',choosecolor2{i});

            %reference
            subplot(3,3,4)
                title('Raw Reference')
                hold on
                plot(tempX(:,plotidx1:plotidx2),PreprocessedData.Raw.reference(:,plotidx1:plotidx2),'Color',choosecolor2{i});
            subplot(3,3,5)
                title('Recentered Reference')
                hold on
                plot(tempX(:,plotidx1:plotidx2),PreprocessedData.Recentered.reference(:,plotidx1:plotidx2),'Color',choosecolor2{i});
                plot(tempX(:,plotidx1:plotidx2),FitCurve.reference(:,plotidx1:plotidx2),'r')
            subplot(3,3,6)
                if setupParam.RefDecayAdjust == 1
                    title('(Reference) Decay Adjusted Reference')
                else
                    title('Decay Adjusted Reference')
                end
                hold on
                plot(tempX(:,plotidx1:plotidx2),PreprocessedData.DecayAdj.reference(:,plotidx1:plotidx2),'Color',choosecolor2{i});

            %signal - reference    
            subplot(3,3,7)
                title('Raw Sig - Ref')
                hold on
                plot(tempX(:,plotidx1:plotidx2),PreprocessedData.Raw.sigsubref(:,plotidx1:plotidx2),'Color',choosecolor2{i});
            subplot(3,3,8)
                title('Recentered Sig - Ref')
                hold on
                plot(tempX(:,plotidx1:plotidx2),PreprocessedData.Recentered.sigsubref(:,plotidx1:plotidx2),'Color',choosecolor2{i});
                plot(tempX(:,plotidx1:plotidx2),FitCurve.sigsubref(:,plotidx1:plotidx2),'r')
            subplot(3,3,9)
                if setupParam.RefDecayAdjust == 1
                    title('(Reference) Decay Adjusted Sig - Ref')
                else
                    title('Decay Adjusted Sig - Ref')
                end
                hold on
                plot(tempX(:,plotidx1:plotidx2),PreprocessedData.DecayAdj.sigsubref(:,plotidx1:plotidx2),'Color',choosecolor2{i});   
                hold off
        end
    end
    hold off