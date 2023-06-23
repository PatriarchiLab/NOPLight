function [currenttitle_SAVE] = photomplotTitle(ST,plotvarname)


if contains(ST,'Raw')
    currenttitle.ST = 'Raw';
elseif contains(ST,'Recentered')
    currenttitle.ST = 'Re-Centered';
elseif contains(ST,'DecayAdj')
    if contains(ST,'Exp')
        currenttitle.ST = 'Reference Adjusted (Exp Fit)';
    elseif contains(ST,'Poly')
        currenttitle.ST = 'Reference Adjusted (Poly Fit)';
    else
        currenttitle.ST = 'Decay Adjusted';
    end
end

if contains(plotvarname,'dFFentire')
    currenttitle.Calc = '∆F/F (fixed session BL period)';
    currenttitle.Yaxis = '∆F/F';
elseif contains(plotvarname,'Zentire')
    currenttitle.Calc = 'Z-score (fixed session BL period)';
    currenttitle.Yaxis = 'Z-score';
elseif contains(plotvarname,'dFFbytrial')
    currenttitle.Calc = '∆F/F (event relative BL period)';
    currenttitle.Yaxis = '∆F/F';
elseif contains(plotvarname,'Zbytrial')
    currenttitle.Calc = 'Z-score (event relative BL period)'; 
    currenttitle.Yaxis = 'Z-score';
else 
    currenttitle.Calc = '';
    currenttitle.Yaxis = 'Raw F';
end

if contains(plotvarname,'ref')
    if contains(plotvarname,'sub')
        currenttitle.Data = 'Sig - Ref';
    else
        currenttitle.Data = 'Ref';
    end
else
    currenttitle.Data = 'Sig';
end


currenttitle_SAVE = currenttitle;

