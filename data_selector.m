function out = data_selector(varargin)
%data_selector(Parent,Fontsize);
BoxPan = uiextras.BoxPanel( ...
    'Parent', varargin(1), ...
    'Title', 'Data selector', ...
    'FontSize',varargin(2), 'FontWeight', 'bold');
out = BoxPan;

    function drawui()
        % Try a 4x4 grid for data selection (set thru set sizes below)
        DataSelBox = uiextras.VBox('Parent', panel{1}, 'Spacing',1);
        DataSelGrid = uiextras.Grid('Parent', DataSelBox, 'Spacing',1);
        % Columns are filled first. First column:
        uiextras.Empty('Parent', DataSelGrid); % 1A
        %uicontrol('Style','text','Parent', DataSelGrid,'String','Select all'); % 2A
        uicontrol('Style','text','Parent', DataSelGrid,'String','Current selection'); % 3A
        uicontrol('Style','text','Parent', DataSelGrid,'String','Sort'); % 4A
        % Second column:
        uicontrol('Style','text','Parent', DataSelGrid,'String','Channels'); % 1B
        %ElecAll = uicontrol('Parent', DataSelGrid,'Style', 'checkbox'); % 2B
        ElecRange = uicontrol('Parent', DataSelGrid,'Style','listbox','min',1,'max',data.elec_n+1,...
            'String', data.elec_list, 'Callback',@onElecRange, 'Value', data.elecs_shown); % 3B
        ElecSort = uicontrol('Parent', DataSelGrid,'Style','checkbox','Callback',@onElecSort); % 4B
        % Third column:
        uicontrol('Style','text','Parent', DataSelGrid,'String','Bins'); % 1C
        %BinAll = uicontrol('Parent', DataSelGrid,'Style', 'checkbox'); % 2C
        brange = cell(ERP.nbin+1,1);
        brange(1) = {'ALL'};
        for i = 1:ERP.nbin
            brange(i+1) = {num2str(i)};
        end
        BinRange =  uicontrol('Parent', DataSelGrid,'Style','listbox','Min',1,'Max',ERP.nbin+1,...
            'String', brange,'callback',@onBinChanged); % 3C
        uiextras.Empty('Parent', DataSelGrid);
        %BinN = uicontrol('Parent', DataSelGrid,'Style','edit','String', data.bins); % 4C
        % Fourth column:
        uicontrol('Style','text','Parent', DataSelGrid,'String','ERPsets'); % 1D
        %SetAll = uicontrol('Parent', DataSelGrid,'Style', 'checkbox'); % 2D
        [~,numerps] = size(observe_ERPDAT.ALLERP);
        range = cell(numerps+1);
        range(1) = {'ALL'};
        for i = 1:numerps
            range(i+1) = {num2str(i)};
        end
        r_range = range(:,1);
        SetRange = uicontrol('Parent', DataSelGrid,'Style','listbox','String',r_range,'Value',observe_ERPDAT.CURRENTERP+1,'callback',@onErpChanged); % 3D
        uiextras.Empty('Parent', DataSelGrid);
        %SetN = uicontrol('Parent', DataSelGrid,'Style','edit','String', '1'); % 4D
        % Set grid sizes
        set(DataSelGrid, 'ColumnSizes',[60 -2 -2 -2],'RowSizes',[30 -3 20]);
    end
end