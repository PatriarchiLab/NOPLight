function entiresessionPhotomPlot_SigRefV2(x,y,eb,setupParam,TrialParam,allTrials)

allTrialsID = allTrials.ID;

if setupParam.CompareGroups == 1
%     GroupParam = TrialParam.GroupParam;
    groupnames1 = fieldnames(allTrialsID);
    groupidx = zeros(1,numel(groupnames1));
        for i = 1:numel(groupnames1)
            if ~isempty(allTrialsID.(groupnames1{i}))
                groupidx(i) = 1;
            end
        end
    groups = groupnames1(groupidx==1);
    
%     expGroups1 =  ['A'; 'B'; 'C'; 'D'; 'E'; 'F'; 'G'; 'H'];
%     expGroups = expGroups1(ismember(expGroups1,groups));
    
    refGroups1 = ['T'; 'U'; 'V'; 'W'; 'X'; 'Y'; 'Z'];
    plotgroups = groups(~ismember(groups,refGroups1));
%     refGroups = refGroups1(ismember(refGroups1,groups));
end

%% Setup data name/timing parameters
All = y.all;
ST1 = {'Raw'; 'Recentered'; 'DecayAdj'};
inUseST = fieldnames(All);
STidx = zeros(1,numel(ST1));
    for i = 1:numel(ST1)
        if ismember(ST1(i),inUseST)
            STidx(i) = 1;
        end
    end
ST = ST1(STidx==1);

% VN1 = varnamesDATA(~contains(varnamesDATA,'Z'));
% VN = VN1(~contains(VN1,'dFF'));

VN = {'signal' 'reference' 'sigsubref'};

eventtime = TrialParam.rawtimestamps{1}(1);
eventduration = TrialParam.eventduration(1);

%% Plot combined signal, reference, and signal - reference on one plot

% Setup variable names/color
legID = {'signal' 'reference' 'sig - ref'};
choosecolor = {'#0c9cf8' '#330672' 'g'};


tempX = x.Dts;

if setupParam.CompareGroups == 0 || setupParam.CombineGroups == 1
    figure(10)
    numcol = numel(ST);
    for t = 1:numel(ST)
        spSpot = t;
        subplot(1,numcol,spSpot)
        
        for i = 1:numel(VN)
            [currenttitle] = photomplotTitle(ST(t),VN(i));
            
            tempY = y.all.(ST{t}).(VN{i});
            tempEBlo = eb.all.lo.(ST{t}).(VN{i});
            tempEBhi = eb.all.hi.(ST{t}).(VN{i});
            
            leg(i) = plot(tempX,tempY,'Color',string(choosecolor(i)),'LineWidth',2); %#ok<AGROW>
            hold on
                filledEBtemp = patch([tempX fliplr(tempX)],[tempEBlo fliplr(tempEBhi)],'k');
                alpha(filledEBtemp,0.2)
                filledEBtemp.EdgeAlpha = 0;
                set(filledEBtemp,'edgecolor',string(choosecolor(i)),'facecolor',string(choosecolor(i)))
        end
        xlim([tempX(1) tempX(end)])
        yl = ylim;
        tempYL = ((floor(yl(1)) - 1):(round(yl(2)) + 1));
            if any(ismember((tempYL),0))
                line([tempX(1) tempX(end)], [0 0],'Color','k');
            end
        line([eventtime eventtime],[yl(1) yl(2)],'Color','k');
        line([(eventtime + eventduration) (eventtime + eventduration)],[yl(1) yl(2)],'Color','k');
        ylim(yl)

        ylabel(sprintf('%s',currenttitle.Yaxis));
        xlabel('Time (s)')
        title(sprintf('Combined %s %s signal and reference',currenttitle.ST,currenttitle.Calc))
        legend(leg,legID)
       
    end
 
    sname = 'CarrieCustom';
    S = hgexport('readstyle',sname);
%     style.Format = 'png';
%     style.ApplyStyle = '1';
    hgexport(gcf,'file_name',S,'applystyle',true);

    hold off
end


%%  By Group: Plot combined signal, reference, and signal - reference on one plot

if setupParam.CompareGroups == 1
    for g = 1:numel(plotgroups)
        figure(10+g)
        
        numcol = numel(ST);
        for t = 1:numel(ST)
            spSpot = t;
            subplot(1,numcol,spSpot)

            for i = 1:numel(VN)
                [currenttitle] = photomplotTitle(ST(t),VN(i));
            
                tempY = y.(plotgroups{g}).(ST{t}).(VN{i});
                tempEBlo = eb.(plotgroups{g}).lo.(ST{t}).(VN{i});
                tempEBhi = eb.(plotgroups{g}).hi.(ST{t}).(VN{i});

                leg(i) = plot(tempX,tempY,'Color',string(choosecolor(i)),'LineWidth',2);
                hold on
                    filledEBtemp = patch([tempX fliplr(tempX)],[tempEBlo fliplr(tempEBhi)],'k');
                    alpha(filledEBtemp,0.2)
                    filledEBtemp.EdgeAlpha = 0;
                    set(filledEBtemp,'edgecolor',string(choosecolor(i)),'facecolor',string(choosecolor(i)))
            end

            xlim([tempX(1) tempX(end)])
            yl = ylim;
            tempYL = ((floor(yl(1)) - 1):(round(yl(2)) + 1));
                if any(ismember((tempYL),0))
                    line([tempX(1) tempX(end)], [0 0],'Color','k');
                end
            line([eventtime eventtime],[-1000 1000],'Color','k');
            line([(eventtime + eventduration) (eventtime + eventduration)],[-1000 1000],'Color','k');
            ylim(yl)
            
            ylabel(sprintf('%s',currenttitle.Yaxis));
            xlabel('Time (s)')
            title(sprintf('Group %s %s signal and reference',plotgroups{g},currenttitle.ST))
            legend(leg,legID)

        end

        sname = 'CarrieCustom';
        S = hgexport('readstyle',sname);
    %     style.Format = 'png';
    %     style.ApplyStyle = '1';
        hgexport(gcf,'file_name',S,'applystyle',true);

        hold off
    end

end

%% Scale all axes across groups to be the same for simple comparison
for g = 1:numel(plotgroups)
    figure(10+g)
    for t = 1:numel(ST)
        spSpot = t;
        subplot(1,numcol,spSpot)
        YLgroup.(ST{t})(g,1:2) = ylim;
    end
end

for g = 1:numel(plotgroups)
    for t = 1:numel(ST)
        YLuse.(ST{t})(1,1) = min(YLgroup.(ST{t})(:,1));
        YLuse.(ST{t})(1,2) = max(YLgroup.(ST{t})(:,2));
    end
end

for g = 1:numel(plotgroups)
    figure(10+g)
    for t = 1:numel(ST)    
        spSpot = t;
        subplot(1,numcol,spSpot)
        ylim(YLuse.(ST{t}))
    end
end

