% Renders channel coefficients for given frequency bins and endpoints.
%
% [y,bbrx]=u.Channels(freqs,rain,x0,x1,bbtx)
% u is an handle to a Universe class (this class)
% freqs:    Vector of frequencies [Hz]
% rain:     Rain intensity [mm/h]
% x0:       Vector of endpoints (class PointOfView)
% x1:       Vector of endpoints (class PointOfView)
% bb:       BB signal transmitted over link. Default white
%
% x1 is optional.
% If excluded all combinations of endpoints in x0 are processed
%
% -------------------------------------------------------------------------
%     This is a part of the Qamcom Channel Model (QCM)
%     Copyright (C) 2017  Bj�rn Sihlbom, QAMCOM Research & Technology AB
%     mailto:bjorn.sihlbom@qamcom.se, http://www.qamcom.se, https://github.com/qamcom/QCM
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
% -------------------------------------------------------------------------

function y=Channels(u,x0,x1,freqs,rain,bb)

if ~exist('bb','var') || isempty(bb), bb=ones(1,numel(freqs)); end
tic

CC = 0; % Coeff counter

% init y. Class?
y.N0 = numel(x0);
y.universe = u;
if ~isempty(x1),
%    y = ChannelResponse(freqs,rain,u,x0);
    y.N1 = numel(x1);
    y.N = y.N0*y.N1;
    fullH = 0;
else
%    y = ChannelResponse(freqs,rain,u,x0,x1);
    y.N1 = y.N0;
    y.N = (y.N0-1)*y.N0/2;
    fullH = 1;
    x1 = x0;
end
y.freqs = freqs;

verbose = (numel(x0)*numel(x1)>1);

if verbose
    msg = sprintf('Rendered 0/%d endpoint pairs. Remaining time = ??',y.N);
    fprintf(msg);
    rev = sprintf('%c',8*ones(1,length(msg)));
end

pp=0;

for endpoint0 = 1:y.N0
    
    pov0 = x0{endpoint0};
    
    for endpoint1 = 1:y.N1
        
        
        if endpoint1<endpoint0 && fullH
            
            % Reciprocal channel
            y.linkMap((endpoint1-1)*y.N0+endpoint0) = -y.linkMap((endpoint0-1)*y.N1+endpoint1);
            
        else
            
            pov1 = x1{endpoint1};
            
            
            
            % Save some particulars for convenience
            pp=pp+1;
            y.linkMap((endpoint1-1)*y.N0+endpoint0)=pp;
            y.endpoints(pp,:) = [endpoint0, endpoint1];
            
            % Get Channel
            y.link{pp} = u.Channel(pov0,pov1,freqs,rain,bb);
            CC = CC+numel(y.link{pp}.Hf);
                
        end
        if verbose
            t=toc;
            
            msg = sprintf('Rendered %d/%d endpoint pairs @ %d kCoeff/sec. Passed=%dmin. Estd Total=%dmin. Estd Remaining=%dmin',pp,y.N,round(CC/t/1e3),round(t/60),round(t/pp*y.N/60),round(t/pp*(y.N-pp)/60));
            fprintf([rev msg]);
            rev = sprintf('%c',8*ones(1,length(msg)));
        end
    end
    
end
if verbose
    fprintf('\nIn total %d Complex Channel Coefficients calculated.\n',CC)
end
y.toc = toc;



