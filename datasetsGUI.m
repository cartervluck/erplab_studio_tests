% ERPset selector panel
%
% Author: Carter Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2018

% ERPLAB Toolbox
% 

%
% Initial setup
%
function varargout = datasetsGUI(varargin)
global datasets; % Local data structure
global box;
global ALLERP;
if nargin == 0
    fig = figure(); % Parent figure
    box = uiextras.BoxPanel('Parent', fig, 'Title', 'ERPsets', 'Padding', 5); % Create boxpanel
elseif nargin == 1
    box = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'ERPsets', 'Padding', 5);
else
    box = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'ERPsets', 'Padding', 5, 'FontSize', varargin{2});
end

getDatasets() % Get datasets from ALLERP

datasets = sortdata(datasets);
datasets = sortdata(datasets);

global selectedData;
try
    cerp = evalin('base','CURRENTERP');
    i = ALLERP(1,cerp);
    [r,~] = size(datasets);
    for j = 1:r
        if strcmp(i.erpname,cell2mat(datasets(j,1)))&&strcmp(i.filename,cell2mat(datasets(j,4)))&&strcmp(i.filepath,cell2mat(datasets(j,5)))
            selectedData = j;
        end
    end
catch
    selectedData = 0;
end
global havedots; % Show dot heirarchy
havedots = 1>0; % Default yes

% datasets = {'name', 1, 0, 'Users/***/Documents/Matlab/Test_data/', 'S1.erp';'name2', 2, 1;'name3', 3, 2;'name4', 4, 1;'name5', 5, 4}; % Create datasets. {'Name', datasetNumber, parentNumber, 'filename', 'filepath'}
% Test erpname/filepath/filename against ALLERP to correlate
% No duplicate dataset numbers. If a dataset's parent number is not a valid
% dataset, the dataset will be cleared when dataset = sortdata(datasets) is
% called. erpsetname must contain at least one non-numeric character.
datasets = sortdata(datasets);
drawui()

varargout{1} = box;

% Grab local structure from global ERP
function getDatasets()
global ALLERP;
global datasets;
datasets = {};
for i = ALLERP
    datasets{end+1,1} = i.erpname;
    [r,~] = size(datasets);
    datasets{end,2} = r;
    datasets{end,3} = 0;
    datasets{end,4} = i.filename;
    datasets{end,5} = i.filepath;
end

% Draw the ui
function drawui()
global datasets;
global box;
global selectedData;
global havedots;
[r, ~] = size(datasets); % Get size of array of datasets. r is # of datasets
% Sort the datasets!!!
datasets = sortdata(datasets);
vBox = uiextras.VBox('Parent', box, 'Spacing', 5); % VBox for everything
%panelshbox = uiextras.HBox('Parent', vBox, 'Spacing', 5);
panelshbox = uix.ScrollingPanel('Parent', vBox);
panelsv2box = uiextras.VBox('Parent',panelshbox,'Spacing',5);
%sp = uipanel(panelshbox);
%set( panelshbox, 'Sizes', [-1 17] );
%s = uicontrol('Style','Slider','Parent',sp,...
%      'Units','normalized','Position',[1 0 0.05 1],...
%      'Value',1,'Callback',{@slider_callback1,panelsv2box},'Min',0,'Max',1);
panels = zeros([1 r]); % Empty array for panels
cbs = zeros([1 r]); % Empty array for checkboxes
dsnums = zeros([1 r]); % Empty array for dataset numbers
dots = zeros([1 r]); % Empty array for dots
dsnames = zeros([1 r]); % Empty array for dataset names
for x = 1:r
    panels(x) = uipanel(panelsv2box, 'ButtonDownFcn', @selectdata,'Position',[25*(x-1),5,100,25]);
    cbs(x) = uicontrol(panels(x), 'Style', 'checkbox', 'Position', [5 5 15 15]);
    dsnums(x) = uicontrol('Parent', panels(x), 'Style', 'text', 'String', num2str(cell2mat(datasets(x,2))), 'Position', [25, 5, 25, 15], 'Enable', 'Inactive', 'ButtonDownFcn', @selectdata);
    % Code for getting how many dots to have
    dotsneeded = 1;
    if havedots
        parentnumber = cell2mat(datasets(x,3));
        while parentnumber ~= 0
            for j = datasets'
                if cell2mat(j(2)) == parentnumber
                    parentnumber = cell2mat(j(3));
                    dotsneeded = dotsneeded + 1;
                end
            end
        end
        dots(x) = uicontrol(panels(x), 'Style', 'text',...
            'String', repmat(' . ',1,dotsneeded),...
            'Position', [50, 5, dotsneeded*11, 15],...
            'FontWeight', 'bold', 'Enable', 'Inactive', 'ButtonDownFcn', @selectdata);
    else
        dotsneeded = 0;
    end
    startX = 55+dotsneeded*11;
    dsnames(x) = uicontrol('Parent', panels(x), 'Style', 'text',...
        'String',cell2mat(datasets(x,1)),...
        'Position', [startX 5 1000 15],...
        'HorizontalAlignment', 'left', 'Enable', 'Inactive', 'ButtonDownFcn', @selectdata); % Have it call a function, pass in x
    if cell2mat(datasets(x,2)) == selectedData
      	set(panels(x),'BackgroundColor',[0.1 0.1 0.7]);
        set(dsnums(x),'BackgroundColor',[0.1 0.1 0.7],'ForegroundColor','w');
        set(dots(x),'BackgroundColor',[0.1 0.1 0.7],'ForegroundColor','w');
        set(dsnames(x),'BackgroundColor',[0.1 0.1 0.7],'ForegroundColor','w');
        set(cbs(x),'BackgroundColor',[0.1 0.1 0.7]);
    else
      	set(panels(x),'BackgroundColor',[0.9 0.9 0.9]);
        set(dsnums(x),'BackgroundColor',[0.9 0.9 0.9],'ForegroundColor','k');
        set(dots(x),'BackgroundColor',[0.9 0.9 0.9],'ForegroundColor','k');
        set(dsnames(x),'BackgroundColor',[0.9 0.9 0.9],'ForegroundColor','k');
        set(cbs(x),'BackgroundColor',[0.9 0.9 0.9]);
    end
end

set( panelsv2box, 'Sizes', ones([1 r])*25 );
set( vBox, 'Sizes', 150 );
set( panelsv2box, 'Position', [panelsv2box.Position(1) (150-(30*r)) panelsv2box.Position(3) r*30] );
buttons1 = uiextras.HBox('Parent', vBox, 'Spacing', 5);
%moveButton = uicontrol('Parent', buttons1, 'Style', 'pushbutton', 'String', 'Move Checked', 'Callback', @movedata);
checkall = uicontrol('Parent', buttons1, 'Style', 'pushbutton', 'String', 'Check All', 'Callback', @checkAll);
checknone = uicontrol('Parent', buttons1, 'Style', 'pushbutton', 'String', 'Check None', 'Callback', @checkNone);
dupeselected = uicontrol('Parent', buttons1, 'Style', 'pushbutton', 'String', 'Duplicate', 'Callback', @duplicateSelected);
buttons2 = uiextras.HBox('Parent', vBox, 'Spacing', 5);
renameselected = uicontrol('Parent', buttons2, 'Style', 'pushbutton', 'String', 'Rename', 'Callback', @renamedata);
clearselected = uicontrol('Parent', buttons2, 'Style', 'pushbutton', 'String', 'Clear', 'Callback', @cleardata);
% appendselected = uicontrol('Parent', buttons2, 'Style', 'pushbutton', 'String', 'Append', 'Callback', @appenddata);
% avgselected = uicontrol('Parent', buttons2, 'Style', 'pushbutton', 'String', 'Average', 'Callback', @avgdata);
% panelsbox = uiextras.HBox('Parent', vBox, 'Spacing', 5);
% exportpanel = uipanel(panelsbox);
% exportvbox = uiextras.VBox('Parent',exportpanel,'Spacing',5);
% exportbutton = uicontrol('Parent', exportvbox, 'Style', 'pushbutton', 'String', 'Export', 'Callback', @temp);
% exporttype = uicontrol('Parent', exportvbox, 'Style', 'popup', 'String', {'ERPSS Text','Universal Text'});
% importpanel = uipanel(panelsbox);
% importvbox = uiextras.VBox('Parent',importpanel,'Spacing',5);
% importbutton = uicontrol('Parent', importvbox, 'Style', 'pushbutton', 'String', 'Import', 'Callback', @temp);
% importtype = uicontrol('Parent', importvbox, 'Style', 'popup', 'String', {'ERPSS Text','Universal Text','Neuroscan (*.arg)'});
importexport = uicontrol('Parent',buttons2, 'Style', 'pushbutton', 'String', 'Import/Export', 'Callback', @temp);
buttons4 = uiextras.HBox('Parent', vBox, 'Spacing', 5);
loadbutton = uicontrol('Parent', buttons4, 'Style', 'pushbutton', 'String', 'Load', 'Callback', @load);
savebutton = uicontrol('Parent', buttons4, 'Style', 'pushbutton', 'String', 'Save', 'Callback', @savechecked);
saveasbutton = uicontrol('Parent', buttons4, 'Style', 'pushbutton', 'String', 'Save As...', 'Callback', @savecheckedas);
if havedots
    dotstoggle = uicontrol('Parent', buttons4, 'Style', 'pushbutton', 'String', 'Dots', 'Callback', @toggledots);
else
    dotstoggle = uicontrol('Parent', buttons4, 'Style', 'pushbutton', 'String', 'No Dots', 'Callback', @toggledots);
end

%
% Callbacks
%
function temp(source,event)
beep

% Load ERP
function load(source,event)
global ERP;
global ALLERP;
global ERPCOM;
global ALLERPCOM;
global datasets;
[~,bc] = size(ALLERP);
[ERP, ALLERP, ERPCOM] = pop_loaderp('');
[ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM);
if (~isequal([1,bc], size(ALLERP)))
    getDatasets()
    datasets = sortdata(datasets);
    drawui();
end

% On dataset 'checked' set value in global structure (for batch mode)
function check_box(source,event)
global datasets;
global ALLERP;
num = 0;
for i = source.Parent.Children
    if strcmp(i.Style,'text')
        if all(ismember(i.String, '0123456789'))
            num = int.parse(i.String);
        end
    end
end

ds = [];
for i = datasets'
    if i(2) == num
        ds = i;
    end
end

for i = ALLERP
    if strcmp(ds(1),i.erpname)&&strcmp(ds(4),i.filepath)&&strcmp(ds(5),i.filename)
        % >:(
        % Change ALLERP structure to have checked property. So that we can
        % use batch mode for things!
    end
end

% Save as
function savecheckedas(source,event)
global datasets;
global ALLERP;
global ERP;
global ERPCOM;
global ALLERPCOM;
ndsns = []; % Dataset numbers
for i = source.Parent.Parent.Children(end).Children(end).Children'
    clear cond
    cond = false;
    num = 0;
    for j = i.Children'
        if strcmp(j.Style,'checkbox')
            if j.Value == 1
                cond = true;
            end
        elseif strcmp(j.Style,'text')
            if all(ismember(j.String, '0123456789'))
            	num = j;
            end
        end
    end
    if cond
        ndsns(1,end+1) = str2double(num.String);
    end
end

clear i
data = {};
for i = datasets'
    if ismember(cell2mat(i(2)),ndsns)
        data(end+1,:) = i';
    end
end

clear i
for i = data'
    [in,erp] = ds2erp(i);
    assignin('base','CURRENTERP',in);
    [ALLERP(1,in), issave ERPCOM] = pop_savemyerp(erp,'gui','saveas');
    [ALLERP(1,in), ALLERPCOM] = erphistory(ALLERP(1,in), ALLERPCOM, ERPCOM);
end

clear i
[ffnr,~] = size(datasets);
it = 1;
for i = 1:ffnr
    if ismember(cell2mat(datasets(i,2)),ndsns)
        clear in
        clear erp
        [in, ~] = ds2erp(data(it,:));
        datasets(i,4) = {ALLERP(1,in).filename};
        it = it + 1;
    end
end

datasets = sortdata(datasets);
drawui();

% Save
function savechecked(source,event)
global datasets;
global ALLERP;
global ERP;
global ERPCOM;
global ALLERPCOM;
global CURRENTERP;
ndsns = []; % Dataset numbers
for i = source.Parent.Parent.Children(end).Children(end).Children'
    clear cond
    cond = false;
    num = 0;
    for j = i.Children'
        if strcmp(j.Style,'checkbox')
            if j.Value == 1
                cond = true;
            end
        elseif strcmp(j.Style,'text')
            if all(ismember(j.String, '0123456789'))
            	num = j;
            end
        end
    end
    if cond
        ndsns(1,end+1) = str2double(num.String);
    end
end

clear i
data = {};
for i = datasets'
    if ismember(cell2mat(i(2)),ndsns)
        data(end+1,:) = i';
    end
end

clear i
for i = data'
    [in,erp] = ds2erp(i);
    assignin('base','CURRENTERP',in);
    [ALLERP(1,in), issave ERPCOM] = pop_savemyerp(erp,'gui','save');
    [ALLERP(1,in), ALLERPCOM] = erphistory(ALLERP(1,in), ALLERPCOM, ERPCOM);
end

datasets = sortdata(datasets);
drawui();

% Scrollbar
function slider_callback1(src,eventdata,arg1)
global datasets;
val = get(src,'Value');
[r,~] = size(datasets);
% At -(val-1) = 0, y = windowheight-(rowheight*rows)
% At -(val-1) = 1, y = 0
% -150(x-1)+30r(x-1) = y
x = -(val-1);
if r >=5
    set(arg1,'Position',[arg1.Position(1) (-150*(x-1))+(30*r*(x-1)) arg1.Position(3) arg1.Position(4)])
end

% Enable/Disable dot structure
function toggledots(source,event)
global datasets;
global havedots;
havedots = ~havedots;
datasets = sortdata(datasets);
drawui()

% Load grand averager
function avgdata(source,event)
global datasets;

ndsns = []; % Dataset numbers
for i = source.Parent.Parent.Children(end).Children(end).Children'
    clear cond
    cond = false;
    num = 0;
    for j = i.Children'
        if strcmp(j.Style,'checkbox')
            if j.Value == 1
                cond = true;
            end
        elseif strcmp(j.Style,'text')
            if all(ismember(j.String, '0123456789'))
            	num = j;
            end
        end
    end
    if cond
        ndsns(1,end+1) = str2double(num.String);
    end
end

clear i
data = {};
for i = datasets'
    if ismember(cell2mat(i(2)),ndsns)
        data(end+1,:) = i';
    end
end

% Data is selected datasets
disp(data)

% Append ERPsets
function appenddata(source,event)
global datasets;
global ALLERP;
ndsns = []; % Dataset numbers
for i = source.Parent.Parent.Children(end).Children(end).Children'
    clear cond
    cond = false;
    num = 0;
    for j = i.Children'
        if strcmp(j.Style,'checkbox')
            if j.Value == 1
                cond = true;
            end
        elseif strcmp(j.Style,'text')
            if all(ismember(j.String, '0123456789'))
            	num = j;
            end
        end
    end
    if cond
        ndsns(1,end+1) = str2double(num.String);
    end
end

clear i
data = {};
for i = datasets'
    if ismember(cell2mat(i(2)),ndsns)
        data(end+1,:) = i';
    end
end

clear i
clear erps
einds = [];
for i = data'
    [einds(end+1), ~] = ds2erp(i);
end

pop_appenderp(ALLERP,'Erpsets',einds);

% Data is selected datasets
disp(data);

% On ERPset selected set ERP, CURRENTERP
function selectdata(source,event)
global datasets;
global selectedData;
% Check if changes have been made to current ERPset before switching,
% prompt user to save. Hash history file, compare

i = 0;
if strcmp(source.Type,'uipanel')
    i = source;
else
    i = source.Parent;
end

for j = i.Children'
    if strcmp(j.Style,'text')
        if all(ismember(j.String, '0123456789'))
            selectedData = str2double(j.String);
            clear k
            for k = datasets'
                if cell2mat(k(2)) == str2double(j.String)
                    [cind, e] = ds2erp(k);
                    assignin('base','CURRENTERP',cind)
                    assignin('base','ERP',e)
                end
            end
        end
    end
end
datasets = sortdata(datasets);
drawui()


function cleardata(source,event)
global datasets;
global ALLERP;
ndsns = []; % Dataset numbers
for i = source.Parent.Parent.Children(end).Children(end).Children'
    clear cond
    cond = false;
    num = 0;
    for j = i.Children'
        if strcmp(j.Style,'checkbox')
            if j.Value == 1
                cond = true;
            end
        elseif strcmp(j.Style,'text')
            if all(ismember(j.String, '0123456789'))
            	num = j;
            end
        end
    end
    if cond
        ndsns(1,end+1) = str2double(num.String);
    end
end

clear i
clear cond
i = 1;
[nr,~] = size(datasets);
cond = i <= nr;
rinds = [];
inds = [];
sub = [];
while cond
    if ismember(cell2mat(datasets(i,2)),ndsns)
        clear j
        [nnr,~] = size(datasets);
        for j = 1:nnr
            if cell2mat(datasets(j,3)) == cell2mat(datasets(i,2))
                datasets(j,3) = datasets(i,3);
            end
            if cell2mat(datasets(j,2)) > cell2mat(datasets(i,2))
                sub(end+1,1) = cell2mat(datasets(j,2));
            end
        end
        clear k
        [~,cerp] = size(ALLERP);
        erpinds = [];
        for k = 1:cerp
            if strcmp(ALLERP(1,k).filename,cell2mat(datasets(i,4)))&&strcmp(ALLERP(1,k).filepath,cell2mat(datasets(i,5)))
                erpinds(end+1) = k;
            end
        end
        erpinds = sort(erpinds, 'descend');
        for k = erpinds
            ALLERP(:,k) = [];
        end
        datasets(i,:) = [];
    else
        i = i + 1;
    end
    [nr,~] = size(datasets);
    if i > nr
        cond = false;
    end
end

datasets = sortrows(datasets,2);
sub = sort(sub);
clear i
for i = sub'
    clear j
    clear nr
    [nr,~] = size(datasets);
    for j = 1:nr
        if cell2mat(datasets(j,2)) == i
            datasets(j,2) = {cell2mat(datasets(j,2))-1};
        end
        if cell2mat(datasets(j,3)) == i
            datasets(j,3) = {cell2mat(datasets(j,3))-1};
        end
    end
end

datasets = sortdata(datasets);
drawui();

%COMPLETE
function checkAll(source,event)
for i = source.Parent.Parent.Children(end).Children(end).Children'
    for j = i.Children'
        if strcmp(j.Style,'checkbox')
            j.Value = 1;
        end
    end
end

%COMPLETE
function checkNone(source,event)
for i = source.Parent.Parent.Children(end).Children(end).Children'
    for j = i.Children'
        if strcmp(j.Style,'checkbox')
            j.Value = 0;
        end
    end
end

% COMPLETE
function duplicateSelected(source,event)
global datasets;
global ALLERP;
ndsns = []; % Dataset numbers
for i = source.Parent.Parent.Children(end).Children(end).Children'
    clear cond
    cond = false;
    num = 0;
    for j = i.Children'
        if strcmp(j.Style,'checkbox')
            if j.Value == 1
                cond = true;
            end
        elseif strcmp(j.Style,'text')
            if all(ismember(j.String, '0123456789'))
            	num = j;
            end
        end
    end
    if cond
        ndsns(1,end+1) = str2double(num.String);
    end
end

clear i
for i = datasets'
    j = cell2mat(i(2));
    if ismember(j,ndsns)
        datasets(end+1,:) = i';
        [r,~] = size(datasets);
        datasets(end,3) = datasets(end,2);
        datasets(end,2) = {r};
        datasets(end,1) = strcat(datasets(end,1),' (Copy)');
        file = strcat(strcat(cell2mat(datasets(end,5)),'/'),cell2mat(datasets(end,4)));
        dest1 = strcat(cell2mat(datasets(end,5)),'/tempERPduplication/');
        dest2 = strcat(cell2mat(datasets(end,5)),'/');
        mkdir(dest1);
        copyfile(file,dest1);
        
        tempfilename = cell2mat(datasets(end,4));
        cond = true;
        while cond
            tempfilename = strcat(tempfilename(1:end-4),'_copy.erp');
            cond = exist(strcat(dest2,tempfilename),'file');
        end
        
        movefile(strcat(dest1,cell2mat(datasets(end,4))),strcat(dest2,tempfilename));
        rmdir(dest1);
        disp(strcat('Created file "',strcat(dest2,tempfilename)));
        
        clear k
        for k = ALLERP
            if strcmp(k.filepath,cell2mat(datasets(end,5))) && strcmp(k.filename,cell2mat(datasets(end,4)))
                ALLERP(1,end+1) = k;
                ALLERP(1,end).erpname = cell2mat(datasets(end,1));
                ALLERP(1,end).filename = strcat(ALLERP(1,end).filename(1:end-4),'_copy.erp');
                tempn = cell2mat(datasets(end,4));
                datasets(end,4) = {strcat(tempn(1:end-4),'_copy.erp')};
            end
        end
    end
end
datasets = sortdata(datasets);
drawui()

function renamedata(source,event)
global datasets;
global ALLERP;
ndsns = but2dsi(source); % Dataset numbers
% for i = source.Parent.Parent.Children(end).Children(end).Children'
%     clear cond
%     cond = false;
%     num = 0;
%     for j = i.Children'
%         if strcmp(j.Style,'checkbox')
%             if j.Value == 1
%                 cond = true;
%             end
%         elseif strcmp(j.Style,'text')
%             if all(ismember(j.String, '0123456789'))
%             	num = j;
%             end
%         end
%     end
%     if cond
%         [~,ndsnsc] = size(ndsns);
%         ndsns(1,ndsnsc+1) = str2double(num.String);
%     end
% end

clear i
[r,~] = size(datasets);
for i = 1:r
    if ismember(cell2mat(datasets(i,2)),ndsns)
        title = 'Rename Dataset';
        prompt = strcat(strcat('Please enter a new name for dataset "',cell2mat(datasets(i,1))),'":');
        new = inputdlg(prompt,title,[1 100],datasets(i,1));
        try
            datasets(i,1) = new;
            clear k
            [~,cerp] = size(ALLERP);
            for k = 1:cerp
                if strcmp(ALLERP(1,k).filepath,cell2mat(datasets(i,5))) && strcmp(ALLERP(1,k).filename,cell2mat(datasets(i,4)))
                    ALLERP(1,k).erpname = cell2mat(new);
                end
            end
        catch
            disp('cancelled');
        end
    end
end
datasets = sortdata(datasets);
drawui()

function movedata(source,event)
global datasets;
ndsns = []; % Dataset numbers
for i = source.Parent.Parent.Children(end).Children(end).Children'
    clear cond
    cond = false;
    num = 0;
    for j = i.Children'
        if strcmp(j.Style,'checkbox')
            if j.Value == 1
                cond = true;
            end
        elseif strcmp(j.Style,'text')
            if all(ismember(j.String, '0123456789'))
            	num = j;
            end
        end
    end
    if cond
        [~,ndsnsc] = size(ndsns);
        ndsns(1,ndsnsc+1) = str2double(num.String);
    end
end
disp(ndsns)

names = {'Parent'};
clear i
for i = datasets'
    if ~ismember(cell2mat(i(2)),ndsns)
        names(1,end+1) = i(1);
    end
end

[indx,tf] = listdlg('PromptString','Move to...','SelectionMode','single','ListString',names);

if tf
    clear num
    num = 0;
    clear i
    for i = datasets'
        if strcmp(cell2mat(i(1)),cell2mat(names(indx)))
            num = cell2mat(i(2));
        end
    end
    
    clear i
    [r,~] = size(datasets);
    for i = 1:r
        if ismember(cell2mat(datasets(i,2)),ndsns)
            datasets(i,3) = {num};
        end
    end
end
datasets = sortdata(datasets);
drawui()

%
% Misc Functions
%

% called datasets = sortdata(datasets), sorts datasets in order based on
% parents
function varargout = sortdata(data)
cinds = [];
ndata = {}; % Sorted data
it = 1; % Iterator for row
for i = data' % Iterate thru all datasets
    if cell2mat(i(3)) == 0 % Find base datasets (child of 0 means it's not reliant on another dataset)
        [~, ic] = size(cinds);
        cinds(1, ic+1) = cell2mat(i(2)); % Append dataset number to list of current indexes
        ndata(it,:) = i'; % Put it in
        it = it + 1;
    end
end

cond = true;
while cond
    ninds = []; % Reset new indexes
    for i = data' % Iterate thru all data
        for j = cinds % Iterate thru all parents
            if cell2mat(i(3)) == j % Check to see if every datapoint is a child of the current layer
                [~, nic] = size(ninds);
                ninds(1, nic+1) = cell2mat(i(2)); % Append dataset number to the next round of parents
                [ndr, ~] = size(ndata);
                for v = 1:ndr
                    if cell2mat(ndata(v, 2)) == j
                        ndata(v+2:end+1,:) = ndata(v+1:end,:);
                        ndata(v+1,:) = i';
                    end
                end
            end
        end
    end
    [~, nic] = size(ninds);
    if nic == 0 % If we've gone thru all of them, there should be no new indexes
        cond = false;
    end
    clear cinds
    cinds = ninds; % Start again with ninds
end
varargout{1} = ndata;

% Gets indeces of checked datasets from the context of a button
function varargout = but2dsi(button)
ndsns = []; % Dataset numbers
for i = button.Parent.Parent.Children(end).Children(end).Children'
    clear cond
    cond = false;
    num = 0;
    for j = i.Children'
        if strcmp(j.Style,'checkbox')
            if j.Value == 1
                cond = true;
            end
        elseif strcmp(j.Style,'text')
            if all(ismember(j.String, '0123456789'))
            	num = str2double(j.String);
            end
        end
    end
    if cond
        [~,ndsnsc] = size(ndsns);
        ndsns(1,ndsnsc+1) = num;
    end
end
varargout{1} = ndsns;

% Gets [ind, erp] for input ds where ds is a dataset structure, ind is the
% index of the corresponding ERP, and ERP is the corresponding ERP
% structure.
function varargout = ds2erp(ds)
global ALLERP
[~,cvtc] = size(ALLERP);
for z = 1:cvtc
    fp1 = ALLERP(1,z).filepath;
    fp2 = cell2mat(ds(5));
    fp1(regexp(fp1,'[/]')) = [];
    fp2(regexp(fp2,'[/]')) = [];
    if strcmp(ALLERP(1,z).erpname,cell2mat(ds(1)))&&strcmp(fp1,fp2)
        varargout{1} = z;
        varargout{2} = ALLERP(1,z);
    end
end
