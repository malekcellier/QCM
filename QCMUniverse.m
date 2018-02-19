% Author: Malek Cellier
% Work address: Kista, Sweden
% Email: malek.cellier@huawei.com
% Created: 2018-01-25

classdef QCMUniverse < handle
    %QCMUNIVERSE Builds input universe to QCM model
    %   Takes YAML file as input describing the world used for QCM
    %   simulations as containing a ground, buildings (which each their
    %   faces) and provides functions to display them
    
    properties
        universe % Universe object
        ground % GroundStructure object
        buildings % BuildingStructure object
        trees % TreeStructure object
        preset_name % name of the preset from the universes.yaml file
        prm % matlab structure containing the output of ReadYaml(preset_file)
        presets % presets for buildings, trees, etc..
    end


    methods
        function obj = QCMUniverse(preset_name, preset)
            if nargin == 0
                % Nothing is specified, so fall back to the local yaml file
                preset_name = 'simple_test'; % Should be default instead
                preset = '';
            elseif nargin == 1
                % The name of the preset of the local yaml file is passed
                preset = '';
            %elseif nargin == 2
                % There are 2 inputs which means that the name of the preset
                % As well as the preset in json foam has been passed by the calling funciton

            end

            obj.preset_name = preset_name;
            obj.readParameters(preset_name, preset)
            obj.readPresets() % Buildings presets so far
            obj.create()
        end

        function readParameters(obj, preset_name, preset)            
            if strcmp(preset, '')
                % The preset is empty => the local file is used
                params = ReadYaml('presets/universes.yaml');
                obj.prm = params.(preset_name); % This is the universe preset            
            else
                % The actual preset is passed
                disp('Raw preset:')
                preset
                obj.prm = jsondecode(preset);
                obj.prm.materials
                obj.prm.trees
                obj.prm.ground
                obj.prm.buildings

            end
        end
        
        function readPresets(obj)            
            % Presets for the universe elements: buildings, trees, etc..
            obj.presets = struct('buildings', ReadYaml('presets/buildings.yaml'));
        end

        function create(obj)
            obj.createUniverse()
            obj.createBuildings()
            obj.createTrees()
        end

        function createUniverse(obj)
            obj.universe = Universe(obj.preset_name);
            % The ground is assumed to be the most basic part of the universe
            grd = obj.prm.ground;
            matGround = GenericMaterial(obj.prm.materials.ground.tag, obj.prm.materials.ground.shading);
            gs = GroundStructure(grd.size.east_west, grd.size.north_south , grd.resolution, matGround);
            obj.universe.AddAtoms('Ground', gs);
            obj.ground = gs;
        end

        function createBuildings(obj)
            % If no buildings, return
            if ~isfield(obj.prm, 'buildings')
                return
            end
            % materials
            matRoof = GenericMaterial(obj.prm.materials.roof.tag, obj.prm.materials.roof.shading);
            matWall = GenericMaterial(obj.prm.materials.wall.tag, obj.prm.materials.wall.shading);
            % The yaml file contains sets of buildings defined as groups
            bgs = obj.prm.buildings;
            nBuildingGroups = size(bgs, 2);
            obj.buildings = {};
            i_building = 1;
            for ii=1:nBuildingGroups % Each group has several buildings
                bg = bgs{ii};
                func_handle = eval(['@layout_', bg.layout.class]);                
                coords = func_handle(obj, bg.layout.preset);
                if isfield(bg, 'translation')
                    coords.x = coords.x + bg.translation.x;
                    coords.y = coords.y + bg.translation.y;
                end     
                % Height can be a constant or a struct with mean and std
                if class(bg.size.height) == 'struct'
                    heights = bg.size.height.mean + bg.size.height.std*randn(1, coords.n);                    
                else
                    heights = bg.size.height*ones(1, coords.n);
                end
                % Corners
                corners = [bg.size.x/2*[-1 -1 1 1]' bg.size.y/2*[-1 1 1 -1]'];
                % Rotation
                rots = zeros(1, coords.n);
                if isfield(bg, 'rotation') & (class(bg.size.height) == 'struct')
                    rots = bg.rotation.mean + bg.rotation.std*randn(1, coords.n);
                end
                % Iterating over the building list
                for ib=1:coords.n
                    pos = [coords.x(ib) coords.y(ib) 0]; % Height above groud is always 0??
                    % Create the building
                    building = BuildingStructure(corners, heights(ib), bg.resolution, matWall, matRoof);
                    obj.universe.AddAtoms(sprintf('Building%d', i_building), building, pos, rots(ib))
                    % Saving the building
                    obj.buildings{i_building} = building;
                    i_building = i_building + 1;
                end
            end
        end

        function createTrees(obj)
            % If no trees, return
            if ~isfield(obj.prm, 'trees')
                return
            end        
            % The materials for the trees are the same for all trees
            matTrunk = GenericMaterial(obj.prm.materials.trunk.tag, obj.prm.materials.trunk.shading);
            matFoliage = ScatteringMaterial(obj.prm.materials.foliage.tag, obj.prm.materials.foliage.shading);
            % The trees are explicitly defined with position, radius and height
            nTrees = size(obj.prm.trees, 2);
            obj.trees = cell(1, nTrees);
            for ii=1:nTrees
                %disp('obj.prm.trees: ')
                %obj.prm.trees
                %obj.prm.trees(1)
                %obj.prm.trees(2)
                %disp('obj.prm.trees.position: ')
                %obj.prm.trees.position
                %disp('type obj.prm.trees: ')
                %type(obj.prm.trees)
                %disp('obj.prm.trees{ii}: ')
                %obj.prm.trees{ii}
                pos = cell2mat(obj.prm.trees{ii}.position);
                radius = obj.prm.trees{ii}.radius;
                height = obj.prm.trees{ii}.height;
                % Tree building API from TreeStructure
                tree = TreeStructure(pos, radius, height, matTrunk, matFoliage);
                % Adding the tree to the universe
                obj.universe.AddAtoms(sprintf('Tree%d', ii), tree)
                % Saving to a cell array
                obj.trees{ii} = tree;
            end
        end

        function show(obj)
            figure(3);
            obj.universe.Plot()
        end

        % Layout functions
        function coords = layout_grid(obj, preset)
            coords = struct('x', [], 'y', [], 'n', 0);
            params = obj.presets.buildings.grid.(preset);
            if ~isfield(params.x, 'min') || ~isfield(params.x, 'max') || ~isfield(params.y, 'min')  || ~isfield(params.y, 'max')
                params.x.min = 0;
                params.x.max = obj.prm.ground.size.east_west;
                params.y.min = 0;
                params.y.max = obj.prm.ground.size.north_south;
            end
            if params.x.min == params.x.max
                x = params.x.min;
            else
                x = params.x.min:params.x.spacing:params.x.max;
            end
            if params.y.min == params.y.max
                y = params.y.min;
            else
                y = params.y.min:params.y.spacing:params.y.max;
            end
            [X, Y] = meshgrid(x, y);
            coords.x = reshape(X, [1, numel(X)]);
            coords.y = reshape(Y, [1, numel(Y)]);
            coords.n = numel(X);
        end

        function coords = layout_circle(obj, preset)
            coords = struct('x', [], 'y', [], 'n', 0);
            params = obj.presets.buildings.circle.(preset);
            r = 0:params.n-1;
            if ~isfield(params, 'center')
                params.center = struct();
                params.center.x = obj.prm.ground.size.east_west/2;
                params.center.y = obj.prm.ground.size.north_south/2;
            end
            if ~isfield(params, 'angle')
                params.angle = 360;
            end
            params.angle = params.angle*pi/180;
            coords.x = params.center.x + params.radius*cos(r/(params.n-1)*params.angle);
            coords.y = params.center.y + params.radius*sin(r/(params.n-1)*params.angle);
            coords.n = params.n;
        end
    end

end