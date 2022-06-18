function [ebsd, header] = loadEBSD_h5(fname,varargin)

if ~exist(fname,'file'), error(['File ' fname ' not found!']); end

ginfo = locFindEBSDGroups(fname);

if numel(ginfo) > 0
    
    groupNames = {ginfo.Name};
    
    patternMatch = false(size(groupNames));
    for k=1:numel(varargin)
        if ischar(varargin{k})
            patternMatch = patternMatch | strncmpi(groupNames,varargin{k},numel(varargin{k}));
        end
    end
    
    if nnz(patternMatch) == 0
        if length(ginfo) > 1
            [sel,ok] = listdlg('ListString',{ginfo.Name},'ListSize',[400 300]);
            
            if ok
                ginfo = ginfo(sel);
            else
                return
            end
        end
    else
        ginfo = ginfo(patternMatch);
    end
end

assert(numel(ginfo) > 0);

if check_option(varargin,'check'), ebsd = EBSD; return; end

try
    for k = 1:numel(ginfo)
        kGroup = ginfo(k);
        
        CS = locReadh5Phase(fname,kGroup);
        
        kGroupData = kGroup.Groups(1).Datasets;
        
        props = struct;
        
        for j=1:numel(kGroupData)
            if strcmpi(kGroupData(j).Name,'RawPatterns') ~= 1
                if length(kGroupData(j).ChunkSize) > 1, continue; end
                data = double(h5read(fname,[kGroup.Groups(1).Name '/' kGroupData(j).Name]));
                
                name = strrep(kGroupData(j).Name,' ','_');
                
                name = strrep(name,'X_Position','x');
                name = strrep(name,'Y_Position','y');
                name = strrep(name,'X_SAMPLE','x');
                name = strrep(name,'Y_SAMPLE','y');
                
                name = regexprep(name,'phi','Phi','ignorecase');
                name = regexprep(name,'phi1','phi1','ignorecase');
                name = regexprep(name,'phi2','phi2','ignorecase');
                
                props.(name) = data(:);
            end
        end
        
        rot = rotation('Euler',props.phi1*degree,props.Phi*degree,props.phi2*degree);
        phases = props.Phase;
        
        props = rmfield(props,{'Phi','phi1','phi2','Phase'});
        
%         ebsd = EBSD(rot,phases,CS,'options',props);
        if length(kGroup.Groups) > 1
            header = h5group2struct(fname,kGroup.Groups(2));
        else
            header = [];
        end
        
        ystep_corf=1; ystep_cor=0;
        %fix the YSTEP value if they are not equal due to a bug in 2.3
        if isfield(header,'XSTEP') && isfield(header,'YSTEP')
            xstep=header.XSTEP;
            ystep=header.YSTEP;
            if round(xstep*100) ~= round(ystep*100)
                ystep_corf=header.XSTEP/ header.YSTEP;
                header.YSTEP=header.XSTEP;
                ystep_cor=1;
            end

        end
        
        ypix_corf=1; ypix_cor=0;
        %fix the XSTEP value if they are not equal due to a bug in 2.3
        if isfield(header,'SEPixelSizeX') && isfield(header,'SEPixelSizeY')
            xstep=header.SEPixelSizeX;
            ystep=header.SEPixelSizeY;
            if round(xstep*100) ~= round(ystep*100)
                ypix_corf=header.SEPixelSizeX/ header.SEPixelSizeY;
                header.SEPixelSizeY=header.SEPixelSizeX;
                ypix_cor=1;
                
            end

        end
            %correct the um positions of each point in the map
        if ystep_cor == 1
            props.y=props.y*ystep_corf;
        end
 
        
        ebsd = EBSD(rot,phases,CS,props);
        
        ind = props.x > -11111;
        ebsd = ebsd(ind);
        ebsd.unitCell = calcUnitCell([ebsd.prop.x,ebsd.prop.y]);
        

    end
end

end

function [ginfo] = locFindEBSDGroups(fname)

info = h5info(fname,'/');

ginfo = struct('Name',{},...
    'Groups',{},...
    'Datasets',{},...
    'Datatypes',{},...
    'Links',{},...
    'Attributes',{});

ginfo = locGr(fname, info.Groups,ginfo);
end

function [ginfo] = locGr(fname,group,ginfo)

if ~isempty(group)
    
    for k=1:numel(group)
        attr  = group(k).Attributes;
        name = group(k).Name;
        
        if (~isempty(attr) && check_option({attr.Value},'EBSD')) || strcmp(name(end-4:end),'/EBSD')
            
            ginfo(end+1) = group(k);
            
        end
        
        [ginfo] = locGr(fname,group(k).Groups,ginfo);
    end
end
end



function CS = locReadh5Phase(fname,group)
% load phase informations from h5 file

group = group.Groups(strcmp([group.Name '/Header'],{group.Groups.Name}));
token = [group.Name '/Phase'];
group = group.Groups(strncmp(token,{group.Groups.Name},length(token)));

for iphase = 1:numel(group.Groups)
    
    try
        mineral = strtrim(char(h5read(fname,[group.Groups(iphase).Name '/MaterialName'])));
    catch
        mineral = strtrim(char(h5read(fname,[group.Groups(iphase).Name '/Name'])));
    end
    formula = strtrim(char(h5read(fname,[group.Groups(iphase).Name '/Formula'])));
    
    try
        lattice(1) = h5read(fname,[group.Groups(iphase).Name '/Lattice Constant a']);
        lattice(2) = h5read(fname,[group.Groups(iphase).Name '/Lattice Constant b']);
        lattice(3) = h5read(fname,[group.Groups(iphase).Name '/Lattice Constant c']);
        
        lattice(4) = h5read(fname,[group.Groups(iphase).Name '/Lattice Constant alpha']);
        lattice(5) = h5read(fname,[group.Groups(iphase).Name '/Lattice Constant beta']);
        lattice(6) = h5read(fname,[group.Groups(iphase).Name '/Lattice Constant gamma']);
        
        pointGroup = h5read(fname,[group.Groups(iphase).Name '/Point Group']);
        pointGroup = regexp(char(pointGroup),'\[([1-6m/\-]*)\]','tokens');
        spaceGroup = pointGroup{1};
        
    catch
        lattice = h5read(fname,[group.Groups(iphase).Name '/LatticeConstants']);
        
        spaceGroup = h5read(fname,[group.Groups(iphase).Name '/SpaceGroup']);
        spaceGroup = strrep(spaceGroup,'#ovl','-');
        if strcmpi(spaceGroup,'P 6#sub3/mmc') %bug fix - TBB & SW (09/04/2018)
            spaceGroup='6/mmm';
        end
    end
    
    try
        CS{iphase} = crystalSymmetry(spaceGroup,double(lattice(1:3)),double(lattice(4:6))*degree,'mineral',mineral);
    catch
        CS{iphase} = 'notIndexed';
    end
end


end