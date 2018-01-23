% Rotate vectors x around Y-axis n, by phi
%
% x = RotateVectorY(x,a)
% x:    3D points to rotate
% a:    How much to rotate [rad]
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

function x = RotateVectorY(x,a)

N = max(size(x,1),numel(a));
if size(x,1)==1
    x=repmat(x,N,1);
end
if numel(a)==1
    a=repmat(a,N,1);
end

% Rotate around y-axis
x2D=(x(:,1)+1j*x(:,3)).*exp(1j*a);
x(:,1) = real(x2D);
x(:,3) = imag(x2D);

