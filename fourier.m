% -------------------------------------------------------------------------
%    <fourier.m> Is part of a COMTRADE reading software suite. Is the 
%                discrete Fourier transform of vector 'x' with elements:
%
%                               n_samp
%    X.real = (sqrt(2)/n_samp) * sum  x(k-n_samp+n)*cos(2*pi*n/N)
%                                n=1
%
%                               n_samp
%    X.imag = (sqrt(2)/n_samp) * sum  x(k-n_samp+n)*sin(-2*pi*n/N)
%                                n=1
%
%    Where: 1 <= k <= number of samples in 'x'.
%
% -------------------------------------------------------------------------
%    Copyright (C) 2011  Giovanni Manassero Junior
% -------------------------------------------------------------------------
%
%    This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
% -------------------------------------------------------------------------
function [X] = fourier(x,k,samp_frequency,lf)

tf     = 1/lf;                      % // Line signal period
ts     = 1/samp_frequency;          % // Sampling period
n_samp = round(samp_frequency/lf);	% // Number of samples per cycle
theta  = 2*pi/n_samp;               % // Angle

% // Defining the array used in the DFT calculations
temp_array = zeros(1,n_samp);

if (k<=n_samp)
	for aux=1:k
		temp_array(n_samp-aux+1) = x(k-aux+1);
    end
else
	for aux=1:n_samp
		temp_array(n_samp-aux+1) = x(k-aux+1);
    end
end

X = struct('real',0,'imag',0);
for aux = 1:n_samp
   X.real = X.real + (sqrt(2)/n_samp)*(temp_array(aux)*cos(theta*(aux-1)));
   X.imag = X.imag - (sqrt(2)/n_samp)*(temp_array(aux)*sin(theta*(aux-1)));
end
X.peak      = sqrt(2)*abs(X.real + i*X.imag);
X.magnitude = abs(X.real + i*X.imag);
X.phase_rad = angle(X.real + i*X.imag);
X.phase_deg = X.phase_rad*180/pi;
X.complex   = X.real + sqrt(-1)*X.imag;         