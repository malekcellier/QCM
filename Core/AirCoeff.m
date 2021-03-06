% Attenuation in dB per km vs  02/H20 resonances etc
% 
% y=AirCoeff(freqs)
% freqs:    Frequency vector [Hz]
% y:        Air attenuation dB/km
%
% Digitized from
% http://www.ofcom.org.uk/static/archive/ra/topics/research/rcru/project28/results.htm
%
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

function y=AirCoeff(freqs)

table = [...
0,0;...
2.9662583799513422, 0.005719432815349659;...
8.038828287030038, 0.010865773370464318;...
12.191775439299802, 0.018470117805048814;...
15.862900717377984, 0.03510711528529781;...
18.70405819115691, 0.07905747980612111;...
20.993688385502907, 0.17993823426442093;...
22.298003082072835, 0.192848024942266;...
23.680945976809927, 0.17420028248567718;...
25.84407699383574, 0.12390755723905174;...
29.793942422655658, 0.0966282768726366;...
34.54123136842786, 0.09684068361618146;...
39.8332772862846, 0.13052393157158035;...
45.19317099073261, 0.21593656477158904;...
48.54468789112468, 0.3910329460788355;...
54.280819704068875, 15.034608805350047;...
56.09537092153052, 15.74367808774361;...
57.96625927626722, 14.543346232559164;...
64.58108288671254, 1.2560441025498328;...
70.83985757859047, 0.4665610058379655;...
77.7410096236137, 0.3762258431723246;...
87.2173601292355, 0.39445046926675686;...
106.24830647736913, 0.5963254635910326;...
112.30998429445617, 2.0208970566216866;...
121.86075677977021, 0.8411675122554543;...
129.4265682399172, 0.8419203352108133;...
153.42077747504302, 1.4422521942840787;...
160.33669740537047, 2.329412426340515;...
171.47138904719668, 25.836512683638652;...
182.97587952438542, 7.0517401795898955;...
190.03682041053966, 3.2133376344874787;...
199.60859043500167, 2.5311210580477077;...
217.88018299526394, 2.421452003153462;...
278.87006573831695, 4.654209486018059;...
296.31039581273444, 9.552529275310107;...
300               , 10];

% Lookup
Nf = numel(freqs);
indsMin = nan(Nf,1);
indsMax = nan(Nf,1);
for ii=1:numel(freqs)  
    fGHz = freqs(ii)/1e9;
    indsMin(ii) = find(table(:,1)<=fGHz,1,'last');
    indsMax(ii) = find(table(:,1)>=fGHz,1,'first');
end

% Interpolate
fmin = table(indsMin,1);
fmax = table(indsMax,1);
amax = (freqs(:)/1e9-fmin)./(fmax-fmin);
amin = 1-amax;
y = amin.*table(indsMin,2)+amax.*table(indsMax,2);

