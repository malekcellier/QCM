% Author: Malek Cellier
% Work address: Kista, Sweden
% Email: malek.cellier@huawei.com, malek.cellier@gmail.com
% Created: 2018-01-24

classdef QCMSim < handle
    %QCMSim Eases setting-up, running and postprocessing RT sims
    %   Wrapper to the QCM simulator, eases running and postprocessing of
    %   raytracing simulations based on the QCM model and implemented
    %   by Björn Sihlbom, QAMCOM Research & Technology AB
    %   bjorn.sihlbom@qamcom.se, http://www.qamcom.se, https://github.com/qamcom/QCM 
    
    properties
        c = 3e8;
        f_ghz
        lambda
        universe % QCM Universe object
        pov % Point of views
        db % structure that contains the parameters
        % old paramters
        prm = struct('TX', '', 'RX', '', 'nRx', '', 'nTx', '', 'env', '');        
        tx % tx points are pov
        rx % rx points are pov
    end

    methods
        function obj = QCMSim(sim_preset_name)
            if nargin < 0
                obj.universe = {}
                obj.pov = {}
                return; % This means creating an empty obj
            end
            % In case a sim_preset_name is passed, we assume it can be found in simulations.yaml
            sims = ReadYaml('presets/simulations.yaml')
            obj.universe = QCMUniverse(sims.(sim_preset_name).universe);
            obj.povs = QCMPov(sims.(sim_preset_name).pov)
        end
        
        function addUniverse(obj, universe)
            % For the case where the QCMSim is created empty
        end

        function addPov(obj, pov)
            % For the case where the QCMSim is created empty
        end

        function readPreset(obj, preset_name)
            obj.db = ReadYaml('presets/' + preset_name);
        end

        function run(obj)
        end

        function show(obj)
        end

        function save(obj)
        end
    end
    
end