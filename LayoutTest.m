% LayoutTest - Demonstrate the Layout function and visualize wind farms
%
% Usage:
%    LayoutTest;
%
% GUI controls provide the interface for this function.

% Notes: Supplementary materials for Radar-Aware Wind Turbine Siting paper by
% Brigada and Ryvkina, submitted to IEEE Transactions on Sustainable Energy,
% 2021.
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

function LayoutTest
	%% Radar parameters
	RRange = 231.5; % Range resolution, m
	RAz = 2; % Azimuth resolution, degrees

	%% Prepare user interface
	clf;
	f = gcf;

	ax = axes('Position', [.13 .3 .775 .65]);
	box on;

	uicontrol(f, 'Style', 'text', 'String', 'Radar', ...
		'Units', 'normalized', 'Position', [0.1 0.22 0.4 0.03]);
	uicontrol(f, 'Style', 'text', 'String', 'Latitude', ...
		'Units', 'normalized', 'Position', [0.1 0.19 0.1 0.03]);
	uicontrol(f, 'Style', 'text', 'String', 'Longitude', ...
		'Units', 'normalized', 'Position', [0.1 0.16 0.1 0.03]);
	rrlat = uicontrol(f, 'Style', 'text', 'String', ['30.0000' 176], ...
		'Units', 'normalized', 'Position', [0.4 0.19 0.1 0.03]);
	rrlon = uicontrol(f, 'Style', 'text', 'String', ['0.0000' 176], ...
		'Units', 'normalized', 'Position', [0.4 0.16 0.1 0.03]);
	urlat = uicontrol(f, 'Style', 'slider', 'Min', -90, 'Max', 90, ...
		'Value', 30, 'SliderStep', [0.01, 1] / 180, ...
		'Units', 'normalized', 'Position', [0.2 0.19 0.2 0.03], ...
		'Callback', @(s,~) update_con(rrlat, s, ['%.4f' 176]));
	urlon = uicontrol(f, 'Style', 'slider', 'Min', -180, 'Max', 180, ...
		'SliderStep', [0.01, 1] / 360, ...
		'Units', 'normalized', 'Position', [0.2 0.16 0.2 0.03], ...
		'Callback', @(s,~) update_con(rrlon, s, ['%.4f' 176]));

	uicontrol(f, 'Style', 'text', 'String', 'Wind Farm', ...
		'Units', 'normalized', 'Position', [0.5 0.22 0.4 0.03]);
	uicontrol(f, 'Style', 'text', 'String', 'Latitude', ...
		'Units', 'normalized', 'Position', [0.5 0.19 0.1 0.03]);
	uicontrol(f, 'Style', 'text', 'String', 'Longitude', ...
		'Units', 'normalized', 'Position', [0.5 0.16 0.1 0.03]);
	rwlat = uicontrol(f, 'Style', 'text', 'String', ['30.3000' 176], ...
		'Units', 'normalized', 'Position', [0.8 0.19 0.1 0.03]);
	rwlon = uicontrol(f, 'Style', 'text', 'String', ['0.1000' 176], ...
		'Units', 'normalized', 'Position', [0.8 0.16 0.1 0.03]);
	uwlat = uicontrol(f, 'Style', 'slider', 'Min', -90, 'Max', 90, ...
		'Value', 30.3, 'SliderStep', [0.01, 1] / 180, ...
		'Units', 'normalized', 'Position', [0.6 0.19 0.2 0.03], ...
		'Callback', @(s,~) update_con(rwlat, s, ['%.4f' 176]));
	uwlon = uicontrol(f, 'Style', 'slider', 'Min', -180, 'Max', 180, ...
		'Value', 0.1, 'SliderStep', [0.01, 1] / 360, ...
		'Units', 'normalized', 'Position', [0.6 0.16 0.2 0.03], ...
		'Callback', @(s,~) update_con(rwlon, s, ['%.4f' 176]));

	uicontrol(f, 'Style', 'text', 'String', 'Distance', ...
		'Units', 'normalized', 'Position', [0.1 0.13 0.1 0.03]);
	rdist = uicontrol(f, 'Style', 'text', 'String', 'x', ...
		'Units', 'normalized', 'Position', [0.4 0.13 0.1 0.03]);

	uicontrol(f, 'Style', 'text', 'String', 'Azimuth', ...
		'Units', 'normalized', 'Position', [0.5 0.13 0.1 0.03]);
	raz = uicontrol(f, 'Style', 'text', 'String', 'x', ...
		'Units', 'normalized', 'Position', [0.8 0.13 0.1 0.03]);

	uicontrol(f, 'Style', 'text', 'String', 'D', ...
		'Units', 'normalized', 'Position', [0.1 0.10 0.1 0.03]);
	rd = uicontrol(f, 'Style', 'text', 'String', '113', ...
		'Units', 'normalized', 'Position', [0.4 0.10 0.1 0.03]);
	ud = uicontrol(f, 'Style', 'slider', 'Min', 0, 'Max', 300, ...
		'Value', 113, 'SliderStep', [1, 10] / 300, ...
		'Units', 'normalized', 'Position', [0.2 0.10 0.2 0.03], ...
		'Callback', @(s,~) update_con(rd, s, '%.0f m'));

	uicontrol(f, 'Style', 'text', 'String', 'Sx', ...
		'Units', 'normalized', 'Position', [0.1 0.07 0.1 0.03]);
	rsx = uicontrol(f, 'Style', 'text', 'String', '7.0 D', ...
		'Units', 'normalized', 'Position', [0.4 0.07 0.1 0.03]);
	usx = uicontrol(f, 'Style', 'slider', 'Min', 0, 'Max', 20, ...
		'Value', 7, 'SliderStep', [0.2, 1] / 20, ...
		'Units', 'normalized', 'Position', [0.2 0.07 0.2 0.03], ...
		'Callback', @(s,~) update_con(rsx, s, '%.1f D'));

	uicontrol(f, 'Style', 'text', 'String', 'Sy', ...
		'Units', 'normalized', 'Position', [0.1 0.04 0.1 0.03]);
	rsy = uicontrol(f, 'Style', 'text', 'String', '5.0 D', ...
		'Units', 'normalized', 'Position', [0.4 0.04 0.1 0.03]);
	usy = uicontrol(f, 'Style', 'slider', 'Min', 0, 'Max', 20, ...
		'Value', 5, 'SliderStep', [0.2, 1] / 20, ...
		'Units', 'normalized', 'Position', [0.2 0.04 0.2 0.03], ...
		'Callback', @(s,~) update_con(rsy, s, '%.1f D'));

	uicontrol(f, 'Style', 'text', 'String', 'Wind Dir.', ...
		'Units', 'normalized', 'Position', [0.5 0.10 0.1 0.03]);
	rwd = uicontrol(f, 'Style', 'text', 'String', ['0.0' 176], ...
		'Units', 'normalized', 'Position', [0.8 0.10 0.1 0.03]);
	uwd = uicontrol(f, 'Style', 'slider', 'Min', 0, 'Max', 360, ...
		'Value', 0, 'SliderStep', [1, 15] / 360, ...
		'Units', 'normalized', 'Position', [0.6 0.10 0.2 0.03], ...
		'Callback', @(s,~) update_con(rwd, s, ['%.1f' 176]));

	uicontrol(f, 'Style', 'text', 'String', 'Nx', ...
		'Units', 'normalized', 'Position', [0.5 0.07 0.1 0.03]);
	rnx = uicontrol(f, 'Style', 'text', 'String', '9', ...
		'Units', 'normalized', 'Position', [0.8 0.07 0.1 0.03]);
	unx = uicontrol(f, 'Style', 'slider', 'Min', 1, 'Max', 40, ...
		'Value', 9, 'SliderStep', [1, 5] / 40, ...
		'Units', 'normalized', 'Position', [0.6 0.07 0.2 0.03], ...
		'Callback', @(s,~) update_con(rnx, s, '%.0f'));

	uicontrol(f, 'Style', 'text', 'String', 'Ny', ...
		'Units', 'normalized', 'Position', [0.5 0.04 0.1 0.03]);
	rny = uicontrol(f, 'Style', 'text', 'String', '9', ...
		'Units', 'normalized', 'Position', [0.8 0.04 0.1 0.03]);
	uny = uicontrol(f, 'Style', 'slider', 'Min', 1, 'Max', 40, ...
		'Value', 9, 'SliderStep', [1, 5] / 40, ...
		'Units', 'normalized', 'Position', [0.6 0.04 0.2 0.03], ...
		'Callback', @(s,~) update_con(rny, s, '%.0f'));

	%% Calculate and display wind turbine grid
	update();

	function update_con(ctrl, src, fmt)
		% This is called when a slider is changed
		%% Update the label next to the slider
		ctrl.String = sprintf(fmt, src.Value);

		%% Calculate and display wind turbine grid
		update();
	end

	function update()
		%% Get values from GUI controls
		rlat = urlat.Value;
		rlon = urlon.Value;

		wlat = uwlat.Value;
		wlon = uwlon.Value;

		d = ud.Value;

		sx = usx.Value;
		sy = usy.Value;

		wd = uwd.Value;

		nx = unx.Value;
		ny = uny.Value;

		%% Compute distance and azimuth from radar to wind farm
		[dist, az] = distance(rlat, rlon, wlat, wlon, wgs84Ellipsoid);
		rdist.String = sprintf('%.2f km', dist/1000);
		raz.String = sprintf('%.1f%c', az, 176);

		%% Compute wind turbine locations
		[TLat, TLon, Stat] = Layout(wlat, wlon, rlat, rlon, d, sx, sy, wd, ...
			nx, ny, RRange, RAz);

		%% Display contaminated areas
		Ellps = wgs84Ellipsoid;
		cla;
		NAz = 4;
		for k = 1 : numel(TLon)
			[wr, waz] = distance(rlat, rlon, TLat(k), TLon(k), Ellps);
			br = [repmat(wr - RRange / 2, 1, NAz), ...
				repmat(wr + RRange / 2, 1, NAz)];
			baz = linspace(waz - RAz / 2, waz + RAz / 2, NAz);
			baz = [baz, fliplr(baz)];
			[blat, blon] = reckon(rlat, rlon, br, baz, Ellps);
			patch(blon, blat, [.9961 .8667 .0118], 'LineStyle', 'none');
			hold on;
		end

		%% Display constant-range rings
		RingAz = 0:360;
		RingRange = unique(Stat.RangeI(:));

		[RingLat, RingLon] = reckon(rlat, rlon, ...
			RingRange + zeros(size(RingAz)), ...
			RingAz + zeros(size(RingRange)), ...
			Ellps);
		lon1 = min(TLon(:));
		lon2 = max(TLon(:));
		lat1 = min(TLat(:));
		lat2 = max(TLat(:));
		RingLat = [RingLat'; nan(1, numel(RingRange))];
		RingLon = [RingLon'; nan(1, numel(RingRange))];
		plot(RingLon(:), RingLat(:), '-', 'Color', [.7 .7 .7]);

		%% Display wind farm center and line from radar to wind farm
		plot(wlon, wlat, 'x', 'Color', [.7 .7 .7]);
		plot([rlon, wlon], [rlat, wlat], '-', 'Color', [.7 .7 .7]);

		%% Display wind direction and cross-wind-direction lines
		[wdlat, wdlon] = reckon(wlat, wlon, [-dist, dist], wd, Ellps);
		plot(wdlon, wdlat, '-', 'Color', [.7 .7 .7]);

		[cwdlat, cwdlon] = reckon(wlat, wlon, [-dist, dist], wd+90, Ellps);
		plot(cwdlon, cwdlat, '-', 'Color', [.7 .7 .7]);

		%% Plot wind turbine locations
		plot(TLon(:), TLat(:), 'k.', 'MarkerSize', 10);
		hold off;
		xlim([lon1 - (lon2 - lon1) * .05, lon2 + (lon2 - lon1) * .05]);
		ylim([lat1 - (lat2 - lat1) * .05, lat2 + (lat2 - lat1) * .05]);

		%% Apply Mercator sizing correction
		% A true Mercator projection would change the stretch factor
		% continuously as a function of range, but this is good enough for the
		% scales we care about
		ax.DataAspectRatio = [1, tand((lat1 + lat2) / 2), 1];
	end
end
