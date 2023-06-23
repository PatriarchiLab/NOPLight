function [choosecolor_SAVE] = photomplotColor(setupParam,numgroups)

%% 

if nargin<2
    numgroups = 0;
end




comparisonType = setupParam.comparisonType;

if comparisonType == 1
    choosecolor = {'k' '#61e15e' '#51c54f' '#41a940' '#328d32' '#227023' '#125414' '#023805'}; %green gradient
elseif comparisonType == 2
    choosecolor = {'k' '#43b6ff' '#399aea' '#2e7dd6' '#2461c1' '#1a44ac' '#0f2898' '#050b83'}; %blue gradient
elseif comparisonType == 3
    choosecolor = {'k' '#fd5959' '#e44b4b' '#ca3d3d' '#b12f2f' '#972121' '#7e1313' '#640505'}; %red gradient
elseif comparisonType == 4
    choosecolor = {'k' '#848bb2' '#757ca0' '#656d8e' '#565e7d' '#474e6b' '#373f59' '#283047' }; %grayish blue (ctrl) gradient
elseif comparisonType == 5
    choosecolor = {'#02536d' '#6fe5f7' '#6d0202'  '#f76f6f' '#1d6228' '#9df983' 'k' '#707173'}; %dark/light blue, dark/light red, dark/light green, black/gray
elseif comparisonType == 6
    choosecolor = {'#2222e0' '#0ac9cb'};  %470 blue, 490 blue
    %choosecolor = {'#7e1313' '#125414'};
elseif comparisonType == 7
    choosecolor = {'#227023' '#1a44ac' '#474e6b'};
end

if ~ismember([6,7],comparisonType)
    
    if numgroups <5
        choosecolor(6:7) = []; choosecolor(3:4) = []; 
    elseif numgroups == 5
        choosecolor(7) = []; choosecolor(3:4) = [];
    elseif numgroups == 6
        choosecolor(5) = []; choosecolor(3) = []; 
    elseif numgroups == 7
        choosecolor(3) = [];
    end
end

choosecolor_SAVE = choosecolor;
    