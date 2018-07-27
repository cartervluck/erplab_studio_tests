% New GUI Layout - Simple ERP viewer 0.014
%
% Author: Andrew Stewart
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2016

% ERPLAB Toolbox
%

%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

% Reqs:
% - data loaded in valid ERPset
% - GUI Layout Toolbox


%
% Demo to explore an ERP Viewer using the new GUI Layout Toolbox
% Now with more in nested functions

function [] = new_erp_viewer14_1erp()


% Sanity checks
try
    test = uix.HBoxFlex();
catch
    disp('The GUI Layout Toolbox might not be installed. Quitting')
    return
end

global ALLERP;

try
    current_ERP = evalin('base','CURRENTERP');
catch
    current_ERP = 1;
end

ERP = ALLERP(current_ERP);

try
    assert(numel(ERP) >= 1)
catch
    disp('ERP structure empty or not supplied?')
    return
end


% Initialize data and interface
data = handleData(ERP);
gui = createInterface(ERP);
plotops;

% Update the GUI with current data
updateInterface();
redrawERP();
redrawERP(); % run second time to sort sizes?


%
% Subfunctions
%
    function data = handleData(ERP)
        
        %current_ERP = 1;
        %ERP = ALLERP(current_ERP);
        
        
        
        elec_list = cell(numel(ERP.chanlocs),1);
        for i=1:numel(ERP.chanlocs)
            elec_list{i} = ERP.chanlocs(i).labels;
        end
        first_elec = 1;
        elec_n = 5;
        
        elecs_shown = first_elec:first_elec+elec_n;
        
        timemin = ERP.times(1);
        timemax = ERP.times(end);
        timefirst = timemin;
        
        bins = zeros(1,ERP.nbin);
        for i = 1:ERP.nbin
            bins(1,i) = i;
        end
        
        [~,bin_n] = size(bins);
        
        matlab_ver = version('-release');
        matlab_ver = str2double(matlab_ver(1:4));
        
        data = struct(...
            'elec_list'     , {elec_list(:)}, ...
            'first_elec'    , first_elec, ...
            'elec_n'        , elec_n, ...
            'elecs_shown'   , elecs_shown, ...
            'timemin'       , timemin, ...
            'timemax'       , timemax, ...
            'timefirst'     , timefirst, ...
            'bins'          , bins, ...
            'bin_n'         , bin_n, ...
            'matlab_ver'    , matlab_ver, ...
            'bins_chans'    , 0, ...
            'min'           , floor(ERP.times(1)/5)*5, ...
            'max'           , ceil(ERP.times(end)/5)*5);
        
        
    end  % handleData


    function gui = createInterface(ERP)
        gui = struct();
        % First, let's start the window
        gui.Window = figure( 'Name', 'ERPLAB Studio v0.014', ...
            'NumberTitle', 'off', ...
            'MenuBar', 'none', ...
            'Toolbar', 'none', ...
            'HandleVisibility', 'off');
        
        % set the window size
        %old_pos = get(gui.Window, 'Position');
        new_pos = [1 1 1200 1200];
        set(gui.Window, 'Position', new_pos);
        
        
        % + File menu
        gui.FileMenu = uimenu( gui.Window, 'Label', 'File' );
        uimenu( gui.FileMenu, 'Label', 'Exit', 'Callback', @onExit );
        
        % + View menu
        gui.ViewMenu = uimenu( gui.Window, 'Label', 'ERPLAB Commands' );
        for ii=1:numel( data.elec_list )
            uimenu( gui.ViewMenu, 'Label', data.elec_list{ii}, 'Callback', @onMenuSelection );
            
        end
        
        % + File menu
        gui.FileMenu = uimenu( gui.Window, 'Label', 'EEG datasets' );
        gui.FileMenu = uimenu( gui.Window, 'Label', 'ERP sets' );
        
        
        %         % + Help menu
        %         helpMenu = uimenu( gui.Window, 'Label', 'Help' );
        %         uimenu( helpMenu, 'Label', 'Documentation', 'Callback', @onHelp );
        
        %% Create tabs
        context_tabs = uiextras.TabPanel('Parent', gui.Window, 'Padding', 5);
        
        tab1 = uix.HBoxFlex( 'Parent', context_tabs, 'Spacing', 10 );
        tab2 = uix.HBoxFlex( 'Parent', context_tabs, 'Spacing', 10 );
        gui.tabERP = uix.HBoxFlex( 'Parent', context_tabs, 'Spacing', 10 );
        tab4 = uix.HBoxFlex( 'Parent', context_tabs, 'Spacing', 10 );
        tab5 = uix.HBoxFlex( 'Parent', context_tabs, 'Spacing', 10 );
        
        context_tabs.TabNames = {'Continuous EEG','Epoched EEG','ERP', 'Multi-ERP','Stats analysis'};
        context_tabs.SelectedChild = 3;
        %context_tabs.HighlightColor = [0 0 1];
        context_tabs.FontWeight = 'bold';
        context_tabs.TabSize = 120;
        
        
        
        %% Arrange the main interface
        
        
        % + Create the panels
        
        gui.ViewBox = uix.VBox('Parent', gui.tabERP);
        gui.ViewPanel = uix.BoxPanel( ...
            'Parent', gui.ViewBox, ...
            'Title', [ERP.erpname ' Page 1/1'], ...
            'HelpFcn', @onDemoHelp );
        gui.ViewContainer = uicontainer( ...
            'Parent', gui.ViewPanel );
        %gui.ViewSlider = uix.VBox( ...
        %    'Parent', gui.ViewBox);
        
        gui.panelscroll = uix.ScrollingPanel(...
            'Parent', gui.tabERP);
        
        % + Adjust the main layout
        set( gui.tabERP, 'Widths', [-4, 300]  ); % Viewpanel and settings panel
        %set( gui.ViewBox, 'Heights', [-1 25] );  % Container and slider
        %set( gui.ViewSlider, 'Heights', [35 35] );
        
        
        
        
        
        % + Create the controls
        %         %controlLayout = uix.VBox( 'Parent', controlPanel, ...
        %             'Padding', 3, 'Spacing', 3 );
        %         %gui.ListBox = uicontrol( 'Style', 'list', ...
        %             'BackgroundColor', 'w', ...
        %             'Parent', controlLayout, ...
        %             'String', data.elec_list(:), ...
        %             'Value', 1, ...
        %             'Callback', @onListSelection);
        
        % + Create the time slider
%         gui.timesl = uicontrol('Style', 'slider', ...
%             'Parent', gui.ViewSlider, ...
%             'min', data.timemin, 'max', data.timemax, ...
%             'value', data.timefirst, ...
%             'Callback', @timeslmove);
%         gui.timesltext = uicontrol('Style', 'text', ...
%             'Parent', gui.ViewSlider, ...
%             'String', num2str(data.timefirst));
        
        %gui.HelpButton = uicontrol( 'Style', 'PushButton', ...
        %   'Parent', controlLayout, ...
        %  'String', 'Help for <demo>', ...
        % 'Callback', @onDemoHelp );
        %          gui.ElecNtext = uicontrol( 'Style', 'text', ...
        %              'Parent', controlLayout','String', 'Number of electrodes plotted');
        %         elecNhbox = uix.HButtonBox( 'Parent', controlLayout, 'Padding', 5);
        %         gui.ElecNminus = uicontrol( 'Style', 'PushButton', ...
        %             'Parent', elecNhbox, ...
        %             'String', '-', ...
        %             'Callback', @onElecNminus );
        %         gui.ElecNbox = uicontrol( 'Style', 'edit', ...
        %             'Parent', elecNhbox, ...
        %             'String', data.elec_n, ...
        %             'Callback', @onElecNbox );
        %         gui.ElecNminus = uicontrol( 'Style', 'PushButton', ...
        %             'Parent', elecNhbox, ...
        %             'String', '+', ...
        %             'Callback', @onElecNplus );
        %         set( controlLayout, 'Heights', [-1 28 28] ); % Make the list fill the space
        
        gui.panel_fonts = 12;
        
        % + Create the settings window panels
        gui.settingLayout = uiextras.VBox('Parent', gui.panelscroll);
        gui.panel{1} = uiextras.BoxPanel( ...
            'Parent', gui.settingLayout, ...
            'Title', 'Data selector', ...
            'FontSize',gui.panel_fonts, 'FontWeight', 'bold');
        gui.panelSizes(1) = 250;
        
        gui.panel{2} = datasetsGUI(gui.settingLayout,gui.panel_fonts);
        gui.panelSizes(2) = 250;
        
%         gui.panel{2} = uiextras.BoxPanel( ...
%             'Parent', gui.settingLayout, ...
%             'FontSize',gui.panel_fonts, 'Title', 'Page view');
%         gui.panelSizes(2) = 150;
        
        gui.panel{3} = uiextras.BoxPanel( ...
            'Parent', gui.settingLayout, ...
            'FontSize',gui.panel_fonts, 'Title', 'Plotting options');
        gui.panelSizes(3) = 300;
        
        gui.panel{4} = uiextras.BoxPanel(          ...
            'Parent'    , gui.settingLayout     , ...
            'FontSize'  , gui.panel_fonts   , ...
            'Title'     , 'History'         );
        gui.panelSizes(4) = 250;
        %% 'TitleHeight_', 50);
        
        gui.panel{5} = uiextras.BoxPanel( ...
            'Parent', gui.settingLayout, ...
            'FontSize',gui.panel_fonts, 'Title', 'Filtering');
        gui.panelSizes(5) = 250;
        
        
        gui.panel{6} = uiextras.BoxPanel( ...
            'Parent', gui.settingLayout, ...
            'FontSize',gui.panel_fonts, 'Title', 'Spectral Tools');
        gui.panelSizes(6) = 250;
        
        
        
        
        
        
        
        set( gui.settingLayout, 'Heights', gui.panelSizes);
        gui.panelscroll.Heights = sum(gui.panelSizes);
        
        
        
        %% Hook up the minimize callback and IsMinimized
        set( gui.panel{1}, 'MinimizeFcn', {@nMinimize, 1} );
        set( gui.panel{2}, 'MinimizeFcn', {@nMinimize, 2} );
        set( gui.panel{3}, 'MinimizeFcn', {@nMinimize, 3} );
        set( gui.panel{4}, 'MinimizeFcn', {@nMinimize, 4} );
        set( gui.panel{5}, 'MinimizeFcn', {@nMinimize, 5} );
        set( gui.panel{6}, 'MinimizeFcn', {@nMinimize, 6} );
        %set( gui.panel{7}, 'MinimizeFcn', {@nMinimize, 7} );
        
        %% Populate the settings windows
        % Try a 4x4 grid for data selection (set thru set sizes below)
        gui.DataSelBox = uiextras.VBox('Parent', gui.panel{1}, 'Spacing',1);
        gui.DataSelGrid = uiextras.Grid('Parent', gui.DataSelBox, 'Spacing',1);
        % Columns are filled first. First column:
        uiextras.Empty('Parent', gui.DataSelGrid); % 1A
        %uicontrol('Style','text','Parent', gui.DataSelGrid,'String','Select all'); % 2A
        uicontrol('Style','text','Parent', gui.DataSelGrid,'String','Current selection'); % 3A
        uicontrol('Style','text','Parent', gui.DataSelGrid,'String','Sort'); % 4A
        % Second column:
        uicontrol('Style','text','Parent', gui.DataSelGrid,'String','Channels'); % 1B
        %gui.ElecAll = uicontrol('Parent', gui.DataSelGrid,'Style', 'checkbox'); % 2B
        gui.ElecRange = uicontrol('Parent', gui.DataSelGrid,'Style','listbox','min',1,'max',data.elec_n+1,...
            'String', data.elec_list, 'Callback',@onElecRange, 'Value', data.elecs_shown); % 3B
        gui.ElecSort = uicontrol('Parent', gui.DataSelGrid,'Style','checkbox','Callback',@onElecSort); % 4B
        % Third column:
        uicontrol('Style','text','Parent', gui.DataSelGrid,'String','Bins'); % 1C
        %gui.BinAll = uicontrol('Parent', gui.DataSelGrid,'Style', 'checkbox'); % 2C
        brange = cell(ERP.nbin+1,1);
        brange(1) = {'ALL'};
        for i = 1:ERP.nbin
            brange(i+1) = {num2str(i)};
        end
        gui.BinRange =  uicontrol('Parent', gui.DataSelGrid,'Style','listbox','Min',1,'Max',ERP.nbin+1,...
            'String', brange,'callback',@onBinChanged); % 3C
        uiextras.Empty('Parent', gui.DataSelGrid);
        %gui.BinN = uicontrol('Parent', gui.DataSelGrid,'Style','edit','String', data.bins); % 4C
        % Fourth column:
        uicontrol('Style','text','Parent', gui.DataSelGrid,'String','ERPsets'); % 1D
        %gui.SetAll = uicontrol('Parent', gui.DataSelGrid,'Style', 'checkbox'); % 2D
        [~,numerps] = size(ALLERP);
        range = cell(numerps+1);
        range(1) = {'ALL'};
        for i = 1:numerps
            range(i+1) = {num2str(i)};
        end
        r_range = range(:,1);
        gui.SetRange = uicontrol('Parent', gui.DataSelGrid,'Style','listbox','String',r_range,'Value',current_ERP+1,'callback',@onErpChanged); % 3D
        uiextras.Empty('Parent', gui.DataSelGrid);
        %gui.SetN = uicontrol('Parent', gui.DataSelGrid,'Style','edit','String', '1'); % 4D
        % Set grid sizes
        set(gui.DataSelGrid, 'ColumnSizes',[60 -2 -2 -2],'RowSizes',[30 -3 20]);
                
        %%  Page view grid - 4x4
%         gui.pagegrid = uiextras.Grid('Parent', gui.panel{2}, 'Spacing',1);
%         % Columns are filled first. First column:
%         uiextras.Empty('Parent', gui.pagegrid); % 1A
%         uicontrol('Style','text','Parent', gui.pagegrid,'String','Overlay'); % 2A
%         uicontrol('Style','text','Parent', gui.pagegrid,'String','Rows'); % 3A
%         uicontrol('Style','text','Parent', gui.pagegrid,'String','Pages'); % 4A
%         % second column:
%         uicontrol('Style','text','Parent', gui.pagegrid,'String','Chans'); % 1B
%         pagegrid_o1 = uicontrol(gui.pagegridbg, 'Parent', gui.pagegrid, 'Style','radiobutton'); %2B
%         pagegrid_o2 = uicontrol(gui.pagegridbg, 'Parent', gui.pagegrid, 'Style','radiobutton','Value',1); %3B
%         pagegrid_o3 = uicontrol(gui.pagegridbg, 'Parent', gui.pagegrid, 'Style','radiobutton'); %4B
%         % third column:
%         uicontrol('Style','text','Parent', gui.pagegrid,'String','Bins'); % 1C
%         pagegrid_r1 = uicontrol(gui.pagegridbg, 'Parent', gui.pagegrid, 'Style','radiobutton','Value',1); %2C
%         pagegrid_r2 = uicontrol(gui.pagegridbg, 'Parent', gui.pagegrid, 'Style','radiobutton'); %3C
%         pagegrid_r3 = uicontrol(gui.pagegridbg,  'Parent', gui.pagegrid,'Style','radiobutton'); %4C
%         % fourth column:
%         uicontrol('Style','text','Parent', gui.pagegrid,'String','ERPsets'); % 1D
%         pagegrid_p1 = uicontrol(gui.pagegridbg,  'Parent', gui.pagegrid,'Style','radiobutton'); %2D
%         pagegrid_p2 = uicontrol(gui.pagegridbg,  'Parent', gui.pagegrid,'Style','radiobutton'); %3D
%         pagegrid_p3 = uicontrol(gui.pagegridbg,  'Parent', gui.pagegrid,'Style','radiobutton','Value',1); %4D
%         % Set grid sizes
%         set(gui.pagegrid, 'ColumnSizes',[60 -2 -2 -2],'RowSizes',[30 -3 -3 -3]);
        gui.pagesel = uicontrol('Parent', gui.DataSelBox, 'Style', 'popupmenu','String',{'CHANNELS with BINS overlay','BINS with CHANNELS overlay'},'callback',@pageviewchanged);
        
        set( gui.DataSelBox, 'Sizes', [-1 25] );
        
        %% Plotting options grid - 3x6?
        
        gui.plotop = uiextras.VBox('Parent',gui.panel{3}, 'Spacing',1);
        
        gui.time_sel = uiextras.HBox('Parent',gui.plotop,'Spacing',1);
        uicontrol('Style','text','Parent', gui.time_sel,'String','Time range:'); % 1A
        plotops.time_all = uicontrol('Style','checkbox','Parent', gui.time_sel,'String','All','callback',@time_all,'Value',1); % 2A
        uicontrol('Style','text','Parent', gui.time_sel,'String','Start');
        plotops.time_min = uicontrol('Style', 'edit','Parent',gui.time_sel,'String',num2str(data.min),'callback',@min_time_change,'Enable','off');
        uicontrol('Style','text','Parent', gui.time_sel,'String','End');
        plotops.time_max = uicontrol('Style', 'edit','Parent',gui.time_sel,'String',num2str(data.max),'callback',@max_time_change,'Enable','off');
        
        set(gui.time_sel, 'Sizes', [70 -1 -1 -1 -1 -1])
        
        gui.plotop_grid = uiextras.Grid('Parent',gui.plotop,'Spacing',1);
        % Columns are filled first. First column:
        uicontrol('Style','text','Parent', gui.plotop_grid,'String','Time ticks:'); % 1B
        uicontrol('Style','text','Parent', gui.plotop_grid,'String','Y scale:'); % 1C
        uicontrol('Style','text','Parent', gui.plotop_grid,'String','Number of rows:'); % 1D
        uicontrol('Style','text','Parent', gui.plotop_grid,'String','Number of columns:'); % 1E
        uicontrol('Style','text','Parent', gui.plotop_grid,'String','Polarity:'); % 1F
        % second column:
        plotops.timet_auto = uicontrol('Style','checkbox','Parent', gui.plotop_grid,'String','Auto','callback',@timet_auto,'Value',1); % 2B
        plotops.yscale_auto = uicontrol('Style','checkbox','Parent', gui.plotop_grid,'String','Auto','callback',@yscale_auto,'Value',1); % 2C
        plotops.rows = uicontrol('Style','edit','Parent', gui.plotop_grid,'String',data.elec_n,'callback',@onElecNbox); % 2D
        plotops.columns = uicontrol('Style','edit','Parent', gui.plotop_grid,'String','1','callback',@onElecNbox); % 2E
        plotops.up = uicontrol('Style','checkbox','Parent', gui.plotop_grid,'String','Positive Up?','callback',@up,'Value',1); % 2F
        gui.posup = 1;
        % Set grid sizes
        set(gui.plotop_grid, 'ColumnSizes',[100 -1],'RowSizes',[30 -1 -1 -1 -1]);
        
        set(gui.plotop,'Sizes',[20 -1]);
        
        
        %% Create History Panel
        
        %         f = figure( 'Name', 'uix.ScrollingPanel Help Example' );
        %         f.Position(3:4) = 400;
        %         gui.history.panel = uix.ScrollingPanel( ...
        %             'Parent'    , gui.panel{4}, ...
        %             'Position'  , [1, 139, 296, 125]);
        %
        % Create uitable within history panel
        [~, total_len] = size(ERP.history);
        gui.history.uitable = uitable(  ...
            'Parent'        , gui.panel{4},...
            'Data'          , strsplit(ERP.history(1,:), '\n')', ...
            'ColumnWidth'   , {total_len+2}, ...
            'ColumnName'    , {'Function call'}, ...
            'RowName'       , []);
        
        
        %% Create Filtering Panel - 4x5?
        
        gui.filtering = uiextras.VBox('Parent',gui.panel{5},'Spacing',1);
        filt_grid = uiextras.Grid('Parent',gui.filtering,'Spacing',1);
        
        % first column
        uiextras.Empty('Parent',filt_grid); % 1A
        uicontrol('Style','checkbox','Parent',filt_grid,'String','High Pass','callback',@highpass_toggle,'Value',1); % 1B
        uicontrol('Style','checkbox','Parent',filt_grid,'String','Low Pass','callback',@lowpass_toggle,'Value',1); % 1C
        
        
        % second column
        uicontrol('Style','text','Parent',filt_grid,'String','Half Amplitude'); % 2A
        gui.hp_halfamp = uicontrol('Style','edit','Parent',filt_grid,'callback',@hp_halfamp); % 2B
        gui.lp_halfamp = uicontrol('Style','edit','Parent',filt_grid,'callback',@lp_halfamp); % 2C
        
        % third column
        uicontrol('Style','text','Parent',filt_grid,'String','Half Power'); % 3A
        gui.hp_halfpow = uicontrol('Style','edit','Parent',filt_grid,'callback',@hp_halfpow); % 3B
        gui.lp_halfpow = uicontrol('Style','edit','Parent',filt_grid,'callback',@lp_halfpow); % 3C
        
        % fourth column
        uiextras.Empty('Parent',filt_grid); % 4A
        uicontrol('Style','text','Parent',filt_grid,'String','Hz'); % 4B
        uicontrol('Style','text','Parent',filt_grid,'String','Hz'); % 4C
        

        set(filt_grid, 'ColumnSizes',[100 -1 -1 -1],'RowSizes',[30 -1 -1]);
        
        rolloff_row = uiextras.HBox('Parent',gui.filtering,'Spacing',1);
        uicontrol('Style','text','Parent',rolloff_row,'String','Roll-Off'); % 1D
        uicontrol('Style','edit','Parent',rolloff_row,'callback',@rolloff); % 2D
        uicontrol('Style','text','Parent',rolloff_row,'String','dB/Octave'); % 3D
        
        batch_row = uiextras.HBox('Parent',gui.filtering,'Spacing',1);
        uicontrol('Style','checkbox','Parent',batch_row,'String','Batch Mode','callback',@batch_filter,'Value',0,'TooltipString','Apply operation to all checked ERPsets.');
        uicontrol('Style','pushbutton','Parent',batch_row,'callback',@batch_help,'String','?');
        uiextras.Empty('Parent',batch_row);
        
        uicontrol('Style','checkbox','Parent',gui.filtering,'String','Remove DC Offset','callback',@remove_dc,'Value',0);
        
        filt_buttons = uiextras.HBox('Parent',gui.filtering,'Spacing',1);
        uicontrol('Style','pushbutton','Parent',filt_buttons,'String','Apply','callback',@apply_filter);
        uicontrol('Style','pushbutton','Parent',filt_buttons,'String','Advanced...','callback',@advanced_filter);
        
        set(gui.filtering,'Sizes',[75 -1 -1 -1 -1]);
        
        %% + Create the view
        p = gui.ViewContainer;
        gui.ViewAxes = uiextras.HBox( 'Parent', p);
        
        
    end % createInterface


    function updateInterface()
        % Update various parts of the interface in response being changed.
        
        % Update the list to show first elec
        %set(gui.ListBox, 'Value', data.first_elec);
        
        % Update the electrode number text
        % set(gui.ElecNbox, 'String', data.elec_n);
        
        % Update the display
        %disp_elecs = ERP.chanlocs(data.first_elec).labels;
        %set( gui.HelpButton, 'String', ['Electrodes starting from ',disp_elecs] );
        
        % Time
        %set( gui.timesltext, 'String', data.timefirst);
        
        set(plotops.rows, 'String',data.elec_n);
        
        
        % Update the view panel title
        %set( gui.ViewPanel, 'Title', sprintf( 'Viewing: %s', disp_elecs ) );
        % Untick all menus
        menus = get( gui.ViewMenu, 'Children' );
        set( menus, 'Checked', 'off' );
        % Use the name to work out which menu item should be ticked
        whichMenu = strcmpi( data.elec_list, get( menus, 'Label' ) );
        set( menus(whichMenu), 'Checked', 'on' );
        
        
    end % updateInterface

    function redrawERP()
        % Draw a demo ERP into the axes provided
        
        if data.bins_chans == 0
            elec_n = data.elec_n;
            max_elec_n = ERP.nchan;
        else
            elec_n = data.bin_n;
            max_elec_n = ERP.nbin;
        end
        
        % We first clear the existing axes ready to build a new one
        if ishandle( gui.ViewAxes )
            delete( gui.ViewAxes );
        end
        
        
        % Get chan labels
        S.chan_label = cell(1,max_elec_n);
        S.chan_label_place = zeros(1,max_elec_n);
        
        if data.bins_chans == 0
        
            for i = 1:elec_n
            
                S.chan_label{i} = ERP.chanlocs(data.first_elec-1+i).labels;
            
            end
        
        else
            
            for i = 1:elec_n
                
                S.chan_label{i} = ERP.bindescr(data.bins(i));
                
            end
            
        end
        
        
        pb_height = 150;  %px
        
        
        % Plot data in the main viewer fig
        splot_n = elec_n;
        tsize   = 13;
        yticks  = [-10 0 10];
        
        
        %S.plot = plot(plot_erp_data');
        
        %p = gui.ViewContainer;
        gui.ViewAxes = uix.ScrollingPanel( 'Parent', gui.ViewContainer);
        
        clear pb pb_ax plotgrid
        gui.plotgrid = uix.Grid('Parent',gui.ViewAxes,'Padding',0,'Spacing',0);
        
        pageinfo_box = uiextras.HBox( 'Parent', gui.plotgrid);
        
        pageinfo_minus = uicontrol('Parent',pageinfo_box,'Style', 'pushbutton', 'String', '-','Callback','page_minus');
        pageinfo_plus = uicontrol('Parent',pageinfo_box,'Style', 'pushbutton', 'String', '+','Callback','page_plus');
        if data.bins_chans == 0
            pageinfo_str = ['Page 1 of 2. Currently showing CHANNELS with BINS overlay. Scroll pages for other ERPSETS.'];
        else
            pageinfo_str = ['Page 1 of 2. Currently showing BINS with CHANNELS overlay. Scroll pages for other ERPSETS.'];
        end
        pageinfo_text = uicontrol('Parent',pageinfo_box,'Style','popup','String',pageinfo_str,'FontSize',13,'FontWeight','bold');
        set(pageinfo_box, 'Sizes', [20 20 -1] );
        
        for i=1:splot_n
            
            ndata = 0;
            
            if data.bins_chans == 0
                ndata = data.bins;
            else
                ndata = data.elecs_shown;
            end
            
            tmin = (floor((data.min-ERP.times(1))/2)+1);
            tmax = (numel(ERP.times)+ceil((data.max-ERP.times(end))/2));
            
            if tmin < 1
                tmin = 1;
            end
            
            if tmax > numel(ERP.times)
                tmax = numel(ERP.times);
            end
            
            sf = ERP.times(2)-ERP.times(1);
            
            plot_erp_data = nan(tmax-tmin+1);
            
            if data.bins_chans == 0
                for i_bin = 1:numel(ndata)
                    plot_erp_data(:,i_bin) = ERP.bindata(data.elecs_shown(i),tmin:tmax,data.bins(i_bin))'*gui.posup; % + (i+1)*S.display_offset;
                end
            else
                for i_bin = 1:numel(ndata)
                    plot_erp_data(:,i_bin) = ERP.bindata(data.elecs_shown(i_bin),tmin:tmax,data.bins(i))'*gui.posup; % + (i+1)*S.display_offset;
                end
            end
            
            leg_str = '';
            
            if data.bins_chans == 0
                leg_str = sprintf('\n\n\n\n\n%s',data.elec_list{data.elecs_shown(i)});
            else
                leg_str = sprintf('\n\n\n\n\n%s',ERP.bindescr{data.bins(i)});
            end
            %fig = figure( 'Visible', 'off' );  % stop the plot appearing in a new fig
            
            pb(i) =  uiextras.HBox( 'Parent', gui.plotgrid);
            leg_text = uicontrol('Style','text','Parent', pb(i),'String',leg_str,'FontSize',13,'FontWeight','bold');
            
            pb_ax(i) = axes('Parent', pb(i),'Color','none');
            set(pb_ax(i),'XLim',[data.min data.max]);
            pb_here = plot(pb_ax(i),ERP.times(tmin:tmax),plot_erp_data);
            
            newlim = [];
            if gui.posup == 1
                newlim = [yticks(1)*2 yticks(end)*2];
            else
                newlim = [yticks(end)*-2 yticks(1)*-2];
            end
            
            % some options currently only work post Matlab R2016a
            if data.matlab_ver >= 2016
                set(pb_ax(i),'FontSize',tsize,'FontWeight','bold','XAxisLocation','origin',...
                    'XGrid','on','YGrid','on','YTick',yticks,'YTickLabel',yticks.*gui.posup, ...
                    'YLim',newlim, ...
                    'box','off', 'Color','none','XLim',[data.min data.max]);
            else
                set(pb_ax(i),'FontSize',tsize,'FontWeight','bold','XAxisLocation','bottom',...
                    'XGrid','on','YGrid','on','YTick',yticks,'YTickLabel',yticks.*gui.posup, ...
                    'YLim',newlim, ...
                    'box','off', 'Color','none','XLim',[data.min data.max]);
                
                hline(0,'k'); % backup xaxis
                
            end
            
            % fix scaling shrinkage
            pos_fix = pb_ax(1).Position;
            pos_fix(2) = 1; % Start at the bottom
            pos_fix(4) = pb_height - 1; % fill the height;
            
            
            
            
            if data.bins_chans == 0
                for i_lines = 1:numel(ndata)
                    set(pb_here(i_lines),'DisplayName',['Bin ' num2str(data.bins(i_lines))]);
                end
            else
                for i_lines = 1:numel(ndata)
                    set(pb_here(i_lines),'DisplayName',['Chan ' cell2mat(data.elec_list(data.elecs_shown(i_lines)))]);
                end
            end
            
            %legend_here = legend(pb_ax(i),'show');
            %set(legend_here,'Units','pixels','EdgeColor','none','Color','none');
            
            %set above as % leg_str = sprintf('\n\n%s',S.chan_label{i});
            if data.bins_chans == 0
                set( pb(i), 'Sizes', [30 -1] );
            else
                set( pb(i), 'Sizes', [70 -1] );
            end
        end
        
        
        col_size = -1;
        row_size = ones(1,splot_n) * pb_height;
        gui.plotgrid.Widths = col_size;
        gui.plotgrid.Heights(:) = [30 row_size] ;
        %set(gui.plotgrid, 'ColumnSizes',col_size,'RowSizes',[30 row_size]);
        gui.plotgrid.Heights(1) = 30; % set the first element (pageinfo) to 30px high
        %set(gui.plotgrid, 'ColumnSizes',col_size,'RowSizes',[30 row_size]);
        
        gui.ViewAxes.Heights = 30 + pb_height*splot_n;
        
        
        %gui.ViewAxes = fig;  % have the current (invisible) fig in gui.ViewAxes
        
        % Ylim
        S.ysep = 5;     % distance separating elecs, in uV
        S.ymin = -10 + -S.ysep * elec_n;  % graph uV below first elec
        S.ymax = 20;    % this is graph uV, so uV above top elec shown
        
        
        %gui.ViewAxes.YLim = [S.ymin S.ymax];
        
        % Labels and ticks
        S.fontsize = 13;
        %gui.ViewAxes.XLabel.String = 'Time (ms)';
        %gui.ViewAxes.XLabel.FontSize = S.fontsize;
        
        
        
        
        % Now copy the axes from the demo into our window and restore its
        % state.
        %set( gui.ViewAxes, 'Parent', gui.ViewContainer );  % set gui.ViewAxes in to main ERP viewer
        
        
        
        
        
        
    end % redrawDemo

    function panel_heights()
        n = numel(gui.panel);
        heights = zeros(size(gui.panel));
        for i = 1:n
            if gui.panel{i}.IsMinimized
                heights(i) = 25;
            else
                heights(i) = gui.panelSizes(i);
            end
        end
        set(gui.settingLayout,'Sizes',heights);
    end
%
% Callback subfunctions
%

    function onMenuSelection( src, ~ )
        % User selected an electrode from the menu
        data.first_elec = get( src, 'Position');
        updateInterface();
        redrawERP();
    end

    function onListSelection( src, ~ )
        % User selected a demo from the list - update "data" and refresh
        data.first_elec = get( src, 'Value' );
        updateInterface();
        redrawERP();
    end % onListSelection

    function onElecNminus( src, ~)
        % User pressed Elec N -
        if data.elec_n >= 1
            data.elec_n = data.elec_n - 1;
            updateInterface();
            redrawERP();
        else
            beep
        end
    end

    function onElecNplus( src, ~)
        % User pressed Elec N +
        if data.elec_n <= ERP.nchan
            data.elec_n = data.elec_n + 1;
            updateInterface();
            redrawERP();
        else
            beep
        end
    end

    function onElecNbox( src, ~)
        % User entered an electrode number
        elecN_input = get(plotops.rows,'String');
        input_error = 0;
        
        try   % input data checking
            elecN_input = str2num(elecN_input);
            assert(~isempty(elecN_input))
            assert(elecN_input>=0)
            assert(isequal(elecN_input,int16(elecN_input)))  % check int
            
            data.elec_n = elecN_input;
            
        catch
            set(gui.ElecNbox,'String',data.elec_n);
            beep
        end
        
        updateInterface();
        redrawERP();
        
    end

    function onElecRange ( src, ~)
        % When Electrode Range selector is clicked on
        
        % Only want to do anything if selection is different from shown
        % already, so check this first
        
        new_chans = src.Value;
        old_chans = data.elecs_shown;
        
        if isequal(old_chans, new_chans) == 0
            disp(src.Value)
            data.elecs_shown = new_chans;
            data.elec_n = numel(data.elecs_shown);
            data.first_elec = data.elecs_shown(1);
            
            updateInterface();
            redrawERP();
        else
            % if same as old values, do nothing
        end
        
    end

    function onElecSort (src, ~)
        %data.electable = chan_sort(data.elec_list)
        
        sort_now = src.Value;
        
        
        if sort_now == 1
            
            sortedT = chan_sort(data.elec_list);
            oldT = sortrows(sortedT,{'old_order'},{'ascend'});
            
            new_shown = nan(numel(data.elecs_shown),1);
            for i = 1:numel(data.elecs_shown)
                new_shown(i) = oldT{data.elecs_shown(i),3};
            end
            data.elecs_shown = new_shown;
            data.elec_list = sortedT{:,2};
            
            set(gui.ElecRange,'String',data.elec_list);
            set(gui.ElecRange,'Value',data.elecs_shown);
            
            
            
            data.sortedT = sortedT;
            disp(data.elecs_shown);
            
        elseif sort_now == 0
            
            % Reset to unsorted
            %data = handleData(ERP);
            %sortedT = chan_sort(data.elec_list);
            sortedT = data.sortedT;
            data.elecs_shown = sortedT{data.elecs_shown,1};
            sortedT = sortrows(sortedT,{'old_order'},{'ascend'});
            
            
            data.elec_list = sortedT{:,2};
            
            set(gui.ElecRange,'String',data.elec_list);
            set(gui.ElecRange,'Value',data.elecs_shown);
            
            disp(data.elecs_shown);
        end
        
        updateInterface();
        redrawERP();
    end

    function onErpChanged( src, ~ )
        global CURRENTERP;
        if src.Value ~= 1
            CURRENTERP = src.Value - 1;
            ERP = ALLERP(CURRENTERP);
            brange = cell(ERP.nbin+1,1);
            brange(1) = {'ALL'};
            for i = 1:ERP.nbin
                brange(i+1) = {num2str(i)};
            end
            gui.BinRange.String = brange;
            [c,~] = size(data.bins);
            i = 1;
            while i <= c
                if data.bins(i) > str2num(cell2mat(brange(end)))
                    data.bins(i) = [];
                    c = c - 1;
                else
                    i = i + 1;
                end
            end
            
            for i = gui.BinRange.Value
                if i > ERP.nbin+1
                    gui.BinRange.Value = ERP.nbin+1;
                end
            end
            
            gui.BinRange.Max = ERP.nbin;
            
            onBinChanged(gui.BinRange,0);
            
            updateInterface();
            redrawERP();
        end
    end

    function onBinChanged( src, ~ )
        data.bins = [];
        all_selected = 0>1;
        for i = src.Value
            if i ~= 1 && ~all_selected
                data.bins(1,end+1) = i - 1;
            else
                carray = src.String;
                carray(1) = [];
                data.bins = str2num(cell2mat(carray));
                all_selected = 1>0;
            end
        end
        data.bin_n = numel(data.bins);
        updateInterface();
        redrawERP();
    end

    function timeslmove ( src, ~)
        % on moving the time slider
        data.timefirst = src.Value;
        
        updateInterface();
        redrawERP();
    end

    function nMinimize( eventSource, eventData, whichpanel ) %#ok<INUSL>
        % A panel has been maximized/minimized
        %s = get( box, 'Sizes' );
        
        pheightmin = 25;
        pheightmax = 100;
        pos = get( gui.panel{whichpanel}, 'Position' );
        minned = gui.panel{whichpanel}.IsMinimized;
        szs = get( gui.settingLayout, 'Sizes' );
        if minned
            set( gui.panel{whichpanel}, 'IsMinimized', false);
            szs(whichpanel) = gui.panelSizes(whichpanel);
        else
            set( gui.panel{whichpanel}, 'IsMinimized', true);
            szs(whichpanel) = 25;
        end
        
        set( gui.settingLayout, 'Sizes', szs );
        gui.panelscroll.Heights = sum(szs);
%                  updateInterface();
%                  redrawERP();
%         set( box, 'Sizes', s );
        
        % Resize the figure, keeping the top stationary
        % delta_height = pos(1,4) - sum( box.Sizes );
        % set( fig, 'Position', pos(1,:) + [0 delta_height 0 -delta_height] );
    end % nMinimize

    function up( source, event )
        if source.Value == 1
            gui.posup = 1;
        else
            gui.posup = -1;
        end
        redrawERP();
    end
    
    function hp_halfamp( source, event )
        inp = str2double(source.String);
        if ~isnan(inp) && isreal(inp) % Add tests
            gui.hp_halfamp = inp;
        else
            beep
            disp('ERPLAB Warning: Error parsing input. Ensure that input is a real number.');
            source.String = '';
        end
    end

    function lp_halfamp( source, event )
        inp = str2double(source.String);
        if ~isnan(inp) && isreal(inp) % Add tests
            gui.lp_halfamp = inp;
        else
            beep
            disp('ERPLAB Warning: Error parsing input. Ensure that input is a real number.');
            source.String = '';
        end
    end

    function hp_halfpow( source, event )
        inp = str2double(source.String);
        if ~isnan(inp) && isreal(inp) % Add tests
            gui.hp_halfpow = inp;
        else
            beep
            disp('ERPLAB Warning: Error parsing input. Ensure that input is a real number.');
            source.String = '';
        end
    end

    function lp_halfpow( source, event )
        inp = str2double(source.String);
        if ~isnan(inp) && isreal(inp) % Add tests
            gui.lp_halfpow = inp;
        else
            beep
            disp('ERPLAB Warning: Error parsing input. Ensure that input is a real number.');
            source.String = '';
        end
    end

    function pageviewchanged( src, ~ )
        if src.Value == 1
            data.bins_chans = 0;
        else
            data.bins_chans = 1;
        end
        redrawERP();
    end
    
    %
    % Case: -2 to 10. Plot: -5 to 10
    % Case: 26 to 466. Plot: 25 to 470
    % Case: -14 to 63. Plot: -15 to 65
    % Case: -120 to 128. Plot: -120 to 130
    % Case: -200 to 798. Plot: -200 to 800
    %
    % Conclusion: Max and Min should be non-zero multiples of 5
    %
    % Method: min / 5, floor, * 5
    % Method: max / 5, ceil, * 5
    %

    function time_all( src, ~ )
        if src.Value == 1
            plotops.time_min.Enable = 'off';
            plotops.time_max.Enable = 'off';
            data.min = floor(ERP.times(1)/5)*5;
            plotops.time_min.String = data.min;
            data.max = ceil(ERP.times(end)/5)*5;
            plotops.time_max.String = data.max;
            redrawERP();
        else
            plotops.time_min.Enable = 'on';
            plotops.time_max.Enable = 'on';
        end
    end

    function min_time_change( src, ~ )
        try
            if str2double(src.String) >= data.max
                beep
                src.String = num2str(ERP.times(1));
                disp('Min input must be smaller than max.');
            else
                data.min = str2double(src.String);
            end
            updateInterface()
            redrawERP()
        catch
            beep
            src.String = ERP.times(1);
            data.min = ERP.times(1);
            disp('Could not parse input');
            updateInterface()
            redrawERP()
        end
    end

    function max_time_change( src, ~ )
        try
            if str2double(src.String) <= data.min
                beep
                src.String = ERP.times(end);
                disp('Max input must be greater than min.');
            else
                data.max = str2double(src.String);
            end
            updateInterface()
            redrawERP()
        catch
            beep
            src.String = ERP.times(end);
            data.max = ERP.times(end);
            disp('Could not parse input');
            updateInterface()
            redrawERP()
        end
    end

    function highpass_toggle( src, ~ )
        if src.Value
            gui.hp_halfamp.Enable = 'On';
            gui.hp_halfpow.Enable = 'On';
        else
            gui.hp_halfamp.Enable = 'Off';
            gui.hp_halfpow.Enable = 'Off';
        end
    end

    function lowpass_toggle( src, ~ )
        if src.Value
            gui.lp_halfamp.Enable = 'On';
            gui.lp_halfpow.Enable = 'On';
        else
            gui.lp_halfamp.Enable = 'Off';
            gui.lp_halfpow.Enable = 'Off';
        end
    end
end %EOF