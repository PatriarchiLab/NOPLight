function entiresessionPhotomPlot_LoneFigV2(x,y,eb,setupParam,TrialParam,allTrials,loneFigure)

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
    
     plotGroups1 =  {'R'; 'A'; 'B'; 'C'; 'D'; 'E'; 'F'; 'G'; 'H'};
     legendID1 = {'vehicle' 'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H'};
     
     plotgroups = plotGroups1(ismember(plotGroups1,groups));
     legendID = legendID1(find(ismember(plotGroups1,plotgroups))); %#ok<FNDSB>
%     refGroups1 = ['T'; 'U'; 'V'; 'W'; 'X'; 'Y'; 'Z'];
%     plotgroups = groups(~ismember(groups,refGroups1));
    numgroups = numel(plotgroups);
%     refGroups = refGroups1(ismember(refGroups1,groups));
else
    numgroups = 0;
end

%% Setup data name/timing parameters
ST = loneFigure.type;

% VN1 = varnamesDATA(~contains(varnamesDATA,'Z'));
% VN = VN1(~contains(VN1,'dFF'));

VN1 = {'signal' 'sigsubref' 'dFFentire_sig' 'dFFentire_sigsubref' 'Zentire_sig' 'Zentire_sigsubref'};

if contains(loneFigure.data,'none')
    VN2 = VN1(~contains(VN1,'Z'));
    VN = VN2(~contains(VN2,'dFF'));
else
    VN = VN1(contains(VN1,loneFigure.data));
end

eventtime = TrialParam.rawtimestamps{1}(1);
eventduration = TrialParam.eventduration(1);

%% Setup plot coloring parameters

[choosecolor] = photomplotColor(setupParam,numgroups);

%%

tempX = x.Dts;

if setupParam.CompareGroups == 0 || setupParam.CombineGroups == 1
    figure(loneFigure.fignum)
    for t = 1:numel(ST)
        for i = 1:numel(VN)
            spSpot = ((t-1)*numel(VN)) + i;
            subplot(t,numel(VN),spSpot)
            hold off
            [currenttitle] = photomplotTitle(ST(t),VN(i));

            tempY = y.all.(ST{t}).(VN{i});
            tempEBlo = eb.all.lo.(ST{t}).(VN{i});
            tempEBhi = eb.all.hi.(ST{t}).(VN{i});
            
            plot(tempX,tempY,'Color',string(choosecolor(2)),'LineWidth',2)
            hold on
                filledEBtemp = patch([tempX fliplr(tempX)],[tempEBlo fliplr(tempEBhi)],'k');
                alpha(filledEBtemp,0.2)
                filledEBtemp.EdgeAlpha = 0;
                set(filledEBtemp,'edgecolor',string(choosecolor(2)),'facecolor',string(choosecolor(2)))


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
            title(sprintf('%s %s %s',currenttitle.Calc, currenttitle.ST, currenttitle.Data))
            hold off
        end
    end
    
    sname = 'CarrieCustom';
    S = hgexport('readstyle',sname);
%     style.Format = 'png';
%     style.ApplyStyle = '1';
    hgexport(gcf,'file_name',S,'applystyle',true);

    
end

%% Plot by group

if setupParam.CompareGroups == 1
    figure(loneFigure.fignum + 1)
    for t = 1:numel(ST)
        for i = 1:numel(VN)
            spSpot = ((t-1)*numel(VN)) + i;
            subplot(t,numel(VN),spSpot)
            hold off
            [currenttitle] = photomplotTitle(ST(t),VN(i));
            
            leg = zeros(1,numel(plotgroups));
            for g = 1:numel(plotgroups)
                tempY = y.(plotgroups{g}).(ST{t}).(VN{i});
                tempEBlo = eb.(plotgroups{g}).lo.(ST{t}).(VN{i});
                tempEBhi = eb.(plotgroups{g}).hi.(ST{t}).(VN{i});

                leg(g) = plot(tempX,tempY,'Color',string(choosecolor(g)),'LineWidth',2);
                hold on
                    filledEBtemp = patch([tempX fliplr(tempX)],[tempEBlo fliplr(tempEBhi)],'k');
                    alpha(filledEBtemp,0.2)
                    filledEBtemp.EdgeAlpha = 0;
                    set(filledEBtemp,'edgecolor',string(choosecolor(g)),'facecolor',string(choosecolor(g)))
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
            
            legend(leg,legendID)
            ylabel(sprintf('%s',currenttitle.Yaxis));
            xlabel('Time (s)')
            title(sprintf('%s %s %s',currenttitle.Calc, currenttitle.ST, currenttitle.Data))
            hold off
        end
    end
    
    sname = 'CarrieCustom';
    S = hgexport('readstyle',sname);
%     style.Format = 'png';
%     style.ApplyStyle = '1';
    hgexport(gcf,'file_name',S,'applystyle',true);

   

end













