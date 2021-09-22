% Layout - Compute optimal wind farm layout in the presence of a radar
%
% Usage:
%    [TLat, TLon, Stat] = Layout(WFLat, WFLon, RLat, RLon, D, Sx, Sy, ...
%       WindDir, Nx, Ny, RRr, RRaz);
%
% Arguments:
%    WFLat, WFLon: Wind farm center latitude and longitude
%    RLat, RLon: Radar latitude and longitude
%    D: Rotor diameter (m)
%    Sx: Streamwise spacing (rotor diameters)
%    Sy: Spanwise spacing (rotor diameters)
%    WindDir: Predominant (design) wind direction (degrees)
%    Nx: Number of wind turbine rows (streamwise)
%    Ny: Number of wind turbine columns (spanwise)
%    RRr: Radar range resolution (m)
%    RRaz: Radar azimuth resolution (degrees)
%
% Returns:
%    TLat: Wind turbine latitude locations
%    TLon: Wind turbine longitude locations
%    Stat: Wind farm parameters and statistics

% Notes: Supplementary materials for Radar-Aware Wind Turbine Siting paper by
% Brigada and Ryvkina, submitted to IEEE Transactions on Sustainable Energy,
% 2021.
%
% Proof of concept.
%
% Tries to align in a streamwise/spanwise grid, even when the given wind farm
% won't fit with that orientation.  The location adjustment via Newton iteration
% causes this to explode when there's no solution.  A robust implementation
% would try to move turbine locations to different grid locations to attempt a
% proper fit.
%
% Does not account for terrain, wind turbine height, radar height, or Earth
% curvature.
%
% Requires MATLAB and the MATLAB Mapping Toolbox; licenses are available from
% https://www.mathworks.com/

% Distribution Statement A.  Approved for public release.  Distribution is
% unlimited.
%
% This material is based upon work supported by the Department of Energy under
% Air Force Contract No. FA8702-15-D-0001. Any opinions, findings, conclusions
% or recommendations expressed in this material are those of the author(s) and
% do not necessarily reflect the views of the Department of Energy .
%
% © 2021 Massachusetts Institute of Technology.
%
% Subject to FAR52.227-11 Patent Rights - Ownership by the contractor (May 2014)
%
% Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS
% Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice,
% U.S. Government rights in this work are defined by DFARS 252.227-7013 or DFARS
% 252.227-7014 as detailed above. Use of this work other than as specifically
% authorized by the U.S. Government may violate any copyrights that exist in
% this work.

function [TLat, TLon, Stat] = Layout(WFLat, WFLon, RLat, RLon, D, Sx, Sy, ...
		WindDir, Nx, Ny, RRr, RRaz)
	%% Get Earth properties
	Ellps = wgs84Ellipsoid;

	%% Compute range and azimuth from radar to wind farm
	[Range, RadarDir] = distance(RLat, RLon, WFLat, WFLon, Ellps);

	Theta = (RadarDir - WindDir) * pi / 180;
	if Theta < -pi
		Theta = Theta + 2*pi;
	elseif Theta >= pi
		Theta = Theta - 2*pi;
	end

	ThetaS = pi/2 - abs(pi/2 - abs(Theta));

	%% Compute optimal stagger factors
	RRth = RRaz * pi / 180;
	RRcr = RRth .* Range;

	% Eqn. 1
	Gsx = -(Sy / Sx) .* tan(Theta);

	% Eqn. 2
	Gx = Wrap(Gsx, -0.5, 0.5);

	% Eqn. 3
	Cx = min([Range .* RRth .* RRr ./ (D.^2 .* Sx .* Sy), ...
		RRr .* sec(ThetaS) ./ (D .* Sx), ...
		Range .* RRth ./ (D .* Sy), ...
		1]);

	% Eqn. 4
	Gsy = -(Sx / Sy) .* cot(Theta);

	% Eqn. 2 (for y)
	Gy = Wrap(Gsy, -0.5, 0.5);

	% Eqn. 5
	Cy = min([Range .* RRth .* RRr ./ (D.^2 .* Sx .* Sy), ...
		RRr .* csc(ThetaS) ./ (D .* Sy), ...
		Range .* RRth ./ (D .* Sx), ...
		1]);

	%% Choose between streamwise and spanwise alignment
	% Eqn. 6
	ThetaC = atan(Sx ./ Sy);

	if ThetaS <= ThetaC
		% Eqn. 7
		C = Cx;

		G = Gx;
		Gs = Gsx;
		DG = G - Gs;

		% Eqn. 8
		Rt = D .* Sy .* sec(ThetaS) ./ RRth;

		% Eqn. 9
		d = D .* Sx .* cos(ThetaS);

		CrossIndex = -(Ny - 1) / 2 : (Ny - 1) / 2;
		RingIndex = (-(Nx - 1) / 2 : (Nx - 1) / 2)' + DG * CrossIndex;
	else
		% Eqn. 7
		C = Cy;
		G = Gy;
		Gs = Gsy;
		DG = G - Gs;

		% Eqn. 8
		Rt = D .* Sx .* csc(ThetaS) ./ RRth;

		% Eqn. 9
		d = D .* Sy .* sin(ThetaS);

		CrossIndex = (-(Nx - 1) / 2 : (Nx - 1) / 2)';
		RingIndex = (-(Ny - 1) / 2 : (Ny - 1) / 2) + DG * CrossIndex;
	end

	%% Compute radar range spacing
	% Eqn. 10
	RangeI = Range + RingIndex .* d;

	%% Compute initial wind turbine locations
	% Compute a transform from latitude-longitude space to an equal-area
	% azimuthal projection centered on the radar
	Proj = defaultm('eqaazim');
	Proj.origin = [RLat, RLon, 0];
	Proj.geoid = Ellps;
	Proj = defaultm(Proj);

	% X: Streamwise direction
	% Y: Spanwise direction
	XI = (-(Nx - 1) / 2 : (Nx - 1) / 2)';
	YI = -(Ny - 1) / 2 : (Ny - 1) / 2;

	% Compute wind turbine locations in X-Y space
	if ThetaS <= ThetaC
		DX = (XI - G .* YI) .* D .* Sx;
		DY = YI .* D .* Sy;
	else
		DX = XI .* D .* Sx;
		DY = (YI - G .* XI) .* D .* Sy;
	end

	% Convert X-Y wind turbine locations to U-V space
	% U: East
	% V: North
	[U0, V0] = mfwdtran(Proj, WFLat, WFLon);
	U = U0 + DX .* sind(WindDir) - DY .* cosd(WindDir);
	V = V0 + DX .* cosd(WindDir) + DY .* sind(WindDir);

	%% Adjust wind turbine locations to match range rings
	% Compute adjustment direction---either directly streamwise or spanwise
	if ThetaS <= ThetaC
		Alpha = WindDir * pi/180;
	else
		Alpha = WindDir * pi/180 + pi/2;
	end

	% Adjust wind turbine locations via Newton iteration so that they land
	% directly on the range rings
	for k = 1 : 5
		% Compute range and azimuth from radar to each wind turbine
		R = hypot(U, V);
		Phi = atan2(U, V);
		% Change in range is the difference in range times the secant of the
		% difference between the adjustment angle and the azimuth
		DR = (RangeI - R) .* sec(Phi - Alpha);
		% Compute change in U-V space
		DU = DR .* sin(Alpha);
		DV = DR .* cos(Alpha);
		% Compute new positions
		U = U + DU;
		V = V + DV;
	end

	%% Transform to latitude/longitude space for output
	[TLat, TLon] = minvtran(Proj, U, V);

	%% Prepare statistics for output
	Stat.Range = Range;
	Stat.Theta = Theta * 180 / pi;
	Stat.ThetaS = ThetaS * 180 / pi;
	Stat.ThetaC = ThetaC * 180 / pi;
	Stat.G = G;
	Stat.Gs = Gs;
	Stat.C = C;
	Stat.Rt = Rt;
	Stat.d = d;
	Stat.RangeI = RangeI;
end

function y = Wrap(x, l, h);
	% Wrap x to the range l to h
	y = mod(x - l, (h - l)) + l;
end
