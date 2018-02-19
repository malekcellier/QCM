% Author: Malek Cellier
% Work address: Kista, Sweden
% Email: malek.cellier@huawei.com, malek.cellier@gmail.com
% Created: 2018-02-13

classdef QCMPov < handle
    %QCMPov Eases setting-up, running and postprocessing RT sims
    %   Wrapper to the QCM simulator, eases running and postprocessing of
    %   raytracing simulations based on the QCM model and implemented
    %   by Björn Sihlbom, QAMCOM Research & Technology AB
    %   bjorn.sihlbom@qamcom.se, http://www.qamcom.se, https://github.com/qamcom/QCM 
    
    properties
        c = 3e8 % 299.792.458 m/s
        freqs % list of simulated frequencies
        cfreq % Central frequency
        clambda % Lambda of cfreq = c/cfreq
        tx % tx points are pov, cell array
        rx % rx points are pov, cell array
        db % structure that contains the parameters
    end

    methods
        function obj = QCMPov(preset_name)
            % A Point of VIew is created using:
            % tag,agroup,position,elevation,azimuth,velocity
            % - tag: a string to describe it
            % - agroup: an arrayGroup
            % - position: coordinates [1,2,3]
            % - elevation: hor=0, up>0, value in degrees
            % - azimuth: anticlockwise, (0,i) is 0, value in degrees
            % - volocity: defaults to [0,0,0] if not specified
            % One should be able to define the following properties per PoV
            % element, array shape, arrays list
            if nargin < 0
            end
            % In case a sim_preset_name is passed, we assume it can be found in simulations.yaml
            povs = ReadYaml('presets/pov.yaml')
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