d = 'C:\Users\Level1Zach\Desktop\Hodograph app test data22\Hodograph app test data2\New folder (2)\hodograph';

t = fullfile(d, "*.txt");
files = dir(t); 
axs = [];
series_figure = figure;
hodo_fig = figure; offset = 10;
arrow_offset = 1 / 15;
counter = 1;
already_seen = [];
flight_num = [];
offsets = [];
coriolisFreq = coriolisFrequency(30.25);
unique_flights = ["F01","F02","F03","F04"];
for k=1:size(unique_flights, 2)
    for i=1:size(files)
        flight_number = files(i).name(1:3);
        flight_number(1) = 'F';
    if strcmp(flight_number, unique_flights(k)) == 0
        %fprintf("%s %s\n", unique_flights(k), flight_number);
        continue;
    end
    % if str2num(flight_number(2:end)) ~= 23
    %     continue;
    % end
    data = readtable(fullfile(d, files(i).name));
    set(0, 'CurrentFigure', hodo_fig);
    ax = subplot(6, 5, i);
    axis equal; % this is needed to keep plots circular
    axs = [axs;ax];
    eps = fit_ellipse(data.u, data.v, ax);
    hold on
    plot(data.u, data.v, 'k.')
    lambda_z = 2*(data.Alt(end) - data.Alt(1));
    m = 2*pi / lambda_z;
    p = eps.phi;
    rot = [cos(p) -sin(p); sin(p) cos(p)];
    uv = [data.u data.v];
    uvrot = rot*uv';
    urot = uvrot(1, :);
    dT = data.temp(2:end) - data.temp(1:end-1);
    dz = data.Alt(2:end) - data.Alt(1:end-1);
    wf = eps.long_axis / eps.short_axis;
    bvMean = mean(data.bv2);
    intrinsicFreq = coriolisFreq*wf;
    %fprintf("%0.10f, %0.10f ", (coriolisFreq^2 * m^2)/abs(bvMean), wf^2 - 1);
    k_h = sqrt((coriolisFreq^2*m^2)/(abs(bvMean))*(wf^2 - 1)); % horizontal wavenumber (1 / meters)
    %fprintf("%f %f\n", intrinsicFreq, wf);
    intrinsicHorizPhaseSpeed = intrinsicFreq / k_h; % m/s
    fprintf("m:%f, lz:%f, h:%f,, bv:%f\n", m, lambda_z, intrinsicHorizPhaseSpeed, bvMean);
    k_h_2 = sqrt((intrinsicFreq^2 - coriolisFreq^2 )* (m^2 / abs(bvMean)));
    int2 = intrinsicFreq/k_h_2;
    % fprintf("m:%f, lz:%f, h:%f, kh:%f\n", m, lambda_z, intrinsicHorizPhaseSpeed, int2);
    dTdz = dT./dz;
    eta = mean(dTdz.*urot(1:end-1));
    if eta < 0
        p = p - pi;
    end
    str = sprintf("f: %s, ^{w}/{f}=%0.1f, t=%0.1f, m_z=%0.1f", ...
        files(i).name(1:3), wf, azimuthFromUnitCircle(rad2deg(p)),...
        lambda_z/1000);
    %title(str);
    fprintf("%s\n", str);
    set(0, 'CurrentFigure', series_figure);
    xlim([5, 155]);
    ylim([12, 33]);
    Alt_of_detection_km = mean(data.Alt) / 1000;
    x1 = counter*offset;
    x2 = counter*offset + wf*cosd(rad2deg(p));
    y1 = Alt_of_detection_km;
    y2 = Alt_of_detection_km + wf*sind(rad2deg(p));
    hold on;
    p1 = [x1 y1];
    p2 = [x2 y2];
    dp = p2-p1;
    %quiver(p1(1),p1(2),dp(1),dp(2), 'AutoScale', 'on', 'color','#9a0200', 'linewidth', 2);
    [xf, yf] = ds2nfu([x1 x2], [y1 y2]);
    A = strsplit(files(i).name,'_');
    if ismember('Clockwise.txt',A)
        Ac = '#A2142F';
    elseif ismember('Counter-Clockwise.txt',A)
        Ac = '#0072BD';
    else
        Ac = '#77AC30';
    end
    annotation(gcf, 'arrow', xf,yf, 'color', Ac, 'LineWidth', 2) %plot arrow angle of propagation length corresponds to magnitude of intrinsic frequency
    xc = [xf(1) - 0.015, xf(2)];
    yc = [yf(1) + 0.02, yf(1)];
%                 annotation(gcf, 'line', xc, yc, 'String', num2str(i))
    annotation(gcf, 'textarrow', xc, yc, 'String', num2str(i),'HeadStyle','none')
%                 if strcmp(flight_number, "F23")
%                     if Alt_of_detection_km > 20 && Alt_of_detection_km < 24
%                         xc = [xf(1) - 0.125, xf(2)-0.02];
%                         yc = [yf(1) + 0.1, yf(1)+0.05];
%                         annotation(gcf, 'textarrow', xc, yc, 'String', 'Eclipse Wave #2')
%                     elseif Alt_of_detection_km > 20
%                         xc = [xf(1) - 0.125, xf(2)- 0.02];
%                         yc = [yf(1) + 0.1, yf(1)+0.05];
%                         annotation(gcf, 'textarrow', xc, yc, 'String', 'Eclipse Wave #3')
%                     end
%                     fprintf("%f\n", Alt_of_detection_km);
%                 end
    %plot([x1 x2], [y1 y2], 'color', '#9a0200', 'linewidth', 3);
    placeholder = [counter*offset counter*offset];
    plot(placeholder, [12, 32.5], 'k'); % plot Altitude in km.
    end
    offsets = [offsets, counter*offset];
    counter = counter + 1;
            end
% 10 -> 150

linkaxes(axs, 'xy');
set(0, 'CurrentFigure', hodo_fig);
sgtitle("All hodographs for the radiosonde campaign")
set(0, 'CurrentFigure', series_figure);
% %offsets = offsets(1:end-1);
flight_num = flight_num(1:end-1, :);
xticks(offsets);
xticklabels(unique_flights); 
set(gca,'XTickLabelRotation', 45, 'fontsize', 16)
ylabel("Altitude of detection (km)") 
xlabel("Flight number")
title("Propagation direction and detection Altitude of gravity waves (hodograph method)", 'fontsize', 16);
